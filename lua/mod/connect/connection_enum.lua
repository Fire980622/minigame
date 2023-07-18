ConnectionEnum = ConnectionEnum or {}

ConnectionEnum.State = {
    Idle = 1,   --空闲状态
    Connecting = 2, --连接中
    Connected = 3,  --已连接
}

ConnectionEnum.ProtocolDataType = {
    Array = "array",
    UByte = "uint8",
    Byte = "int8",
    Short = "int16",
    UShort = "uint16",
    Int = "int32",
    UInt = "uint32",
    Long = "int64",
    ULong = "uint64",
    String = "string",
}

ConnectionEnum.CmdByteNum = 4   --协议号占用的字节数
ConnectionEnum.ConnectMaxTryNum = 20