UtilsBase = UtilsBase or {}

UtilsBase.Time = os.time()
UtilsBase.FloatTime = os.time()
UtilsBase.ClientSyncTime = os.clock()

local _string_format = string.format
local _os_time = os.time
local _os_date = os.date
local _tostring = tostring
local _tonumber = tonumber
local _type = type
local _ipairs = ipairs
local _pairs = pairs
local _next = next
local _table_insert = table.insert
local _table_concat = table.concat
local _math_ceil = math.ceil
local _math_floor = math.floor
local _math_abs = math.abs

function UtilsBase.ServerTime()
    return math.round(UtilsBase.FloatTime)
end

function UtilsBase.ZeroTimeStamp(now)
    if now == nil then now = UtilsBase.ServerTime() end
    local year,month,day = TimeHelper.GetYMD(now)
    local zero_stamp = _os_time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
    return zero_stamp
end

UtilsBase.INT32_MAX = 2147483647
UtilsBase.INT32_MIN = -2147483648

-- 剑骑普攻动作
UtilsBase.QishiAttackActionName = {
    ["attack4101"] = true
    ,["attack4102"] = true
    ,["attack4103"] = true
    ,["attack4001"] = true
    ,["attack4002"] = true
    ,["attack4003"] = true
}

-- 复制table
function UtilsBase.copytab(st, keytab)
    local keylist
    if keytab == nil then
        keylist = {}
    else
        keylist = keytab
    end
    if st == nil then return nil end
    if _type(st) ~= "table" then
        return st
    end
    local tab = {}
    for k, v in _pairs(st or {}) do
        if _type(v) ~= "table" then
            tab[k] = v
        elseif keylist[v] == nil then
            keylist[v] = true
            tab[k] = UtilsBase.copytab(v, keylist)
        end
    end
    return tab
end

-- 覆盖table属性 把tab2的所有内容赋值给tab1
function UtilsBase.covertab(tab1, tab2)
    for k, v in _pairs(tab2) do
        tab1[k] = v
    end
    return tab1
end

function UtilsBase.mergeTable(...)
    local arg = {...}
    local result = {}
    for i, v in _ipairs(arg) do
        for _, vv in _ipairs(v) do
            _table_insert(result, vv)
        end
    end
    return result
end

-- 代替lua的sort，以避免出现不稳定排序问题
function UtilsBase.BubbleSort(templist, sortFuc)
    local list = {}
    for k, v in _pairs(templist) do
        _table_insert(list, v)
    end
    local tempVal = true
    for m=#list-1,1,-1 do
        tempVal = true
        for i=#list-1,1,-1 do
            local a = list[i]
            local b = list[i+1]
            local sortBoo = sortFuc(a, b)
            if sortBoo == false then
                list[i], list[i+1] = list[i+1], list[i]
                tempVal = false
            end
        end
        if tempVal then break end
    end
    return list
end

function UtilsBase.Platform()
    return Application_platform
end

function UtilsBase.PlatformStr()
    if Application_platform == RuntimePlatform.IPhonePlayer then
        return "IPhonePlayer"
    elseif Application_platform == RuntimePlatform.Android then
        return "Android"
    elseif Application_platform == RuntimePlatform.WindowsPlayer
        or Application_platform == RuntimePlatform.WindowsEditor
        then
        return "WindowsPlayer"
    else
        return nil
    end
end

function UtilsBase.IsIPhonePlayer()
    return Application_platform == RuntimePlatform.IPhonePlayer
end

-- 序列化
-- 序列化时只需传入obj的值，其它保持nil
function UtilsBase.serialize(obj, name, newline, depth, keytab)
    local keylist
    if keytab == nil then
        keylist = {}
    else
        keylist = keytab
    end
    local space = newline and "    " or ""
    newline = newline and true
    depth = depth or 0

    local tmp = string.rep(space, depth)
    local more = depth < 3
    if name then
        if _type(name) == "number" then
            tmp = tmp .. "[" .. name .. "] = "
        elseif _type(name) == "string" then
            tmp = tmp .. name .. " = "
        else
            tmp = tmp .. _tostring(name) .. " = "
        end
    end
    if _type(obj) == "table" and string.find(tostring(obj),"table") and keylist[obj] == nil then
            keylist[obj] = true
            local mt = getmetatable(obj)
            if mt and mt.__typename ~= nil then
                tmp = tmp..tostring(obj)
            elseif mt ~= nil and mt.DeleteMe and not more then
                tmp = tmp .. [["【lua_class】:"]]..tostring(obj)
            else
                tmp = tmp .. "{" .. (newline and "\n" or "")

                for k, v in _pairs(obj) do
                    tmp =  tmp .. UtilsBase.serialize(v, k, newline, depth + 1, keylist) .. "," .. (newline and "\n" or "")
                end

                tmp = tmp .. string.rep(space, depth) .. "}"
            end
        -- end
    elseif _type(obj) == "number" then
        tmp = tmp .. _tostring(obj)
    elseif _type(obj) == "string" then
        tmp = tmp .. _string_format("%q", obj)
    elseif _type(obj) == "boolean" then
        tmp = tmp .. (obj and "true" or "false")
    elseif _type(obj) == "function" then
        -- tmp = tmp .. _tostring(obj)
        tmp = tmp .. [["【function】"]]
    elseif _type(obj) == "userdata" then
        -- tmp = tmp .. "【userdata】"
        tmp = tmp .. tostring(obj)
    else
        -- tmp = tmp .. "\"[" .. _string_format("%s", _tostring(obj)) .. "]\""
        tmp = tmp .. "\"[" .. _string_format("%s", _tostring(obj)) .. "]\""
    end

    return tmp
end

-- 用于存储的序列化
function UtilsBase.serializeForSave(obj, name)
    local tmp = ""
    local showComma = false
    local objType = _type(obj)
    if objType == "table" or
        objType == "number" or
        objType == "string" or
        objType == "boolean" then
        if name then
            if _type(name) == "number" then
                tmp = tmp .. "[" .. name .. "] = "
            elseif _type(name) == "string" then
                tmp = tmp .. name .. " = "
            else
                tmp = tmp .. _tostring(name) .. " = "
            end
        end
        showComma = true

        if string.find(tostring(obj),"table:0x") then
            tmp = tmp .. "{" ..  ""
            for k, v in _pairs(obj) do
                if k ~= "_class_type" and k ~= "traceinfo" then
                    local str, returnShowComma = UtilsBase.serializeForSave(v, k)
                    tmp =  tmp .. str .. (returnShowComma and "," or "")
                end
            end
            tmp = tmp .. "}"
        elseif _type(obj) == "number" then
            tmp = tmp .. _tostring(obj)
        elseif _type(obj) == "string" then
            tmp = tmp .. _string_format("%q", obj)
        elseif _type(obj) == "boolean" then
            tmp = tmp .. (obj and "true" or "false")
        end
    end

    return tmp, showComma
