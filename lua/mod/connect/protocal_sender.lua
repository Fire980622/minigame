ProtocalSender = ProtocalSender or BaseClass()

local _table_insert = table.insert
local _table_concat = table.concat
local _string_pack = string.pack
local _pcall = pcall
local _ipairs = ipairs

function ProtocalSender:__init(protocolDict)
    self.protocolDict = protocolDict
    self.buffList = {}
end

function ProtocalSender:__delete()
end

function ProtocalSender:Clear()
    self.buffList = {}
end

function ProtocalSender:Send(cmd, data)
    local protocol = self.protocolDict[cmd]
    if protocol == nil then
        LogError(string.format("发送协议：%s出错, 协议描述不存在", cmd))
        return
    end
    self:Clear()
    for _, field in _ipairs(protocol) do
        local status = _pcall(ProtocalSender.Parse, self, field, data[field.name])
        if not status then
            LogError(string.format("发送协议：%s出错, 检查协议字段：%s, 数据：%s", cmd, field.name, UtilsBase.serializeForSave(data)))
            return
        end
    end
    local protocolContent = self:GetBuffString()
    local headContent = _string_pack("<I", #protocolContent + 2) .. _string_pack("<H", cmd)
    return headContent .. protocolContent
end

function ProtocalSender:Parse(field, val)
    local protocolDataType = field.type
    if protocolDataType == ConnectionEnum.ProtocolDataType.Array then
        local length = #val
        self:WriteUShort(length)
        for i = 1, length do
            for _, sub in ipairs(field.fields) do
                self:Parse(sub, val[i][sub.name])
            end
        end
    else
        if protocolDataType == ConnectionEnum.ProtocolDataType.Byte then
            return self:WriteByte(val)
        elseif protocolDataType == ConnectionEnum.ProtocolDataType.UByte then
            return self:WriteUByte(val)
        elseif protocolDataType == ConnectionEnum.ProtocolDataType.Short then
            return self:WriteShort(val)
        elseif protocolDataType == ConnectionEnum.ProtocolDataType.UShort then
            return self:WriteUShort(val)
        elseif protocolDataType == ConnectionEnum.ProtocolDataType.Int then
            return self:WriteInt(val)
        elseif protocolDataType == ConnectionEnum.ProtocolDataType.UInt then
            return self:WriteUInt(val)
        elseif protocolDataType == ConnectionEnum.ProtocolDataType.Long then
            return self:WriteLong(val)
        elseif protocolDataType == ConnectionEnum.ProtocolDataType.ULong then
            return self:WriteULong(val)
        elseif protocolDataType == ConnectionEnum.ProtocolDataType.String then
            return self:WriteString(val)
        else
            LogError(string.format("未处理类型:%s", block.type))
        end
    end
end

function ProtocalSender:WriteByte(val)
    _table_insert(self.buffList, _string_pack("<b", val))
end

function ProtocalSender:WriteUByte(val)
    _table_insert(self.buffList, _string_pack("<B", val))
end

function ProtocalSender:WriteShort(val)
    _table_insert(self.buffList, _string_pack("<h", val))
end

function ProtocalSender:WriteUShort(val)
    _table_insert(self.buffList, _string_pack("<H", val))
end

function ProtocalSender:WriteInt(val)
    _table_insert(self.buffList, _string_pack("<i", val))
end

function ProtocalSender:WriteUInt(val)
    _table_insert(self.buffList, _string_pack("<I", val))
end

function ProtocalSender:WriteLong(val)
    _table_insert(self.buffList, _string_pack("<i8", val))
end

function ProtocalSender:WriteULong(val)
    _table_insert(self.buffList, _string_pack("<I8", val))
end

function ProtocalSender:WriteString(val)
    self:WriteUShort(#val)
    _table_insert(self.buffList, val)
end

function ProtocalSender:GetBuffString()
    return _table_concat(self.buffList)
end
