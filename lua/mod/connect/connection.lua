-- socket连接处理相关接口
Connection = Connection or BaseClass()

local Connection = Connection
local pcall = pcall
local xpcall = xpcall
local callcmd = 0
local socket = require("socket.core")

function Connection:__init()
    Connection.Instance = self

    self.handlers = {} -- 协议回调处理函数
    self.state = ConnectionEnum.State.Idle

    -- self.currentCmd = nil
    -- self.cacheByte = nil

    -- TODO 后续有空优化代码
    self.datalength = nil
    self.cache_buf = nil
    self.cmd = nil
end

function Connection:__delete()
    UtilsBase.FieldDeleteMe(self, "protocalSender")
    UtilsBase.FieldDeleteMe(self, "protocalReceiver")
end

-- 载入或重载协议配置数据
function Connection:LoadMatedata()
    local DataProtocol = require("data/data_protocol")
    self.protocalSender = ProtocalSender.New(DataProtocol.send)
    self.protocalReceiver = ProtocalReceiver.New(DataProtocol.recv)
end

function Connection:OnTick()
end

function Connection:Connect(ip, port)
    if self.state ~= ConnectionEnum.State.Idle then
        return
    end
    self.state = ConnectionEnum.State.Connecting
    self:CreateSocket(ip, port)
end

-- socket建立连接时回调
function Connection:OnConnected()
    Log.Debug("socket已经建立连接")
    UtilsBase.TimerDelete(self, "tickTimer")
    self.state = ConnectionEnum.State.Connected
    EventMgr.Instance:Fire(event_name.socket_connect)
end

-- 断线重连
function Connection:Reconnect()
    if self.state ~= ConnectionEnum.State.Idle then
        return
    end

    --TODO
    -- self:Connect(LoginManager.Instance.targetServer.ip, LoginManager.Instance.targetServer.port)
end

-- 断开连接
function Connection:Disconnect()
    self.datalength = nil
    self.cmd = nil
    self.cache_buf = nil
    Log.Info("主动断开socket\n"..debug.traceback())
    self.tcpSocket:close()
    self.tcpSocket = nil
    self.state = ConnectionEnum.State.Idle
    EventMgr.Instance:Fire(event_name.socket_disconnect)
end

-- 通过socket发送协议数据
function Connection:Send(cmd, data)
    if self.state ~= ConnectionEnum.State.Connected then
        NoticeManager.Instance:ShowFloat(_T("与服务器连接已断开"))
        if self.state ~= ConnectionEnum.State.Connecting then
            self:Reconnect()
        end
        return
    end
    local content = self.protocalSender:Send(cmd, data)
    local res, res1, res2 = self.tcpSocket:send(content)
    local trycount = 0
    if not res then
        if res1 == "closed" then
            trycount = 0
            self:Disconnect()
        elseif trycount == 2 then
            trycount = 0
            self:Disconnect()
        else
            trycount = trycount + 1
        end
    end
end

function Connection:AddHandler(cmd, callback)
    self.handlers[cmd] = callback
end

function Connection:RemoveHandler(cmd)
    self.handlers[cmd] = nil
end

function Connection:GetHandler(cmd)
    return self.handlers[cmd]
end

function Connection:Update()
    if self.state ~= ConnectionEnum.State.Connected then
        return
    end
    for i = 1, 999 do
        if not self:SocketReceive() then
            if i > 10 then
                break
            end
        end
    end
end

