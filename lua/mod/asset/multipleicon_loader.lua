-- 使用Icon图集显示Icon
-- Icon是特殊的资源，可以使用sprite直接属值，而图集内部的图片则不可以（UI的图集不同平方使用的策略不一样）
-- @author huangyq
MultipleIconLoader = MultipleIconLoader or BaseClass()

function MultipleIconLoader:__init(gameObject, pathList, defaultName)
    self.gameObject = gameObject
    self.pathList = pathList
    self.defaultName = defaultName

    self.resList = {}

    for _, path in ipairs(self.pathList) do
        table.insert(self.resList, {path = path, type = AssetType.Asset, holdTime = 77})
    end
    self.assetLoader = nil

    -- <name, path>
    self.spriteDict = nil
    self:Load()
end

function MultipleIconLoader:__delete()
    if self.assetLoader ~= nil then
        self.assetLoader:DeleteMe()
        self.assetLoader = nil
    end
    if not UtilsBase.IsNull(self.gameObject) then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function MultipleIconLoader:Load()
    local callback = function()
        self:InitDict()
    end
    self.assetLoader = AssetBatchLoader.New("MultipleIconLoader");
    self.assetLoader:AddListener(callback)
    self.assetLoader:LoadAll(self.resList)
end

function MultipleIconLoader:InitDict()
    local autoReleaser = self.gameObject:GetComponent(typeof(AssetAutoReleaser))
    if autoReleaser ~= nil then
        Log.Error("AssetAutoReleaser冲突, GameObject已经存在AssetAutoReleaser组件")
    end
    self.spriteDict = {}
    autoReleaser = self.gameObject:AddComponent(typeof(AssetAutoReleaser))
    for _, path in ipairs(self.pathList) do
        autoReleaser:Add(path)
        AssetManager.IncreaseReferenceCount(path)

        local nameList = AssetManager.GetSubObjectNames(path)
        local count = nameList.Count
        for i = 0, count - 1 do
            if self.spriteDict[nameList[i]] ~= nil then
                Log.Error("MIconAutoReleaser子名字冲突[" .. nameList[i] .. "]")
            end
            self.spriteDict[nameList[i]] = path
            if self.defaultName ~= nil and self.defaultName == nameList[i] then
                self.gameObject:GetComponent(typeof(Image)).sprite = AssetManager.GetSubObject(path, nameList[i])
            end
        end
    end
    self.assetLoader:DeleteMe()
    self.assetLoader = nil
end

function MultipleIconLoader:SetIcon(name)
    if self.spriteDict == nil then
        Log.Error("MIconAutoReleaser还没初始化完")
        self.defaultName = name
    else
        if self.spriteDict[name] ~= nil then
            self.gameObject:GetComponent(typeof(Image)).sprite = AssetManager.GetSubObject(self.spriteDict[name], name)
        else
            Log.Error("MIconAutoReleaser找不到子资源信息[" .. name .. "]")
        end
    end
end