end

-- 反序列化
function UtilsBase.unserialize(str)
    str = string.gsub(str, [[%\[/]+]], "/")  -- 把"\/" 替换为 "/"
    return assert(loadstring("local tmp = " .. str .. " return tmp"))()
end

-- 显示指定对象的结构
function UtilsBase.dump(obj, name)
    if IS_DEBUG and ctx.Editor then
        print(UtilsBase.serialize(obj, UtilsColor.Green(name), true, 0))
    end
end

-- 显示指定对象的matetable结构
function UtilsBase.dump_mt(obj, name)
    if IS_DEBUG and ctx.Editor then
        UtilsBase.dump(getmetatable(obj), name)
    end
end

-- 获取子节点路径
function UtilsBase.GetChild(transform, nodeName)
    if transform == nil then
    	return nil
    end

    local childs = transform.gameObject:GetComponentsInChildren(typeof(Transform))
    local num = childs.Length
    for i = 0, num - 1 do
        if childs[i].name == nodeName then
            return childs[i]
        end
    end
    return nil
end

-- 判断值是否为null、nil
function UtilsBase.IsNull(value)
    -- return value == nil or value:Equals(nil)
    return value == nil
end


function UtilsBase.DefaultHoldTime()
    if IS_DEBUG then
        return 3
    end
    if IS_IOS then
        return 90
    else
        return 180
    end
end

function UtilsBase.GetEffectPath(effectid)
    return _string_format(AssetConfig.effect_path, effectid)
end

function UtilsBase.GetBigBgPath(path)
    return _string_format(AssetConfig.big_bg, path)
end

function UtilsBase.GetDramaPath(resname)
    return _string_format(AssetConfig.drama_path, resname)
end

function UtilsBase.Key(...)
    return table.concat({...}, "_")
end

local self_key = false
function UtilsBase.SelfKey()
    if not self_key then
        local roleData = RoleManager.Instance.model:getRoleVo()
        if roleData == nil then
            return nil
        end
        self_key = UtilsBase.Key(roleData.rid, roleData.srv_id)
    end
    return self_key
end

function UtilsBase.ClearSelfKey()
    self_key = false
end

function UtilsBase.IsSelf(rid, srv_id)
    local roleData = RoleManager.Instance.model:getRoleVo()
    if roleData == nil then
        return false
    end
    return rid == roleData.rid and srv_id == roleData.srv_id
end

function UtilsBase.IsSameRole(sRid, sPlatform, sZoneId, tRid, tPlatform, tZoneId)
    return sRid == tRid and sPlatform == tPlatform and sZoneId == tZoneId
end

-- 复制table
function UtilsBase.Copy(st)
    if st == nil then return nil end
    if _type(st) ~= "table" then
        return st
    end
    local tab = {}
    for k, v in _pairs(st or {}) do
        if _type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = UtilsBase.Copy(v)
        end
    end
    return tab
end

function UtilsBase.ChangeLayer(go, layername)
    local uilayer = LayerMask.NameToLayer(layername)
    if uilayer == 0 then
        return
    end
    local childs = go:GetComponentsInChildren(typeof(Transform), true)
    local num = childs.Length
    for i = 0, num-1 do
        childs[i].gameObject.layer = uilayer
    end
end

function UtilsBase.ChangeLayerTo(go, from_layername, to_layername)
    local formlayer = LayerMask.NameToLayer(from_layername)
    local tolayer = LayerMask.NameToLayer(to_layername)
    local childs = go:GetComponentsInChildren(typeof(Transform), true)
    local num = childs.Length
    for i = 0, num-1 do
        if childs[i].gameObject.layer == formlayer then
            childs[i].gameObject.layer = tolayer
        end
    end
end

-- 默认不需要传递secondlayer, 当有多个遮罩叠加的时候需要设置为TRUE
function UtilsBase.SetMaskMat(ImgCom, secondlayer)
    if not secondlayer then
        if UtilsBase.maskmat == nil then
            local shader = ShaderManager.Instance:GetShader("Custom/MyUIDefault")
            UtilsBase.maskmat = PreloadManager.Instance:GetObject(AssetConfig.mask_mat)
            UtilsBase.maskmat.shader = shader
        end
        ImgCom.material = UtilsBase.maskmat
    else
        if UtilsBase.maskmat2 == nil then
            local shader = ShaderManager.Instance:GetShader("Custom/MyUIDefault2")
            UtilsBase.maskmat2 = PreloadManager.Instance:GetObject(AssetConfig.mask_mat2)
            UtilsBase.maskmat2.shader = shader
        end
        ImgCom.material = UtilsBase.maskmat2
    end
end

-- --------------------------
-- 检测方向距离上有没碰撞
-- origin:当前点
-- direction:方向
-- distance:检测距离
-- layer:层级
-- --------------------------
function UtilsBase.CheckHit(origin, direction, distance, layer)
    local val = MathBit.orOp(SettingManager.GetLayerMaskVal(layer), SettingManager.GetLayerMaskVal("Ignore Raycast"))
    local result, hit = Physics.Raycast(origin, direction, Slua.out, distance, val)
    if result then
        return hit.point, hit
    end
    return nil
end

local spos = Vector3(0, 1000, 0)
local dir = Vector3(0, -1, 0)
local mt = getmetatable(UtilsGmaeLogic)
if mt.GetHeight then
    function UtilsBase.GetHeight(x, z)
        return UtilsGmaeLogic.GetHeight(x, z, SettingManager.GetLayerMaskVal("Default"))+ 0.1
    end
else
    function UtilsBase.GetHeight(x, z)
        spos:Set(x, 1000, z)
        local result, hit = Physics.Raycast(spos, dir, Slua.out, 2000, SettingManager.GetLayerMaskVal("Default"))
        if result then
            return hit.point.y + 0.1, result
        else
            return 1, result
        end
    end
end

-- 判断是否到达一个点
function UtilsBase.IsReach(pos1, pos2)
    local mapcellsize = MapManager.Instance.cellSize
    if _math_abs(pos1.x - pos2.x) <= mapcellsize and _math_abs(pos1.z - pos2.z) <= mapcellsize then
        return true
    end
    return false
end

