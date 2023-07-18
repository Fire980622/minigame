-- ----------------------------------------------------------
-- 逻辑模块 - 游戏登录
-- ----------------------------------------------------------
LoginManager = LoginManager or BaseClass(BaseManager)

function LoginManager:__init()
    if LoginManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

    LoginManager.Instance = self
    self.model = LoginModel.New()

    self.timeId = 0
    self.lastHeartbeatTime = nil

    Connection.Instance:LoadMatedata()

    self:InitHandler()

    self.sendHeartbeat = function(id) self.timeId = id self:Send1099() end

    EventMgr.Instance:AddListener(event_name.socket_connect, function() self:OnConnected() end)
   --[[  if not self.Window then
        self.Window=LoginView.New(self.model)
    end
    --self.Window:Open() ]]
end

function LoginManager:__delete()
    TimerManager.Delete(self.timeId)
end

function LoginManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(1099, self.On1099)
end

function LoginManager:Send1099()
    local time = os.time()
    -- Log.Info(string.format("发心跳包 %s", time))
    if self.lastHeartbeatTime ~= nil and time - self.lastHeartbeatTime > 60 and self.remotelogin == false then
        -- Log.Info("长时间未收到心跳包，判断为断线，重新连接")
        Connection.Instance:Disconnect()
        self.lastHeartbeatTime = nil
    end
    Connection.Instance:Send(1099, { time = time })
end

-- 处理返回的心跳包数据，并将客户端时间与服务器时间进行同步
function LoginManager:On1099(data)
    Log.Info(string.format("收心跳包 %s", data.server_time))
    UtilsBase.Time = data.server_time
    self.lastHeartbeatTime = os.time()
end


-- 登录游戏服务器处理
function LoginManager:DoLogin(serverIndex, account)
    --if self.timeId ~= 0 then TimerManager.Delete(self.timeId) self.timeId = 0 end
    -- self.timeId = TimerManager.Add(0, 10000, self.sendHeartbeat)

    local targetServer = { name = "开发服", host = "192.168.1.69", port = 8001, platform = "dev", zone_id = 1}
    -- Connection.Instance.targetServer = targetServer
    -- Connection.Instance:Connect(targetServer.host, targetServer.port)

    self:LoginSuccess()
end

-- 返回登录界面
function LoginManager:ReturnToLogin(forceHasLogin)

end

function LoginManager:OnConnected()
    self:LoginSuccess()
end

function LoginManager:LoginSuccess()
    self.model:CloseMainUI()
    -- 显示主界面
    -- MainuiManager.Instance:ShowMainuiPanel()
   
end