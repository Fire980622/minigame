TimerManager = TimerManager or BaseClass()

-- require "util/ctimer"
local list = require "util/list"

local TimerList = {}
function TimerManager.getInstance()
    if TimerManager.Instance == nil then
        TimerManager.Instance = TimerManager.New()
    end
    return TimerManager.Instance
end

function TimerManager:__init( )
    if TimerManager.Instance then
        -- LogError("不可以对单例对象重复实例化"..debug.traceback())
        return
    end
    TimerManager.Instance = self
    self.m_TimerList = list:new()  --{value = v}
    self.updateTime = 0
    self.lastUpdateTime = 0
    self.m_curTimer = nil
    self.effectSimulate = {}
    self.animationSimulate = {}

    self.poolhead = 0
    self.poolList = {}

end

    -- /// <summary>
    -- /// 更新定时器
    -- /// </summary>
local timerid = 0
local runid = 0
function TimerManager:Update(deltaTime)
    self.m_curTimer =self.m_TimerList:next()

    while (nil ~= self.m_curTimer) do
        local ztimer = self.m_curTimer.value
        self.m_curTimer = self.m_TimerList:next(self.m_curTimer)
        timerid = ztimer.ID
        runid = ztimer.runid
        local result = ztimer:Run(deltaTime)
        if (result == false) then -- 删除
            -- self:RemoveTimer(ztimer)
            self:RemoveTimerID(timerid, runid)
        end
    end
    if Time.timeScale ~= 1 then
        for k,v in pairs(self.effectSimulate) do
            if not UtilsBase.IsNull(v.go) then
                for k,v in pairs(v.coms) do
                    v:Simulate(Time.unscaledDeltaTime, true, false);
                end
            else
                self.effectSimulate[k] = nil
            end
        end
    end
end

    -- /// <summary>
    -- /// 增加定时器
    -- /// <param name="unScale">True:不受Timescale影响
    -- /// false:收到TimeScale影响</param>
    -- /// </summary>
function TimerManager:AddOnceTimer(duration,isUnScale,handler, ...)
    return self:Internal_AddTimer(1, duration, isUnScale,handler,...)
end

    -- /// <summary>
    -- /// 增加计数定时器
    -- /// <param name="isUnScale">True:不受Time.scale影响,false相反</param>
    -- /// </summary>
function TimerManager:AddCountTimer(duration, isUnScale, handler, count, ...)
    if count == nil then
        LogError(StrUtilText(_T("参数错误:count = nil ")))
        return
    end
    return self:Internal_AddTimer(count, duration, isUnScale, handler,...)
end

    -- /// <summary>
    -- /// 增加持续定时器
    -- /// True:不受Timescale影响
    -- /// false:收到Timescale影响
    -- /// </summary>
function TimerManager:AddRepeatTimer(duration, isUnScale, handler, ...)
    -- print("添加循环计时器："..tostring(duration).."  "..tostring(isUnScale).."  "..tostring(handler))
    return self:Internal_AddTimer(-1, duration, isUnScale, handler,...)
end

function TimerManager:ChangeDuration(timerid, duration)
    if timerid == nil then
        return
    end
    local realid = MathBit.andOp(timerid,0xFFFF)
    local countid = MathBit.rShiftOp(timerid,16)
    if TimerList[realid] ~= nil and TimerList[realid].runid == countid then
        TimerList[realid]:SetDuration(duration / 1000)
    end
end

function TimerManager:RemoveTimer(timer)
    if (timer == nil or timer.iter == nil) then
        return
    end
    self.m_TimerList:remove(timer.iter)  --- 根据节点移除
    timer:Dispose()
    self:ReturnObj(timer)
end

-- 通过id删除
function TimerManager:RemoveTimerID(id, runid)
    if TimerList[id] ~= nil and TimerList[id].runid == runid then
        TimerManager.getInstance():RemoveTimer(TimerList[id])
    end
end
    -- /// <summary>
    -- /// 从对象池创建时间对象
    -- /// </summary>
function TimerManager:CreateObj()
    return self:GetObj()
        -- return CTimer.New()
end

    -- /// <summary>
    -- /// 增加定时器
    -- /// <param name="isUnScale">是否不被Time.scale影响</param>
    -- /// </summary>
function TimerManager:Internal_AddTimer(count, duration, isUnScale, handler,...)
    if handler == nil then
        LogError("handler is nil")
    end
    if (duration < 0) then
        return nil
    end

    local timer = self:CreateObj()
    if (timer == nil) then
        return nil
    end
    -- print("-----------------------(TimerManager:Internal_AddTimer)",duration)
    local uid = timer:Initialize(count, duration, isUnScale, handler,...)
    timer.iter = self.m_TimerList:unshift(timer)  --返回节点
    return uid
end

    -- /// <summary>
    -- /// 是否在运行
    -- /// </summary>
function TimerManager:IsRunning(timer)
        -- local timerNode = TimerManager.m_TimerList:shift()
        -- while (nil ~= timerNode) do
        --     local curTimerNode = timerNode
        --     timerNode = timerNode._next

        --     if (curTimerNode.Value == timer) then
        --         return true
        --     end

        -- end
        -- return false
        local zvar = self.m_TimerList:find(timer)
        if zvar ~= nil then
            return true
        end
        return false
