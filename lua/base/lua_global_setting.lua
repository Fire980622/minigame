local parentG = {}
-- if not ctx.Editor then
-- 数据表跟其它的不一样
Config = Config or {}
local dataG = {}
local __Dataoaded = {}
setmetatable(Config, dataG)
dataG.__index = function(t, k)
    local requireName = ClzMapping[k]
    if requireName and not __Dataoaded[requireName] then
        __Dataoaded[requireName] = true
        if require (ClzMapping[k]) then
            return Config[k]
        else
            return false
        end
    end
end

local __ModuleLoaded = {}
setmetatable(_G, parentG)
parentG.__index = function(t, k)
    local requireName = ClzMapping[k]
    if requireName and not __ModuleLoaded[requireName] then
        __ModuleLoaded[requireName] = true
        if require (ClzMapping[k]) then
            return _G[k]
        else
            return false
        end
    end
end
-- end