function UtilsBase.FixPos(beginpos, endpos)
    -- local fix = MapManager.Instance:GetForwardPoint(beginpos, endpos)
    local dir = endpos - beginpos
    dir.y = 0
    local dis = Vector2ZDis(endpos, beginpos)
    local hitpos, hit = UtilsBase.CheckHit(beginpos, dir, dis, "ModelNpc")
    if hitpos then
        local hitdir = Vector2ZDis(hitpos, beginpos)
        if hitdir <= 2 or (math.abs(hitpos.x - beginpos.x) < 0.05 and math.abs(hitpos.z - beginpos.z) < 0.05) then
            -- hzf("hitdir", hitdir)
            local nor = hit.normal
            -- Debug.DrawLine (hitpos, hitpos + hit.normal, Color.green, 20);
            -- Debug.DrawLine (hitpos, hitpos + dir, Color.red, 20);
            local angel = Vector3.Angle(nor, dir)
            local cosval = Vector3.Cross(dir, nor)
            -- hzf("angel", angel)
            local pox = cosval.y < 0 and -1 or 1
            local a = math.sin(math.pi / 2 * pox)
            local b = math.cos(math.pi / 2 * pox)
            local x = nor.x * b - nor.z * a
            local y = nor.x * a + nor.z * b
            local realdir = Vector3(x, 0, y)
            -- Debug.DrawLine (hitpos, hitpos + realdir, Color.blue, 20);
            -- Debug.DrawLine (beginpos, beginpos + realdir, Color.yellow, 20);
            local newpos = beginpos + realdir.normalized * dis*math.sin(math.pi * angel / 180)
            -- local newhitpos = UtilsBase.CheckHit(beginpos, realdir.normalized, dis*math.sin(math.pi * angel / 180), "ModelNpc")
            local newhitpos = UtilsBase.CheckHit(beginpos, realdir.normalized, dis, "ModelNpc")
            if newhitpos then
                if Vector2ZDis(newhitpos, beginpos) > 2 then
                    return newhitpos, true
                else
                    return beginpos, true
                end
            else
                return newpos, true
            end
        else
            -- hzf("OK")
            hitpos = beginpos + (hitpos - beginpos).normalized * (hitdir -1.5)
            return hitpos, true
        end
    else
            -- hzf("GO")
        return endpos, false
    end
end

function UtilsBase.PosValid(beginpos, endpos)
    if beginpos == nil or endpos == nil then
        return true
    end
    local dir = endpos - beginpos
    dir.y = 0
    local dis = Vector2ZDis(endpos, beginpos)
    local hitpos, hit = UtilsBase.CheckHit(beginpos, dir, dis, "Ignore Raycast")
    if hitpos then
        -- 碰到空气墙了
        return false, hitpos
    else
        return true
    end
end
-- norelative 不管相对层级
function UtilsBase.SetOrder(go, order, norelative)
    local renders = go:GetComponentsInChildren(typeof(Renderer), true)
   for i = 0, renders.Length - 1 do
        local t = renders[i]
        if norelative then
            t.sortingOrder = order
        elseif _math_abs(t.sortingOrder - order) > 10 then
            t.sortingOrder = order + t.sortingOrder
        else
            t.sortingOrder = order + t.sortingOrder %10
        end
    end
end

function UtilsBase.SetRenderQueue(go, val)
    local renders = go:GetComponentsInChildren(typeof(Renderer), true)
    for i = 0, renders.Length - 1 do
        t.material.renderQueue = val
    end
end

function UtilsBase.SetMaterialStencil(material, secondlayer)
    if not secondlayer then
        material:SetFloat(SettingManager.GetShaderProID("_Stencil"), 1);
    else
        material:SetFloat(SettingManager.GetShaderProID("_Stencil"), 3);
    end
end

function UtilsBase.ChangeEffectMaskShader(go, order, layername, secondlayer)
    if layername ~= nil then
        UtilsBase.ChangeLayer(go, layername)
    end
    local renders = go.transform:GetComponentsInChildren(typeof(Renderer), true)
    for i = 0, renders.Length - 1 do
        local t = renders[i]
        if string.find(t.material.shader.name, "ParticlesAdditive") then
            t.material.shader = ShaderManager.Instance:GetShader("Xcqy/ParticleMask")
            UtilsBase.SetMaterialStencil(t.material, secondlayer)
        elseif string.find(t.material.shader.name, "ParticlesAlphaBlended") then
            t.material.shader = ShaderManager.Instance:GetShader("Xcqy/ParticlesAlphaBlendedMask")
            UtilsBase.SetMaterialStencil(t.material, secondlayer)
        elseif string.find(t.material.shader.name, "ZQLTTextureAdd") then
            t.material.shader = ShaderManager.Instance:GetShader("Xcqy/Particles/ZQLTTextureAddMask")
            UtilsBase.SetMaterialStencil(t.material, secondlayer)
        elseif string.find(t.material.shader.name, "UVRoll_add") then
            t.material.shader = ShaderManager.Instance:GetShader("Custom/UVRoll_addMask")
            UtilsBase.SetMaterialStencil(t.material, secondlayer)
        elseif t.material.shader.name == "Xcqy/UnlitTexture" then
            t.material.shader = ShaderManager.Instance:GetShader("Xcqy/UnlitTexturePreview")
            t.material:SetFloat(SettingManager.GetShaderProID("_StencilComp"), StencilComp.Equal);
            UtilsBase.SetMaterialStencil(t.material, secondlayer)
        end
        if order ~= nil then
            t.sortingOrder = order
        end
    end
end

local _orginal_id = 100000
function UtilsBase.GetClientID()
    _orginal_id = _orginal_id + 1
    return _orginal_id
end

-- 长文本格式，后面点点点
function UtilsBase.LongTextFormat(str, len)
    local list = string.ConvertStringTable(str)
    if #list <= len then
        return str
    end

    local result = ""
    for i,v in _ipairs(list) do
        if i <= (len - 3) then
            result = result .. v
        else
            break
        end
    end
    result = _string_format("%s...", result)
    return result
end

function UtilsBase.TableDeleteMe(object, name)
    if object[name] ~= nil then
        for key, item in _pairs(object[name]) do
            if item.DeleteMe then
                item:DeleteMe()
            else
                if IS_DEBUG then
                    LogError("TableDeleteMe找不到销毁方法")
                end
            end
        end
        object[name] = nil
    end
end

function UtilsBase.FieldDeleteMe(object, name)
    if IS_DEBUG then
        if type(name) ~= "string" then
            LogError("FieldDeleteMe 传入参数不为字符串")
        end
    end

    if object[name] ~= nil then
        object[name]:DeleteMe()
        object[name] = nil
    end
end

function UtilsBase.DestroyGameObject(object, name)
    if object[name] ~= nil then
        GameObject.Destroy(object[name])
        object[name] = nil
    end
end

function UtilsBase.TweenDelete(object, name)
    if object[name] ~= nil then
        Tween.Instance:Cancel(object[name])
        object[name] = nil
    end
end

function UtilsBase.TweenIdListDelete(object, name)
    if object[name] then
        for _, tweenId in _pairs(object[name]) do
            Tween.Instance:Cancel(tweenId)
        end
        object[name] = nil
    end
