ProtocalReceiver = ProtocalReceiver or BaseClass()

local _table_insert = table.insert
local _table_concat = table.concat
local _string_unpack = string.unpack
local _string_sub = string.sub
local _string_format = string.format
local _pcall = pcall
local _ipairs = ipairs

function ProtocalReceiver:__init(protocolDict)
    self.protocolDict = protocolDict
    self.lastParseKey = ""
end

function ProtocalReceiver:__delete()
end

function ProtocalReceiver:Receive(cmd, data)
    local protocal = self.protocolDict[cmd]
    if protocal == nil then
        if IS_DEBUG then
            LogError(string.format("cmd:%s 客户端漏生成啦，请使用“前端开发工具-更新协议”然后再试一次，还有问题就是后端的锅", cmd))
        end
        return
    end

    self.buffString = data
    self.buffIndex = 1
    local result = {}
    local status = _pcall(ProtocalReceiver.ParseTableData, self, protocal, result)
    if not status then
        LogError(string.format("解析协议：%s出错, 检查协议字段是否与服务端对应,字段位置：%s\n", cmd, self.lastParseKey))
        return
    end

    local handler = Connection.Instance:GetHandler(cmd)
    if handler == nil then
        if IS_DEBUG then
            LogError(string.format("cmd:%s 客户端漏监听啦", cmd))
        end
        return
    end

    if IS_DEBUG then
        GmModel.Instance:ReciveData(cmd, result)
    end
    local status, errInfo = _pcall(handler, result)
    if not status then
        LogError("处理协议：" .. tostring(cmd) .. "的回调函数时发生异常:" .. tostring(errInfo))
    end
end

function ProtocalReceiver:ParseTableData(protocal, tb)
    for _, v in _ipairs(protocal) do
        self.lastParseKey = v.name
        tb[v.name] = self:Parse(v)
    end
end

function ProtocalReceiver:Parse(field)
    local protocolDataType = field.type
    if protocolDataType == ConnectionEnum.ProtocolDataType.Array then
        local temp = {}
        local length = self:ReadUShort()
        for i = 1, length do
            local subTb = {}
            for _, subField in ipairs(field.fields) do
                self.lastParseKey = subField.name
                subTb[subField.name] = self:Parse(subField)
            end
            temp[i] = subTb
        end
        return temp
    elseif protocolDataType == ConnectionEnum.ProtocolDataType.Byte then
        return self:ReadByte()
    elseif protocolDataType == ConnectionEnum.ProtocolDataType.UByte then
        return self:ReadUByte()
    elseif protocolDataType == ConnectionEnum.ProtocolDataType.Short then
        return self:ReadShort()
    elseif protocolDataType == ConnectionEnum.ProtocolDataType.UShort then
        return self:ReadUShort()
    elseif protocolDataType == ConnectionEnum.ProtocolDataType.Int then
        return self:ReadInt()
    elseif protocolDataType == ConnectionEnum.ProtocolDataType.UInt then
        return self:ReadUInt()
    elseif protocolDataType == ConnectionEnum.ProtocolDataType.Long then
        return self:ReadLong()
    elseif protocolDataType == ConnectionEnum.ProtocolDataType.ULong then
        return self:ReadULong()
    elseif protocolDataType == ConnectionEnum.ProtocolDataType.String then
        return self:ReadString()
    else
        LogError(string.format("未处理类型:%s", protocolDataType))
        return
    end
end

function ProtocalReceiver:Read(fmt, byteNum)
    self:CheckAvailable()
    local result = _string_unpack(fmt, self.buffString, self.buffIndex)
    self.buffIndex = self.buffIndex + byteNum
    return result
end

function ProtocalReceiver:ReadByte()
    return self:Read("<b", 1)
end

function ProtocalReceiver:ReadUByte()
    return self:Read("<B", 1)
end

function ProtocalReceiver:ReadShort()
    return self:Read("<h", 2)
end

function ProtocalReceiver:ReadUShort()
    return self:Read("<H", 2)
end

function ProtocalReceiver:ReadInt()
    return self:Read("<i", 4)
end

function ProtocalReceiver:ReadUInt()
    return self:Read("<I", 4)
end

function ProtocalReceiver:ReadLong()
    return self:Read("<l", 8)
end

function ProtocalReceiver:ReadULong()
    return self:Read("<L", 8)
end

function ProtocalReceiver:ReadString()
    self:CheckAvailable()
    local length = self:ReadUShort()
    if length == 0 then
        return string.Empty
    end
    local result = _string_sub(self.buffString, self.buffIndex, self.buffIndex + length - 1)
    self.buffIndex = self.buffIndex + length
    return result
end

function ProtocalReceiver:CheckAvailable()
    assert(#self.buffString >= self.buffIndex,
        _string_format("End of file was encountered. pos: %d, len: %d.", self.buffIndex, #self.buffString))
end