end
local lasterror = 0
function TimerManager.Add(...)
    if IS_DEBUG then
        if TimerManager.Instance.m_TimerList.length > 100 then
            if UtilsBase.ServerTime() - lasterror > 3 then
                TimerManager.CheckTimerError()
                if ctx.Editor then
                    LogError("激活的计时器过多请确认是否正常,如果用了《GM命令》或者《当前人过多》导致则忽略\n"..tostring(TimerManager.Instance.m_TimerList.length), true)
                end
                lasterror = UtilsBase.ServerTime()
            end
            -- return
        end
    end
    local num_args = select("#", ...)

    if num_args == 2 then
        return TimerManager.getInstance():AddOnceTimer(select(1, ...)/1000, true, select(2, ...))
    elseif num_args == 3 then
        return TimerManager.getInstance():AddRepeatTimer(select(2, ...)/1000, true, select(3, ...))
    else
        LogError("Timer参数错误")
    end
end


function TimerManager.AddScale(...)
    local num_args = select("#", ...)
    -- for i = 1, num_args do
    --     local arg = select(i, ...)
    --     print(i, arg)
    -- end
    -- print("参数个数"..tostring(num_args))
    if num_args == 2 then
        return TimerManager.getInstance():AddOnceTimer(select(1, ...)/1000, false, select(2, ...))
    elseif num_args == 3 then
        return TimerManager.getInstance():AddRepeatTimer(select(2, ...)/1000, false, select(3, ...))
    else
        LogError("Timer参数错误")
    end
end


function TimerManager.Delete(timerid)
    if timerid == nil then
        return
    end
    local realid = MathBit.andOp(timerid,0xFFFF)
    local countid = MathBit.rShiftOp(timerid,16)
    if TimerList[realid] ~= nil and TimerList[realid].runid == countid then
        TimerManager.getInstance():RemoveTimer(TimerList[realid])
    end
end


-- 让粒子效果不受timescale影响
function TimerManager.AddUnScaleEffect(effectobj)
    if not UtilsBase.IsNull(effectobj) then
        local rec = {}
        local id = effectobj:GetInstanceID()
        local particals = effectobj:GetComponentsInChildren(typeof(ParticleSystem), true)
        local coms = {}
        local num = particals.Length
        for i = 0, num - 1 do
            coms[i] = particals[i]
        end
        TimerManager.getInstance().effectSimulate[id] = {go = effectobj, coms = coms}
    end
end

function TimerManager.AddUnScaleAnimation(animation)
    if not UtilsBase.IsNull(animation) then
        local id = animation:GetInstanceID()
        self.animationSimulate[id] = animation
    end
--     AnimationState animState = animation[clipName]; // 当前动画状态

-- curTime = ModuleManager.realtimeSinceStartup; // 当前真实时间
-- deltaTime = curTime - lastFrameTime; // 此帧与上一帧的时间间隔
-- lastFrameTime = curTime; // 记录此帧时间，下一帧用
-- progressTime += deltaTime; // 动画已播放时间
-- animState.normalizedTime = progressTime / currState.length; // 动画规范化时间[0-1]
-- animation.Sample(); // 在当前状态对动画进行采样，当你想显式设置动画状态并且对它取样的时候使用
end

function TimerManager:GetObj()
    -- if self.poolhead <= 0 then
    --     hzf("创建计时器")
    --     local timer = CTimer.New()
    --     TimerList[timer.ID] = timer
    --     return timer
    -- else
    --     self.poolhead = self.poolhead - 1
    --     if self.poolList[self.poolhead] ~= nil then
    --         hzf("OK拿到缓存计时器", self.poolhead)
    --         return self.poolList[self.poolhead]
    --     else
    --         hzf("No拿到空的的缓存计时器！！！！！", self.poolhead)
    --         return nil
    --     end
    -- end
    for k,v in pairs(TimerList) do
        if v.iter == nil then
            -- hzf("取到一个缓存池的￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥￥")
            return v
        end
    end
    local timer = CTimer.New()
    TimerList[timer.ID] = timer
    return timer
end

function TimerManager:ReturnObj(timer)
    -- if timer == nil then
    --     hzf("回收空的计时器#####", self.poolhead)
    --     return
    -- end
    -- self.poolList[self.poolhead+1] = timer
    -- self.poolhead = self.poolhead + 1
    -- hzf("回收计时器", self.poolhead)
    -- hzf("计时器列表长度", #TimerList)
end

function TimerManager.GetPoolLength()
    return #TimerList
end

function TimerManager.AddValChange(from, to, time, endcall, tweentype, changecall)
    local begin = UtilsBase.FloatTime
    local changeval = to - from
    local timerid = TimerManager.Add(0, 20, function()
        local dura = (UtilsBase.FloatTime - begin)/time
        if changecall then
            changecall(from + math.min(1, dura) * changeval)
        end
        if dura >= 1 then
            if endcall then
                endcall()
            end
            return false
        end
    end)
    return timerid
end

function TimerManager.CheckTimerError()
    TimerManager.getInstance().m_curTimer =TimerManager.getInstance().m_TimerList:next() --
    local temp1 = {}
    while (nil ~= TimerManager.getInstance().m_curTimer) do
        local ztimer = TimerManager.getInstance().m_curTimer.value --
        TimerManager.getInstance().m_curTimer = TimerManager.getInstance().m_TimerList:next(TimerManager.getInstance().m_curTimer)
        temp1[ztimer.info] = temp1[ztimer.info] or 0
        temp1[ztimer.info] = temp1[ztimer.info] + 1
    end
    local temp2 = {}
    for k,v in pairs(temp1) do
        table.insert(temp2, {num = v, info = k})
    end
    table.sort(temp2, function(a, b)
        return a.num > b.num
    end)
    for i=1,10 do
        -- Log.Info(tostring(temp2[i].num).."\n"..temp2[i].info)
    end
end


LuaTimer = {}
setmetatable(LuaTimer, TimerManager)