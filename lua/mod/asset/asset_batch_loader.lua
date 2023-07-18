-- 多资源加载
-- @author huangyq
AssetBatchLoader = AssetBatchLoader or BaseClass()

function AssetBatchLoader:__init(name)
    self.name = name
    -- 优先级不同的使用分帧加载
    -- {{path, type, callback, priority, asset}}
    self.resList = {}
    self.resDict = {}

    -- 根据优先级分级的资源
    -- {{index = X, list = {}}}
    self.resPList ={{}}

    self.eventLib = nil
    self.isLoading = false

    self.isCancel = false
end

function AssetBatchLoader:__delete()
    if self.isLoading then
        self.isCancel =true
        -- print(debug.traceback())
        -- Log.Error("非法操作，资源正在加载中")
    end
    self.resPList = nil
    for _, data in ipairs(self.resList) do
        if data.asset ~= nil then
            AssetManager.DecreaseReferenceCount(data.path)
            if data.type == AssetType.Prefab then
                -- GameObject.DestroyImmediate(data.asset)
            end
        end
    end
    self.resList = nil

    if self.eventLib ~= nil then
        self.eventLib:DeleteMe()
        self.eventLib = nil
    end
end

function AssetBatchLoader:AddListener(callback, priority)
    if priority == nil then
        priority = 1
    end
    local event = self:GetEvent(priority)
    event:AddListener(callback)
end

function AssetBatchLoader:RemoveListener(callback, priority)
    if priority == nil then
        priority = 1
    end
    local event = self:GetEvent(priority)
    event:RemoListener(callback)
end

function AssetBatchLoader:LoadAll(list)
    self.resList = UtilsBase.copytab(list)
    for _, data in ipairs(self.resList) do
        self.resDict[data.path] = true
        if data.priority == nil then
            data.priority = 1
        end
    end
    self.resPList = self:Grouping()
    if #self.resPList > 0 then
        self:LoadAssetByPriority()
    end
end

function AssetBatchLoader:LoadAssetByPriority()
    if #self.resPList > 0 then
        local pCell = self.resPList[1]
        table.remove(self.resPList, 1)
        self.isLoading = true
        for _, data in ipairs(pCell.list) do
            local cdata = data
            local holdTime = data.holdTime
            -- 设置默认值
            local loadType = AssetLoadType.BothAsync

            if holdTime == nil then
                -- 缓存时间默认30秒
                -- 这个时间是以引用数变为0时开始算
                holdTime = 30
            end
            if data.loadType ~= nil then
                loadType = data.loadType
            end

            if data.type == AssetType.Prefab then
                local cb = function(go)
                    self:OnGameObjectLoaded(go, cdata)
                end
                AssetManager.GetGameObject(data.path, holdTime, cb, 5, loadType)
            elseif data.type == AssetType.Object then
                local cb = function(go)
                    self:OnObjectLoaded(go, cdata)
                end
                AssetManager.GetObject(data.path, holdTime, cb, 5, loadType)
            elseif data.type == AssetType.Asset then
                local cb = function(path)
                    self:OnAssetLoaded(path, cdata)
                end
                AssetManager.GetAsset(data.path, holdTime, cb, 5, loadType)
            end
        end
    end
end

function AssetBatchLoader:Grouping()
    local gDict = {}
    for _, data in ipairs(self.resList) do
        local gCell = gDict[data.priority]
        if gCell == nil then
            gCell = {index = data.priority, list = {}}
            gDict[data.priority] = gCell
        end
        table.insert(gCell.list, data)
    end
    local gList = {}
    for _, data in pairs(gDict) do
        table.insert(gList, data)
    end
    local sortfun = function(a,b)
        return a.index < b.index
    end
    table.sort(gList, sortfun)
    return gList
end

function AssetBatchLoader:OnGameObjectLoaded(obj, ldata)
    local completed = true
    if self.resList == nil then
        return
    end
    for _, data in ipairs(self.resList) do
        if data.path == ldata.path then
            data.asset = obj
            AssetManager.IncreaseReferenceCount(data.path)
            if data.callback ~= nil then
                data.callback(data.path)
            end
        elseif data.asset == nil and data.priority == ldata.priority then
            completed = false
        end
    end
    if completed then
        if self.isCancel then
            self.isLoading = false
            self:DeleteMe()
            return
        end
        if self.eventLib ~= nil then
            self.isLoading = false
            self.eventLib:Fire()
        end
    end
    if self.resList ~= nil and #self.resPList > 0 then
        self:LoadAssetByPriority()
    end
end

function AssetBatchLoader:OnObjectLoaded(obj, ldata)
    local completed = true
    if self.resList == nil then
        return
    end
    for _, data in ipairs(self.resList) do
        if data.path == ldata.path then
            data.asset = obj
            AssetManager.IncreaseReferenceCount(data.path)
            if data.callback ~= nil then
                data.callback(data.path)
            end
        elseif data.asset == nil and data.priority == ldata.priority then
            completed = false
        end
    end
    if completed then
        if self.isCancel then
            self.isLoading = false
            self:DeleteMe()
            return
        end
        if self.eventLib ~= nil then
            self.isLoading = false
            self.eventLib:Fire()
        end
    end
    if self.resList ~= nil and #self.resPList > 0 then
        self:LoadAssetByPriority()
    end
end

function AssetBatchLoader:OnAssetLoaded(path, ldata)
    local completed = true
    if self.resList == nil then
        return
    end
    for _, data in ipairs(self.resList) do
        if data.path == ldata.path then
            data.asset = path
            AssetManager.IncreaseReferenceCount(data.path)
            if data.callback ~= nil then
                data.callback(data.path)
            end
        elseif data.asset == nil and data.priority == ldata.priority then
            completed = false
        end
    end
    if completed then
        if self.isCancel then
            self.isLoading = false
            self:DeleteMe()
            return
        end
        if self.eventLib ~= nil then
            self.isLoading = false
            self.eventLib:Fire()
        end
    end
    if self.resList ~= nil and #self.resPList > 0 then
        self:LoadAssetByPriority()
    end
end

function AssetBatchLoader:GetEvent()
    if self.eventLib == nil then
        self.eventLib = EventLib.New()
    end
    return self.eventLib
end

function AssetBatchLoader:Grouping()
    local gDict = {}
    for _, data in ipairs(self.resList) do
        local gCell = gDict[data.priority]
        if gCell == nil then
            gCell = {index = data.priority, list = {}}
            gDict[data.priority] = gCell
        end
        table.insert(gCell.list, data)
    end
    local gList = {}
    for _, data in pairs(gDict) do
        table.insert(gList, data)
    end
    local sortfun = function(a,b)
        return a.index < b.index
    end
    table.sort(gList, sortfun)
    return gList
end

-- 拿出资源
function AssetBatchLoader:Pop(path, parent)
    if self.isLoading then
        Log.Error("非法操作，资源正在加载中不可拿出数据")
    end
    for _, data in ipairs(self.resList) do
        if data.path == path then
            AssetManager.DecreaseReferenceCount(path)
            local asset = data.asset
            if data.type == AssetType.Prefab then
                if UtilsBase.IsNull(asset) then
                    Log.Error("非法操作，资源已被取出，或资源为空".. data.path)
                end
                local gameObject = GameObject.Instantiate(asset, parent)
                AssetManager.AddAssetAutoReleaser(gameObject, data.path)
                data.asset = nil
                return gameObject
            else
                data.asset = nil
                return asset
            end
        end
    end
end

function AssetBatchLoader:Contain(path)
    if self.resDict[path] == nil then
        return false
    else
        return true
    end
end
