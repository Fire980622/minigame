--所有的服务端客户端坐标转换，都在Send和On处理

--客户端坐标转服务端坐标
--ClientToServerPosition的缩写
function CSPosition(value)
    return math.floor(value * 10)
end

--服务端坐标转客户端坐标
--所有的距离单位，包括长度，速度
--ServerToClientPosition的缩写
function SCPosition(value)
    return value * 0.1
end


--通用服务端数据转客户端数据
--所有的距离单位，包括长度，速度
function SCCommon(tb, name)
    tb[name] = SCPosition(tb[name])
end

--服务端时间戳转为客户端时间戳
function SCTime(value)
    return value * 0.001
end

function SCTime1(tb, name)
    tb[name] = SCTime(tb[name])
end

-- tb = {
--     pos_x
--     pos_y
--     pos_z
-- }
SCPosition1 = function(tb)
    tb.pos_x = SCPosition(tb.pos_x)
    --TODO 过渡写法
    if tb.pos_y then
        tb.pos_y = SCPosition(tb.pos_y)
    end
    --TODO 过渡写法
    if tb.pos_z then
        tb.pos_z = SCPosition(tb.pos_z)
    end
end

-- tb = {
--     {pos_x, pos_y}
-- }
SCPosition2 = function(tb)
    for i = 1, #tb do
        SCPosition1(tb[i])
    end
end

-- tb = {
--     x
--     y
-- }
SCPosition3 = function(tb)
    tb.x = SCPosition(tb.x)
    tb.z = SCPosition(tb.z)
end

-- tb = {
--      {x, y}
-- }
SCPosition4 = function(tb)
    for i = 1, #tb do
        local item = tb[i]
        item.x = SCPosition(item.x)
        --TODO 过渡写法
        if item.y then
            item.y = SCPosition(item.y)
            item.z = item.y
        elseif item.z then
            item.z = SCPosition(item.z)
        end
    end
end

-- tb = {
--     ori_x
--     ori_y
-- }
SCPosition5 = function(tb)
    tb.ori_x = SCPosition(tb.ori_x)
    tb.ori_z = SCPosition(tb.ori_y)
end

-- tb = {
--     end_pos_x
--     end_pos_z
-- }
SCPosition6 = function(tb)
    tb.end_pos_x = SCPosition(tb.end_pos_x)
    tb.end_pos_z = SCPosition(tb.end_pos_z)
end

-- tb = {
--     skill_x
--     skill_y
-- }
SCPosition7 = function(tb)
    tb.skill_x = SCPosition(tb.skill_x)
    tb.skill_z = SCPosition(tb.skill_z)
end

-- tb = {
--     obj_x
--     obj_z
-- }
SCPosition8 = function(tb)
    tb.obj_x = SCPosition(tb.obj_x)
    tb.obj_z = SCPosition(tb.obj_z)
end

-- tb = {
    -- {obj_x,  obj_z}
-- }
SCPosition9 = function(tb)
    for i = 1, #tb do
        SCPosition8(tb[i])
    end
end