end

function UtilsBase.TimerDelete(object, name)
    if object[name] ~= nil then
        TimerManager.Delete(object[name])
        object[name] = nil
    end
end

function UtilsBase.TimerManagerDelete(object, name)
    if object[name] ~= nil then
        TimerManager.Delete(object[name])
        object[name] = nil
    end
end

function UtilsBase.TimerListDelete(object, name)
    if object[name] then
        for _, timer in _pairs(object[name]) do
            TimerManager.Delete(timer)
        end
        object[name] = nil
    end
end

function UtilsBase.CancelTween(id)
    Tween.Instance:Cancel(id)
end

function UtilsBase.InitTimeline(class, name)
    if class[name] == nil then
        class[name] = TimeLine.New()
    end
    class[name]:Clear()
end

function UtilsBase.SafeHide(class, name)
    if class[name] then
        class[name]:Hide()
    end
end

function UtilsBase.LoadAndPlayEffect(object, name, effectId, parent, position, order, changeMaskShader, scale, constancy, secondMask)
    if object[name] ~= nil then
        if constancy then
            if not object[name].activeInHierarchy then
                UtilsBase.PlayEffect(object, name)
            end
        else
            UtilsBase.PlayEffect(object, name)
        end
    else
        if object[name .. "_loading"] then
            object[name .. "_callback"] = object[name .. "_callback"] or {}
            table.insert(object[name .. "_callback"], function() UtilsBase.HideEffect(object, name) end)
        else
            local cb = function() UtilsBase.PlayEffect(object, name) end
            UtilsBase.LoadEffect(object, name, effectId, parent, position, order, cb, changeMaskShader, scale, secondMask)
        end
    end
end

function UtilsBase.PlayEffect(object, name)
    if not UtilsBase.IsNull(object[name]) then
        object[name]:SetActive(false)
        object[name]:SetActive(true)
    end
end

function UtilsBase.HideEffect(object, name)
    if not UtilsBase.IsNull(object[name]) then
        object[name]:SetActive(false)
    else
        if object[name .. "_loading"] then
            object[name .. "_callback"] = object[name .. "_callback"] or {}
            table.insert(object[name .. "_callback"], function() UtilsBase.HideEffect(object, name) end)
        end
    end
end

function UtilsBase.LoadEffect(object, name, effectId, parent, position, order, cb, changeMaskShader, scale, secondMask)
    if object[name] then
        return
    end
    object[name .. "_loading"] = true
    local loader = nil
    local callback = function(assetsloader)
        if object[name] == nil then
            if not UtilsBase.IsNull(parent) then
                local effect = assetsloader:Pop(UtilsBase.GetEffectPath(effectId))
                object[name] = effect
                local transform = effect.transform
                transform:SetParent(parent)
                transform.localScale = scale ~= nil and scale or Vector3.one
                transform.localPosition = position
                transform.localRotation = Quaternion.identity
                if changeMaskShader then
                    UtilsBase.ChangeEffectMaskShader(effect, order, "UI", secondMask)
                else
                    UtilsBase.SetOrder(effect, order)
                end
                object[name .. "_loading"] = false
                if cb then
                    cb()
                end
                for _,__cb in ipairs(object[name .. "_callback"] or {}) do
                    __cb()
                end
            end
        end
        loader:DeleteMe()
        loader = nil
    end
    loader = EffectLoader.New({effectId}, callback)
    loader:Load()
end

function UtilsBase.TableToList(tab)
    local result = {}
    for _, v in _pairs(tab) do
        _table_insert(result, v)
    end
    return result
end

function UtilsBase.TableValueToDict(tab)
    local result = {}
    for key, value in _pairs(tab) do
        result[value] = key
    end
    return result
end

function UtilsBase.KeyValueSwap(tab)
    local result = {}
    for k, v in pairs(tab) do
        result[v] = k
    end
    return result
end

function UtilsBase.GetTableCount(tab)
    local count = 0
    for _, v in _pairs(tab) do
        count = count + 1
    end
    return count
end

function UtilsBase.GetNullOrTableCount(tab)
    if tab == nil or type(tab) ~= "table" then
        return 0
    end
    return UtilsBase.GetTableCount(tab)
end

function UtilsBase.CreateTableIfEmpty(tab, key)
    if tab[key] == nil then
        tab[key] = {}
    end
end

function UtilsBase.XPCall(func, errcb)
    local status, err = xpcall(func, function(errinfo)
        if errcb then
            errcb()
        else
            LogError("代码报错了: ".. _tostring(errinfo)..debug.traceback())
        end
    end)
end

function UtilsBase.SetParent(childTrans, parentTrans, scale, position)
    childTrans:SetParent(parentTrans)
    childTrans.localScale = scale or Vector3.one
    childTrans.localPosition = position or Vector3.zero
    childTrans.localRotation = Quaternion.identity
end

function UtilsBase.LoadIcon(classSelf, loaderName, image, path, callback)
    if classSelf[loaderName] == nil then
        classSelf[loaderName] = SingleIconLoader.New(image, path, callback)
    else
        classSelf[loaderName]:Reload(image, path, callback)
    end
end

function UtilsBase.LoadMultipleIcon(classSelf, loaderName, imageGo, pathList, defaultName, callback)
    if classSelf[loaderName] == nil then
        classSelf[loaderName] = MultipleIconLoader.New(imageGo, pathList, defaultName, callback)
    else
        classSelf[loaderName]:SetIcon(defaultName, callback)
    end
end

function UtilsBase.LoadTitleUIIcon(class, image, name, titleLev, classes, scale,func)
    UtilsUI.InActive(image.gameObject)
    local path = string.format("title_%s", TitleConfigHelper.GetTitleIcon(titleLev, classes))
    UtilsBase.LoadMultipleIcon(class, name, image.gameObject, {AssetConfig.titlename}, path, function()
        UtilsUI.Active(image.gameObject)
        image:SetNativeSize()
        scale = scale or 1
        SetLocalScale(image.transform, scale, scale, scale)
        if func ~= nil then
            func()
        end
    end)
end

function UtilsBase.SetMoneyNoitceImg(class, imageCom, name)
    local coinNum = BackpackManager.Instance:GetItemCount(ItemConfigHelper.COIN_ITEM_ID)
    local iconId = ItemConfigHelper.COIN_ITEM_ID
    if coinNum == 0 and NoticeModel.Instance:IsNoShowAgain("ExchangeComfirmTip") then
        local goldNum = BackpackManager.Instance:GetItemCount(ItemConfigHelper.GOLD_BIND_ITEM_ID)
        iconId = goldNum == 0 and ItemConfigHelper.COIN_ITEM_ID or ItemConfigHelper.GOLD_BIND_ITEM_ID
    end
    UtilsBase.LoadIcon(class, name, imageCom, ItemConfigHelper.GetIconPath(iconId))
