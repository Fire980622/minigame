-- 事件系统
local _table_insert = table.insert
local _pairs = pairs
local _xpcall = xpcall
local _assert = assert

EventLib = EventLib or BaseClass()
local EventLib = EventLib
local os_clock = os.clock
function EventLib:__init(EventName, checrepeat)
    self.handlers = nil
    self.oncehandlers = nil
    self.args = nil
    self.EventName = EventName or "<Unknown Event>"
    self.firedelay = nil
    self.notcheck = not checrepeat
    self.handlerList = {}
    self.errfunction = function(errinfo)
        if self.EventName ~= nil then
            LogError("EventLib:Fire出错了[" .. self.EventName .. "]:" .. tostring(errinfo).."\n"..debug.traceback())
        else
            LogError("EventLib:Fire出错了" .. tostring(errinfo).."\n"..debug.traceback())
        end
    end
end

function EventLib:AddListener(handler)
    self:Add(handler)
end

function EventLib:AddOnceListener(handler)
    self:AddOnce(handler)
end

function EventLib:Add(handler)
    _assert(type(handler) == "function", "非法事件")
    if self.handlers == nil then
        self.handlers = {}
    end
    self.handlers[handler] = true
    -- for k,v in _pairs(self.handlers) do
    --     if v == handler then
    --         -- LogError("重复添加事件监听"..debug.traceback())
    --         return
    --     end
    -- end
    -- _table_insert(self.handlers, handler)
end
-- 添加一次性监听
function EventLib:AddOnce(handler)
    _assert(type(handler) == "function", "非法事件")
    if self.oncehandlers == nil then
        self.oncehandlers = {}
    end
    self.oncehandlers[handler] = true
    -- _table_insert(self.oncehandlers, handler)
end

function EventLib:ClearOnce()
    self.oncehandlers = {}
end

function EventLib:RemoveListener(handler)
    self:Remove(handler)
end
function EventLib:Remove(handler)
    -- _assert(type(handler) == "function", "非法事件")
    if not handler then
        -- self.handlers = nil
    else
        if self.handlers then
            self.handlers[handler] = nil
        end
        if self.oncehandlers then
            self.oncehandlers[handler] = nil
        end
    end
end

function EventLib:RemoveAll()
    self.handlers = nil
end

local checktime = 0.033
EventLib.usetime = 0
EventLib.cache = {}
-- 应该只有一个主线程，就不考虑多线程问题了
function EventLib:Fire(args1, args2, args3, args4, args5)
    -- if EventLib.usetime > checktime then
    --     -- hzf(Time.frameCount.."fire超时了", EventLib.usetime)
    --     _table_insert(EventLib.cache, {self, args1, args2, args3, args4})
    --     return
    -- end
    -- local begin = os_clock()
    if not self.notcheck then
        if self.firedelay then
            TimerManager.Delete(self.firedelay)
            self.firedelay = false
        end
        self.firedelay = TimerManager.Add(1, function()
            self.firedelay = false
            self:__innerFire(args1, args2, args3, args4, args5)
        end)
    else
        -- self.firetimes = self.firetimes  or 0
        -- if Time.time == self.lasttick then
        --     self.firetimes = self.firetimes + 1
        --     hzf("FFFFFFFFFFFFFFFFFFFFF = "..self.EventName, self.firetimes)
        -- else
        --     self.lasttick = Time.time
        --     self.firetimes = 0
        -- end
        -- self.firetimes = self.firetimes + 1
        self:__innerFire(args1, args2, args3, args4, args5)
    end
end

if ctx.IsDebug then
    function EventLib:__innerFire(args1, args2, args3, args4, args5)
        if self.handlers ~= nil or self.oncehandlers ~= nil then
            local list = {}
            if self.handlers then
                for handler, _ in _pairs(self.handlers) do
                    _table_insert(list, handler)
                end
            end
            if self.oncehandlers then
                for handler, _ in _pairs(self.oncehandlers) do
                    _table_insert(list, handler)
                end
                -- 编译环境下也要清除一次监听
                self.oncehandlers = nil
            end
            for k, func in _pairs(list) do
                _xpcall(func, self.errfunction, args1, args2, args3, args4, args5)
                list[k] = nil
            end
        end
    end
