-- 测试地图
DemoScenceElement = DemoScenceElement or BaseClass()

function DemoScenceElement:__init()
    self.mapPath = string.format(AssetConfig.demo_map_path, "0", "1")
    self.resList = {
        {path = AssetConfig.demo_scence_element_path, type = AssetType.Prefab}
        ,{path = self.mapPath, type = AssetType.Object}
    }

    self.assetLoader = nil
    self.gameObject = nil
end

function DemoScenceElement:__delete()
end

function DemoScenceElement:Init()
    self.assetLoader = AssetBatchLoader.New("DemoScenceElement")
    local callback = function()
        self:OnResLoadCompleted()
    end
    self.assetLoader:AddListener(callback)
    self.assetLoader:LoadAll(self.resList)
end

function DemoScenceElement:OnResLoadCompleted()
    self.gameObject = self.assetLoader:Pop(AssetConfig.demo_scence_element_path)
    local mainTexture = self.assetLoader:Pop(self.mapPath)
    local autoReleaser = self.gameObject:GetComponent(typeof(AssetAutoReleaser))
    local mapCell = self.gameObject.transform:Find("Map/1").gameObject
    mapCell:GetComponent(typeof(Renderer)).sharedMaterial.mainTexture = mainTexture
    AssetMgrProxy.Instance:IncreaseReferenceCount(self.mapPath)
    autoReleaser:Add(self.mapPath)
end