end

function UtilsBase.SetMoneyNoitceId(id)
    if id ~= ItemConfigHelper.COIN_ITEM_ID then

        return id
    end
    local coinNum = BackpackManager.Instance:GetItemCount(ItemConfigHelper.COIN_ITEM_ID)
    local iconId = ItemConfigHelper.COIN_ITEM_ID
    if coinNum == 0 and NoticeModel.Instance:IsNoShowAgain("ExchangeComfirmTip") then
        local goldNum = BackpackManager.Instance:GetItemCount(ItemConfigHelper.GOLD_BIND_ITEM_ID)
        iconId = goldNum == 0 and ItemConfigHelper.COIN_ITEM_ID or ItemConfigHelper.GOLD_BIND_ITEM_ID
    end
    return iconId
end

function UtilsBase.SafeSpineLoad(classSelf, loader, setting)
    if setting == nil then
        LogError("不允许传入空的setting来初始化spineloader")
        return
    end
    if classSelf[loader] == nil then
        classSelf[loader] = SpineLoader.New(setting)
        classSelf[loader]:Load()
    else
        classSelf[loader]:Reload(setting)
    end
end

function UtilsBase.LoadAsset(class, loaderName, resList, callback)
    if loaderName == "assetLoader" then LogError("assetLoader已被BaseView使用了. 请改用其他loaderName") end
    if class[loaderName] then
        return
    end
    class[loaderName] = AssetBatchLoader.New(loaderName)
    class[loaderName]:AddListener(callback)
    class[loaderName]:LoadAll(resList)
end

-- setting = {
    -- base_id,        --宠物baseid
    -- star_lev,       --宠物星级
    -- scaleRatio,     --界面缩放系数
    -- parentTrans,    --挂载节点
    -- position,       --位置
    -- callback,       --回调函数
    -- layer,          --界面层级
    -- rotation,       --旋转
    -- class,          --持有preview的类
    -- loaderName,     --loader名字
    -- previewName,    --preview名字
    -- needShow,       --是否需要加载后显示（默认为true）
    -- isFightAnimation, --是否需要播放战斗动作
-- }
function UtilsBase.LoadPetModel(setting)
    local modelData = PetConfigHelper.GetModelData(setting.base_id, setting.star_lev)
    local starConfig = PetConfigHelper.GetStarConfig(setting.base_id, setting.star_lev)
    local unitConfig = UnitConfigHelper.GetConfig(starConfig.unit_id)

    local isFightAnimation = setting.isFightAnimation == true

    local previewName = setting.previewName or "PetComposite"
    local loaderName = setting.loaderName or "preview"
    local needShow = setting.needShow ~= false

    local rotation = setting.rotation or Vector3(12, 153.7, -8.5)

    local scaleRatio = setting.scaleRatio or 100
    local modelScale = modelData.scale * scaleRatio + (unitConfig.scale * scaleRatio / 240)

    local height = PetConfigHelper.GetModelHeight(setting.base_id, setting.star_lev) or 0
    local modelHeight = height * modelScale / 100
    local position = Vector3(setting.position.x, setting.position.y, setting.position.z)
    position.y = position.y + modelHeight

    local callback = setting.callback or function(composite)
        if isFightAnimation then
            composite:PlayAnimations({"attack1000", "stand1"})
        else
            composite:PlayAnimations({"stand1"})
        end
        if composite.tpose then
            SetLocalScale(composite.tpose.transform, modelScale, modelScale, modelScale)
            SetLocalPosition(composite.tpose.transform, position.x, position.y, position.z)
        end
        if not needShow then
            setting.class[loaderName]:Hide()
        end
    end
    if setting.class[loaderName] == nil then
        local config = PetConfigHelper.GetConfig(setting.base_id)
        local modelSetting = {
            name = previewName
            ,layer = "UI"
            ,sortingOrder = setting.layer
            ,parent = setting.parentTrans
            ,localPos = position
            ,localRot = rotation
        }
        setting.class[loaderName] = PreviewmodelComposite.New(callback, modelSetting, modelData)
    else
        setting.class[loaderName]:Reload(modelData, callback)
    end
end

function UtilsBase.ContainValueTable(tab, value)
    for k,v in _pairs(tab) do
        if value == v then
            return true
        end
    end
    return false
end

function UtilsBase.ToChargeSDK(charge_id, bridge)
    local amount, id, name, type = RechargeConfigHelper.FitSDK(charge_id)
    if SdkManager.Instance:RunSdk() then
        SdkManager.Instance:ShowChargeView(amount, id, name, type, bridge or "vx")
    end
    StoreManager.Instance:ToSetBury(id, name)
end

-- 获取地区说明
-- cn => 国内
-- sg => 新马
function UtilsBase.GetLocation()
    if CSInfo then
        return CSInfo.Location
    else
        return "cn"
    end
end