else
    function EventLib:__innerFire(args1, args2, args3, args4, args5)
        if self.handlers ~= nil or self.oncehandlers ~= nil then
            local list = {}
            if self.handlers then
                for handler, _ in _pairs(self.handlers) do
                    _table_insert(list, handler)
                end
            end
            if self.oncehandlers then
                for handler, _ in _pairs(self.oncehandlers) do
                    _table_insert(list, handler)
                end
            end
            if self.EventName ~= event_name.frame_update then
                local cor = coroutine.create(function()
                    local t = os_clock()
                    for k, func in _pairs(list) do
                        -- local info = debug.getinfo(func,"S")
                        -- local nname = info.source..info.linedefined
                        -- Profiling.Profiler.BeginSample(nname)
                        if (self.handlers and self.handlers[func]) or (self.oncehandlers and self.oncehandlers[func]) then
                            _xpcall(func, self.errfunction, args1, args2, args3, args4, args5)
                            if self.oncehandlers and self.oncehandlers[func] then
                                self.oncehandlers[func] = nil
                            end
                        end
                        -- Profiling.Profiler.EndSample(nname)
                        list[k] = nil
                        if os_clock() - t > 0.01 then
                            coroutine.yield()
                            t = os_clock()
                        end
                    end
                end)
                coroutine.resume(cor)
                if self.EventName and coroutine.status(cor) ~= "dead" then
                    _table_insert(EventLib.cache, cor)
                end
            else
                for k, func in _pairs(list) do
                    _xpcall(func, self.errfunction, args1, args2, args3, args4, args5)
                    list[k] = nil
                end
            end

        end
    end
end

function EventLib:Destroy()
    self:RemoveAll()
    for k, v in _pairs(self) do
        self[k] = nil
    end
end

function EventLib:__delete()
    self:Destroy()
end

local checkrepeat_event = {
    -- [event_name.backpack_equip_add] = true,
    -- [event_name.backpack_equip_delete] = true,
    -- [event_name.role_attr_change] = true,
    -- [event_name.role_assets_change] = true,
    -- [event_name.socket_disconnect] = true,
    -- [event_name.role_vice_update] = true,
    -- [event_name.agenda_activity_can_get_reward] = true,
    -- [event_name.mainui_mid_change] = true,
    -- [event_name.doingdata_update] = true,
    -- [event_name.skill_equip_change] = true,
    -- [event_name.pet_scene_info_update] = true,
    -- [event_name.quest_update] = true,
    -- [event_name.role_skill_point] = true,
}
-- UnityEvent.RemoveListener在某些情况下不起作用
-- 所以增加了该方式，handler为lua function
EventMgr = EventMgr or BaseClass()
function EventMgr:__init()
    EventMgr.Instance = self
    self.countFire = {}
    self.events = {}
    self.delaytimer = {}
end

function EventMgr:AddListener(event, handler)
    if not event or type(event) ~= "string" then
        LogError("事件名要为字符串")
    end

    if not handler or type(handler) ~= "function" then
        LogError("handler必须是一个函数,事件名:"..event)
    end

    if not self.events[event] then
        self.events[event] = EventLib.New(event)
    end
    self.events[event]:Add(handler)
end
-- 添加一次性监听
function EventMgr:AddOnceListener(event, handler)
    if not event or type(event) ~= "string" then
        LogError("事件名要为字符串")
    end

    if not handler or type(handler) ~= "function" then
        LogError("handler为是一个函数,事件名:"..event)
    end

    if not self.events[event] then
        self.events[event] = EventLib.New(event)
    end
    self.events[event]:AddOnce(handler)
end

function EventMgr:RemoveListener(event, handler)
    if self.events[event] then
        self.events[event]:Remove(handler)
    end
end
function EventMgr:RemoveAllListener(event)
    if self.events[event] then
        self.events[event]:RemoveAll()
    end
end

function EventMgr:Fire(event, args1, args2, args3, args4, args5)
    -- Debug.Log(event)
    if self.events[event] then
        if self.countFire[event] == nil then
            self.countFire[event] = 0
        end
        self.countFire[event] = self.countFire[event] + 1
        -- 场景跳转中角色event变化先不要发送
        if checkrepeat_event[event] or (SceneJumpIng and event == event_name.role_event_change) then
            if self.delaytimer[event] ~= nil then
                return
            end
            self.delaytimer[event] = TimerManager.Add(300 ,function()
                self.delaytimer[event] = nil
                self.events[event]:Fire(args1, args2, args3, args4, args5)
            end)
        else
            self.events[event]:Fire(args1, args2, args3, args4, args5)
        end
    end
end

local table_remove = table.remove
function EventMgr:FireCache()
-- 应该只有一个主线程，就不考虑多线程问题了
    -- while EventLib.usetime < checktime do
    --     local data = table_remove(EventLib.cache)
    --     if data then
    --         data[1]:Fire(data[2], data[3], data[4], data[5])
    --     else
    --         -- hzf("完了哈")
    --         return
    --     end
    -- end
    local clearflag = 0
    for k,v in pairs(EventLib.cache) do
        coroutine.resume(v)
        if coroutine.status(v) == "dead" then
            clearflag = clearflag + 1
        end
    end
    if clearflag > 0 then
        local temp = {}
        for k,v in pairs(EventLib.cache) do
            if coroutine.status(v) ~= "dead" then
                _table_insert(temp, v)
            end
        end
        EventLib.cache = temp
    end
end