function Connection:SocketReceive()
    if self.datalength == nil then
        local lengthnum = ConnectionEnum.CmdByteNum
        if self.cache_buf ~= nil then
            lengthnum = ConnectionEnum.CmdByteNum - #self.cache_buf
        end
        local lengthstr, err, temp = self.tcpSocket:receive(lengthnum)
        if lengthstr then
            if self.cache_buf ~= nil then
                lengthstr = self.cache_buf..lengthstr
            end
            self.cache_buf = nil
            self.datalength = string.unpack("<I", lengthstr, 1)
        else
            if temp ~= nil and #temp > 0 then
                if self.cache_buf == nil then
                    self.cache_buf = temp
                else
                    self.cache_buf = self.cache_buf..temp
                end
                -- Lahm("进行协议长度拼接了！！！！！"..#self.cache_buf)
                -- Log.Info("数据接收不完整进行拼接"..tostring(self.datalength))
            elseif temp == nil then
                Log.Info("协议数据长度接收异常")
                self:Disconnect()
            end
            return
        end
    end
    if self.cmd == nil then
        local lengthnum = 2
        if self.cache_buf ~= nil then
            lengthnum = 2 - #self.cache_buf
        end
        local cmdstr, err, temp = self.tcpSocket:receive(lengthnum)
        if cmdstr then
            if self.cache_buf ~= nil then
                cmdstr = self.cache_buf..cmdstr
            end
            self.cache_buf = nil
            self.cmd = string.unpack("<H", cmdstr, 1)
        else
            if temp ~= nil and #temp > 0 then
                if self.cache_buf == nil then
                    self.cache_buf = temp
                else
                    self.cache_buf = self.cache_buf..temp
                end
                -- Lahm("进行协议号拼接了！！！！！"..#self.cache_buf)
                -- Log.Info("数据接收不完整进行拼接"..tostring(self.datalength))
            elseif temp == nil then
                Log.Info("协议数据长度接收异常")
                self:Disconnect()
            end
            return
        end
    end
    local data, err, temp = self.tcpSocket:receive(self.datalength - 2)
    if data ~= nil or self.datalength - 2 == 0 then
        if self.cache_buf ~= nil then
            data = self.cache_buf..data
        end
        xpcall(Connection.ParseByte, Connection.ParseError, Connection.Instance, self.cmd, data)
        self.cache_buf = nil
        self.datalength = nil
        self.cmd = nil
        return true
    else
        if temp ~= nil and #temp > 0 then
            self.datalength = self.datalength - #temp
            if self.cache_buf == nil then
                self.cache_buf = temp
            else
                self.cache_buf = self.cache_buf..temp
            end
        elseif temp == nil then
            Log.Info("协议数据接收异常")
            self:Disconnect()
        end
        return
    end
end


function Connection:ClearData()
end

function Connection:ParseByte(cmd, data)
    -- TODO data可能为nil吗？
    if data == nil then
        return
    end
    self.protocalReceiver:Receive(cmd, data)
end

function Connection:ParseError()
    if self.tcpSocket then
        self.tcpSocket:close()
    end
end

function Connection:SetState(state)
    self.state = state
end

function Connection:GetNetType()
    if ctx:IsIpv6() then
        return "inet6"
    end
    return "inet"
end

function Connection:CreateSocket(host, port)
    local tcpSocket = socket.tcp()
    if not tcpSocket then
        self:SocketError()
        return
    end

    self.tcpSocket = tcpSocket
    tcpSocket:settimeout(0)
    tcpSocket:connect(host, port, nil, nil, self:GetNetType())

    local try = 0
    local c1 = coroutine.create(function()
        while true do
            local _, cli = socket.select({}, {tcpSocket}, 0)
            Log.Info("尝试连接:" .. try)
            if cli[1] ~= nil then
                tcpSocket:setoption("keepalive", true)
                tcpSocket:settimeout(0)
                local res = tcpSocket:send("--fssj--game--client---")
                if res == nil then
                    self:SocketError()
                    break
                end
                self:OnConnected()
                break
            end
            try = try + 1
            if try > ConnectionEnum.ConnectMaxTryNum then
                self:SocketError()
                break
            end
            coroutine.yield()
        end
    end)
    coroutine.resume(c1)

    UtilsBase.TimerDelete(self, "tickTimer")
    self.tickTimer = TimerManager.Add(0, 0.2, function()
        if coroutine.status(c1) ~= "dead" then
            coroutine.resume(c1)
        else
            return false
        end
    end)
end

function Connection:SocketError()
    self.tcpSocket = nil
    UtilsBase.TimerDelete(self, "tickTimer")
    NoticeManager.Instance:ShowFloat(_T("暂时无法连接服务器，请稍后再试~"))
    self:SetState(ConnectionEnum.State.Idle)
end