function UtilsBase.ToBase64(source_str)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local s64 = ""
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(_math_floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. "="
        end
    end

    return s64
end

function UtilsBase.UrlEncode(s)
     s = string.gsub(s, "([^%w%.%- ])", function(c) return _string_format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function UtilsBase.AccountByChanelId(pchanlid, uid)
    return _tostring(pchanlid) .. "_" .. _tostring(uid)
end

function UtilsBase.ChannelGroupId()
    if Application_platform == RuntimePlatform.IPhonePlayer then
        return "666"
    end
    return ctx.ChannelGroupId
end

function UtilsBase.PlayMovie(name, canskip, callback)
    if Application_platform ~= RuntimePlatform.Android and Application_platform ~= RuntimePlatform.IPhonePlayer then
        NoticeManager.Instance:ShowFloat(_T("非移动平台不支持视频播放"))
        if callback then
            callback()
        end
        return
    end
    if UtilsBase.playmovieCom == nil then
        UtilsBase.playmovieCom = ctx.MainCamera.gameObject:AddComponent(typeof(MoviePlayer))
    end
    UtilsBase.playmovieCom.path = name
    -- Log.Info("开始播放视频~~~~~~")
    UtilsBase.playmovieCom.onFinish = nil
    if callback ~= nil then
        local event = UnityEvent()
        event:AddListener(callback)
        UtilsBase.playmovieCom.onFinish = event
    end
    UtilsBase.playmovieCom:Play(canskip == true)
    -- Log.Info("播放视频结束~~~~~~")
end

function UtilsBase.ContrastData(classes,sex)
    local roleData = RoleManager.Instance.model:getRoleVo()
    if (roleData.classes == classes or classes == 0) and (roleData.sex == sex or sex == 2) then
        return true
    end
    return false
end

function UtilsBase.TimeDeltaToDate(delta)
    local floor = _math_floor
    return floor(delta / 86400), floor((delta % 86400) / 3600), floor((delta % 3600) / 60), floor(delta % 60)
end

-- delta 时间差
-- showArgs = {1, 0, 0, 1}，对应{天，时，分，秒}是否要显示
function UtilsBase.TimeDeltaToString(delta, showArgs)
    local floor = _math_floor
    local args = {floor(delta / 86400), floor((delta % 86400) / 3600), floor((delta % 3600) / 60), floor(delta % 60)}
    local result = {}
    local preok = 0
    showArgs = showArgs or {1, 1, 1, 1}
    if showArgs[1] == 1 and (args[1] > 0 or preok > 0) then preok = 1 _table_insert(result, args[1]) _table_insert(result, _T("日")) end
    if showArgs[2] == 1 and (args[2] > 0 or preok > 0) then preok = 1 _table_insert(result, _string_format("%02d", args[2])) _table_insert(result, _T("时")) end
    if showArgs[3] == 1 and (args[3] > 0 or preok > 0) then preok = 1 _table_insert(result, _string_format("%02d", args[3])) _table_insert(result, _T("分")) end
    if showArgs[4] == 1 and (args[4] > 0 or preok > 0) then preok = 1 _table_insert(result, _string_format("%02d", args[4])) _table_insert(result, _T("秒")) end
    if _next(result) then
        return _table_concat(result)
    else
        return ""
    end
end

function UtilsBase.GetDate(timeStemp)
    return _tonumber(_os_date("%y", timeStemp)), _tonumber(_os_date("%m", timeStemp)), _tonumber(_os_date("%d", timeStemp)), _tonumber(_os_date("%H", timeStemp)), _tonumber(_os_date("%M", timeStemp)), _tonumber(_os_date("%S", timeStemp))
end

-- format = {0,1,1,0,1,0}, 分别表示年月日时分秒是否显示
function UtilsBase.GetDateString(timeStemp, format)
    format = format or {}
    local result = {}
    local args = {0, 0, 0, 0, 0, 0}
    args[1],args[2],args[3],args[4],args[5],args[6] = UtilsBase.GetDate(timeStemp)
    if format[1] == 1 then _table_insert(result, args[1]) _table_insert(result, _T("年")) end
    if format[2] == 1 then _table_insert(result, args[2]) _table_insert(result, _T("月")) end
    if format[3] == 1 then _table_insert(result, args[3]) _table_insert(result, _T("日")) end
    if format[4] == 1 then _table_insert(result, args[4]) _table_insert(result, _T("时")) end
    if format[5] == 1 then _table_insert(result, args[5]) _table_insert(result, _T("分")) end
    if format[6] == 1 then _table_insert(result, args[6]) _table_insert(result, _T("秒")) end

    if _next(result) then
        return _table_concat(result)
    else
        return ""
    end
end

-- 判断两个时间戳是否在同一天
-- 适用于2018年1月1日0点往后的时间戳
function UtilsBase.IsDifferentDate(stemp1, stemp2)
    UtilsBase.standardStemp = UtilsBase.standardStemp or _os_time({year = 2018, month = 1, day = 1, hour = 0, min = 0, sec = 0})
    return _math_floor((stemp1 - UtilsBase.standardStemp) / 86400) ~= _math_floor((stemp2 - UtilsBase.standardStemp) / 86400)
end

-- 距离今天的天数
function UtilsBase.GetDistanceDays(stemp, standard)
    standard = standard or UtilsBase.ServerTime()
    UtilsBase.standardStemp = UtilsBase.standardStemp or _os_time({year = 2018, month = 1, day = 1, hour = 0, min = 0, sec = 0})
    return _math_floor((stemp - UtilsBase.standardStemp) / 86400) - _math_floor((standard - UtilsBase.standardStemp) / 86400)
end

-- 获取今天的秒数
function UtilsBase.GetZeroStempToday(dis)
    UtilsBase.standardStemp = UtilsBase.standardStemp or _os_time({year = 2018, month = 1, day = 1, hour = 0, min = 0, sec = 0})
    return UtilsBase.ServerTime() - (UtilsBase.ServerTime() - UtilsBase.standardStemp) % 86400 + (dis or 0) * 86400
end


-- 是否玩家体验服
function UtilsBase.IsExperienceSrv()
    if CSVersion.platform == "android_experience" then
        return true
    else
        return false
    end
end

-- 获取网络状态
function UtilsBase.NetworkStatus()
    local val = Application.internetReachability
    if val == 0 then
        return "none"
    elseif val == 1 then
        return "data"
    elseif val == 2 then
        return "wifi"
    end
    return "wifi"
    -- return SdkManager.Instance:GetNetworkType()
end

local _dynamicShadowVector = Vector3(-0.29, -0.57, -0.2)
function UtilsBase.DynamicShadowVector()
    return _dynamicShadowVector
end

-- 中文utf-8字符串截取，超过指定长度的部分用...代替
function UtilsBase.SplitStringToLength(str,len)
    if str == nil then
        return ""
    end
    local lengthUTF_8 = #(string.gsub(str, "[\128-\191]", ""))
    if lengthUTF_8 <= len then
        return str
    else
        local matchStr = "^"
        for var=1, len do
            matchStr = matchStr..".[\128-\191]*"
        end
        local string = string.match(str, matchStr)
        return string.format("%s...",string);
    end
end

-- maxCount --设置多少位数开始转换为文字显示 默认5位数
function UtilsBase.ExchangeNum(nowVal, maxCount)
    local valueData = nowVal
    local max = 9999
    if maxCount ~= nil then
        max = math.pow(10, maxCount) - 1
    end
    if nowVal > max then
        if nowVal > 99999999 then
            local vlaue1 = nowVal/100000000
            vlaue1 = vlaue1-vlaue1%0.1
            valueData = vlaue1 .. "亿"
        else
            local vlaue1 = nowVal/10000
            vlaue1 = vlaue1-vlaue1%0.1
            valueData = vlaue1 .. "万"
        end
    end
    return valueData
end

function UtilsBase.HasItemNum(id)
    local hasNum = BackpackManager.Instance:GetItemCount(id)
    if hasNum == nil or hasNum == 0 then
        hasNum = RoleManager.Instance.model:GetAssetsValue(id)
    end
    return hasNum
end

-- 今日是否完成
function UtilsBase.IsToDayDone(key)
    local selfkey = UtilsBase.SelfKey()
    local day = os.date("%d", timeStemp)
    local result = PlayerPrefs.GetString(selfkey..key)
    return result == day
end

--设置今日已完成
function UtilsBase.SetToDayDone(key)
    local selfkey = UtilsBase.SelfKey()
    local day = os.date("%d", timeStemp)
    PlayerPrefs.SetString(selfkey..key, day)
end


--记得设置过灰色的面板，在销毁的时候，将灰色设置回来，
--避免面板销毁后，材质跟image还保留在这里而释放不了
-- function UtilsBase.SetGrey(Img, Yes, Changecolor)
--     if Yes then
--         if Img ~= nil then
--             if Changecolor then
--                 Img.color = Color(0.5, 0.5, 0.5)
--             else
--                 -- Img.grey = true
--                 UtilsBase.setImageGrey(Img,true)
--             end
--         end
--
--     elseif Img ~= nil then
--         if Changecolor then
--             Img.color = Color.white
--         else
--             -- Img.grey = false
--             UtilsBase.setImageGrey(Img,false)
--         end
--     end
-- end

--变灰功能、
local default_shader_name           = "UI/UGUI_Default"
local default_shader_noAlpTex_name  = "UI/UGUI_Default_NoAlpTex"
local grey_shader_name              = "UI/UGUI_Grey"
local grey_shader_noAlpTex_name     = "UI/UGUI_Grey_NoAlpTex"

-----------现在不再需要存储起来-----------
function UtilsBase.SetImageGrey(image)
    if not image then
        return nil
    end

    local reMatrial = image.material
    if not reMatrial then
        return
    end
    --如果已经灰色处理的 直接返回
    local rshader_name = reMatrial.shader.name

    if rshader_name == grey_shader_name or
       rshader_name == grey_shader_noAlpTex_name then
        return reMatrial
    end

    local grey_mat = UtilsBase.getGreyMaterailByName(reMatrial,rshader_name)
    if grey_mat then
        image.material = grey_mat --赋予灰色材质
    end
    return grey_mat
end

function UtilsBase.ResetImageGray(image)
    if not image then
        return nil
    end
    local shadername = image.material.shader.name
    if shadername == grey_shader_name then
        image.material.shader = ShaderManager.Instance:GetShader(default_shader_name)
    elseif shadername == grey_shader_noAlpTex_name then
        image.material.shader = ShaderManager.Instance:GetShader(default_shader_noAlpTex_name)
    end
    if image.enabled then
        image.enabled = false
        image.enabled = true
    end
end

function UtilsBase.getGreyMaterailByName(reMatrial,rshader_name)
    local gshader_name = grey_shader_name
    if rshader_name == default_shader_noAlpTex_name  then
        gshader_name = grey_shader_noAlpTex_name
    end

    local gshader = ShaderManager.Instance:GetShader(gshader_name)
    if not gshader then
        LogWarning("can not find grey shader !!!!!!!!!!" .. gshader_name)
        return nil
    end
    local grey_mat = Material(gshader)
    grey_mat:CopyPropertiesFromMaterial(reMatrial)
    return grey_mat
end

function UtilsBase.ParseJson(str)
    return NormalJson(str).table
end

function UtilsBase.DelectLocalFile(fileName)
    local call = function()
        if Webcam == nil then
            os.remove(fileName)
        else
            DeleteFile.DeletePath(fileName)
        end
    end
    local status, err = xpcall(call, function(errinfo)
        Log.Debug("删除本地文件出错了 " .. tostring(errinfo)); Log.Debug(debug.traceback())
    end)
    if not status then
        Log.Debug("删除本地文件出错了 " .. tostring(err))
        return false
    end
    return true
end

function UtilsBase.SaveLocalFile(fileName, bytes)
    local status, err = xpcall(function() UtilsIO.WriteAllBytes(fileName, bytes) end, function(errinfo)
        Log.Debug("储存本地文件出错了 " .. tostring(errinfo)); Log.Debug(debug.traceback())
    end)
    if not status then
        Log.Debug("储存本地文件出错了 " .. tostring(err))
        return false
    end
    return true
end

function UtilsBase.LoadLocalFile(fileName)
    local bytes = nil
    local status, err = xpcall(function() bytes = UtilsIO.ReadAllBytes(fileName) end, function(errinfo)
        Log.Debug("读取本地文件出错了 " .. tostring(errinfo)); Log.Debug(debug.traceback())
    end)
    if not status then
        Log.Debug("读取本地文件出错了 " .. tostring(err))
    end

    return bytes
end

function UtilsBase.Download(url, callback)
    local c = coroutine.create(function()
        local www = WWW(url)
        coroutine.yield()
        while not www.isDone do
            coroutine.yield()
        end
        if www.error == "" or www.error == nil then
            if callback then
                callback(www.bytes)
            end
        end
    end)

    local func = function(f, co, __count)
        TimerManager.Add(100, function()
            if __count == 100 then
                return
            elseif coroutine.status(co) == "dead" then
                return
            else
                coroutine.resume(co)
                f(f, co, __count + 1)
            end
        end)
    end
    func(func, c, 0)
end

function UtilsBase.GetEtc(key)
    if Config.DataEtc.data_get_etc_config[key] == nil then
        LogError("etc_data找不到配置key:" .. tostring(key) .. "\n" .. debug.traceback())
    end
    return Config.DataEtc.data_get_etc_config[key].val
end

function UtilsBase.FindPath(transform)
    local trans = transform
    local tab = {}

    while trans ~= nil do
        table.insert(tab, 1, trans.gameObject.name)
        trans = trans.parent
    end
    return table.concat(tab, "/")
end

function UtilsBase.OpenSrvTime()
    return CampaignManager.Instance.mergeInfo.open_srv_time
end

-- 获取C# 对象中的方法、变量，尽量少用
function UtilsBase.GetInterface(customData, name)
    local tab = getmetatable(customData)
    for k,v in pairs(tab) do
        if tostring(k) == name then
            return v
        end
    end
end

function UtilsBase.GetFormatUrl(url)
    local tab = StringHelper.Split(url, [[\/]])
    return table.concat(tab, "/")
end

function UtilsBase.IsSameServer(args)
    local roledata = RoleManager.Instance.model:getRoleVo()
    local mergeInfo = CampaignManager.Instance.mergeInfo
    if args.srv_id == roledata.srv_id then
        return true
    else
        if mergeInfo then
            return mergeInfo:IsSameServer(args.platform, args.zone_id)
        else
            return false
        end
    end
end

-- 是否为诗悦渠道 (包含安卓和IOS)
function UtilsBase.IsSyChannel()
    if UtilsBase._isSyChannel == nil then
        UtilsBase._isSyChannel = UtilsBase.IsAndroidSyChannel() or UtilsBase.IsIOSSyChannel()
    end
    return UtilsBase._isSyChannel
end

-- 是否为安卓诗悦渠道
function UtilsBase.IsAndroidSyChannel()
    if UtilsBase._isAndroidSyChannel == nil then
        local platformChannleId = ctx.PlatformChannleId
        UtilsBase._isAndroidSyChannel = false
        if IS_ANDROID and platformChannleId and string.find(platformChannleId, "sy") then
            UtilsBase._isAndroidSyChannel = true
        end
    end
    return UtilsBase._isAndroidSyChannel
end

-- 是否为IOS诗悦渠道
function UtilsBase.IsIOSSyChannel()
    if UtilsBase._isIOSSyChannel == nil then
        UtilsBase._isIOSSyChannel = ctx.PlatformChannleId == "195"
    end
    return UtilsBase._isIOSSyChannel
end

-- 字符串转时间缀
function UtilsBase.String2Time(timeString)
    if type(timeString) ~= 'string' then LogError('string2time: timeString is not a string') return 0 end
    local fun = string.gmatch( timeString, "%d+")
    local y = fun() or 0
    if y == 0 then LogError('timeString is a invalid time string') return 0 end
    local m = fun() or 0
    if m == 0 then LogError('timeString is a invalid time string') return 0 end
    local d = fun() or 0
    if d == 0 then LogError('timeString is a invalid time string') return 0 end
    local H = fun() or 0
    if H == 0 then LogError('timeString is a invalid time string') return 0 end
    local M = fun() or 0
    if M == 0 then LogError('timeString is a invalid time string') return 0 end
    local S = fun() or 0
    if S == 0 then LogError('timeString is a invalid time string') return 0 end
    return os.time({year=y, month=m, day=d, hour=H,min=M,sec=S})
end

table.qsort = function(tab, func, low, high)
    low = low and low or 1;
    high = high and high or #tab;
    local l = low
    local h = high
    local povit = tab[low];
    while(l < h) do
        while(l < h and not func(tab[h], povit)) do
            h = h - 1
        end
        if (l < h) then
            local temp = tab[h];
            tab[h] = tab[l];
            tab[l] = temp;
            l = l + 1;
        end
        while(l < h and func(tab[l], povit)) do
            l = l + 1;
        end
        if(l < h) then
            local temp = tab[h];
            tab[h] = tab[l];
            tab[l] = temp;
            h = h - 1;
        end
    end

    if(l > low) then table.qsort(tab, func, low, l-1) end
    if(h < high) then table.qsort(tab, func, l+1, high) end
end

function UtilsBase.MergeTabSame(...)
    local arg = {...}
    local result = {}
    for i, v in _ipairs(arg) do
        for _, vv in _ipairs(v) do
            local isHas = false
            for _,vvv in pairs(result) do
                if vvv == vv then
                    isHas = true
                end
            end
            if isHas == false then
                _table_insert(result, vv)
            end
        end
    end
    return result
end
-- table.sort = table.qsort

function UtilsBase.ShakePhone()
    if SettingManager.Instance:GetResult(SettingType.ShakePhone) ~= 1 then
        Utils.ShakePhone()
    end
end

function UtilsBase.GetAssetsValue(str,showStr)
    local newStr
    local showStr = showStr or str
    if tonumber(str) < 10000 then
        newStr = string.format("<color=#855b2d>%s</color>",showStr)
    elseif tonumber(str) < 100000 then
        newStr = string.format("<color=#3a8536>%s</color>",showStr)
    elseif tonumber(str) < 1000000 then
        newStr = string.format("<color=#4187c4>%s</color>",showStr)
    elseif tonumber(str) < 10000000 then
        newStr = string.format("<color=#ca41c7>%s</color>",showStr)
    else
        newStr = string.format("<color=#cf7335>%s</color>",showStr)
    end
    return newStr
end

--随机获得圆心点
function UtilsBase.GetCirclePoint(pointX,pointY,R)
    math.randomseed(tostring(os.time()):reverse():sub(1,6))
    local r = math.sqrt(math.random(0,R*R)) --只有参数n产生1-n之间的整数
    local theta =  math.random() * 2 * math.pi
    local x = pointX + r*math.cos(theta)
    local y = pointY + r*math.sin(theta)
    return x,y
end

function UtilsBase.ClearTrail(ts)
    if UtilsBase.IsNull(ts) then
         return
     end
    local Trails = ts:GetComponentsInChildren(typeof(TrailRenderer))
    for i = 0, renders.Length - 1 do
        local rd = renders[i]
        rd:Clear()
    end
end

function UtilsBase.KeyFind(keyName, keyValue, tab)
    for k,v in pairs(tab) do
        if v[keyName] ~= nil and v[keyName] == keyValue then
            return v
        end
    end
    return nil
end

function UtilsBase.GetServerName(zoneId, platform)
    local list = ServerConfig.curServers
    if list ~= nil then
        for _, data in pairs(list) do
            if data.zone_id == zoneId and data.platform == platform then
                return data.zone_name
            end
        end
    end
    list = ServerConfig.servers
    if list ~= nil then
        for _, data in ipairs(list) do
            if data.zone_id == zoneId and data.platform == platform then
                return data.zone_name
            end
        end
    end
    list = ServerConfig.testServers
    if list ~= nil then
        for _, data in ipairs(list) do
            if data.zone_id == zoneId and data.platform == platform then
                return data.zone_name
            end
        end
    end
    return _T("未知服")
end

-- 是否是审核服（用于判断充值）
function UtilsBase.IsReviewServer()
    if UtilsBase._reviewServerDict == nil then
        UtilsBase._reviewServerDict = {
            ["1008177|41"] = 1, ["1008178|41"] = 1, ["1008179|41"] = 1, ["1008180|41"] = 1,
            ["1008181|41"] = 1, ["1008182|41"] = 1, ["1008183|41"] = 1, ["1008184|41"] = 1,
            ["1008185|41"] = 1, ["1008186|41"] = 1, ["1007911|41"] = 1, ["1007912|41"] = 1,
            ["1007913|41"] = 1, ["1007914|41"] = 1, ["1007915|41"] = 1, ["1007916|41"] = 1,
            ["1007917|41"] = 1, ["1007918|41"] = 1, ["1007919|41"] = 1, ["1007920|41"] = 1,
            ["1007921|41"] = 1,
        }
    end
    local platformChannelId = ctx.PlatformChannleId
    return UtilsBase._reviewServerDict[platformChannelId] ~= nil
end

-- 获取子节点路径
function UtilsBase.GetChildPath(transform, nodeName)
    local tcc = transform.childCount - 1
    local rvl
    for i = 0, tcc do
        local it = transform.transform:GetChild(i)
        if it.childCount > 0 then
            if it.name == nodeName then
                return it.name
            end
            rvl = UtilsBase.GetChildPath(it, nodeName)
            if rvl ~= "" then
                return it.name.."/"..rvl
            end
        elseif it.name == nodeName then
                return it.name
        end
    end
    return ""
end