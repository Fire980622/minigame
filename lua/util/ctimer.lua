CTimer = CTimer or BaseClass()
local timerid = 1
local errFunc = function(err) LogError("定时器报错停止运行: ".. tostring(err).."\n"..debug.traceback()) end
function CTimer:__init()
    --模式
    self._count = 0
    --定时器时长
    self._duration = 0
    --剩余时间
    self._leftTime = 0
    --定时器委托
    self._callback = nil
    --参数列表
    self._args = nil
    --是否不被Time.scale影响
    self._unScale = false
    --启动时间
    self.initTime = 0
    self.debug_id = nil
    self.iter = nil
    self.ID = timerid + 1
    timerid = timerid + 1
    self.runid = 0
end

function CTimer:Duration()
        return self._duration
end

function CTimer:SetDuration(val)
    self._duration = val or 0.2
end
    -- /// <summary>
    -- /// 初始化函数
    -- /// </summary>
function CTimer:Initialize(count, duration, unScale, handler,...)
    if count== nil then
        LogError("兄die,定时器参数传递错误,赶紧改改")
        return
    end
    if IS_DEBUG then
        self.info = debug.traceback()
    end
    self.runid = self.runid + 1
    self.initTime = ModuleManager.realtimeSinceStartup
    self._count = count
    self._duration = duration
    self._unScale = unScale
    if count < 1 then
        self._leftTime = 0
    else
        self._leftTime = duration
    end
    self._callback = handler
    -- local arg = {...}
    -- self._args = arg
    return MathBit.orOp(self.ID, MathBit.lShiftOp(self.runid, 16))
end

    -- /// <summary>
    -- /// 运行事件
    -- /// </summary>
function CTimer:Run(delta)
        -- print("-------------------------------------------CTimer:Run1")

        if (nil == self._callback) then
            return false
        end
        local zfun = self._callback
            -- print("-------------------------------------------CTimer:Run2")
        if (self._unScale) then
                -- print("-------------------------------------------CTimer:Run3")
            if (self._leftTime > ModuleManager.realtimeSinceStartup - self.initTime) then
                return true
            end
        else
                -- print("-------------------------------------------CTimer:Run4")
            self._leftTime = self._leftTime - delta
            if (self._leftTime > 0) then
                return true
            end
        end
        -- print("-------------------------------------------CTimer:Run5")
        if (self._count >= 0) then
            self._count = self._count - 1
            if (self._count <= 0) then
            -- print("-------------------------------------------CTimer:Run6")
                    self._callback = nil
                    xpcall(zfun, errFunc)
                    -- if UNITY_EDITOR ==true then
                    -- if (debug_id == "hearCTimer")
                    -- {
                    --     Debug.LogWarning(StrUtilText("时间过短：") + (ModuleManager.realtimeSinceStartup - initTime) + "," + _duration);
                    -- }
                    -- end
                    --// 通知删除定时器
                    return false
            end
        end
        -- local result = zfun(unpack(self._args))
        local result = true
        local status, err = xpcall(zfun, errFunc)
        if status then
            result = err
        else
            result = false
        end
        self._leftTime = self._leftTime  + self._duration
        return result ~= false
end

    -- /// <summary>
    -- /// 重置
    -- /// </summary>
function CTimer:Reset()
    self.runid = self.runid + 1
    self._count = 0
    self._duration = 0
    self._leftTime = 0
    self._unScale = false
    self._callback = nil
    self._args = nil
    self.iter = nil
end

    -- /// <summary>
    -- /// 释放
    -- /// </summary>
function CTimer:Dispose()
    self:Reset()
end

function CTimer:GetUid()
    return MathBit.orOp(self.ID, MathBit.lShiftOp(self.runid, 16))
end