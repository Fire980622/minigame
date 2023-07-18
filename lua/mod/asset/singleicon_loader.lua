-- 单icon加载
SingleIconLoader = SingleIconLoader or BaseClass()

function SingleIconLoader:__init(gameObject, path, callback)
    self.path = path
    self.gameObject = gameObject
    self.callback = callback

    self.resList = {
        {path = self.path, type = AssetType.Object, holdTime = 56}
    }

    self.assetLoader = nil
    self:Load()
end

function SingleIconLoader:__delete()
    if self.assetLoader ~= nil then
        self.assetLoader:DeleteMe()
        self.assetLoader = nil
    end
end

function SingleIconLoader:Load()
    local callback = function()
        self:SetIcon()
    end
    self.assetLoader = AssetBatchLoader.New("SingleIconLoader[" .. self.path .. "]");
    self.assetLoader:AddListener(callback)
    self.assetLoader:LoadAll(self.resList)
end

function SingleIconLoader:SetIcon()
    local image = self.gameObject:GetComponent(typeof(Image))
    local autoReleaser = self.gameObject:GetComponent(typeof(IconAutoReleaser))
    if autoReleaser == nil then
        autoReleaser = self.gameObject:AddComponent(typeof(IconAutoReleaser))
    else
        if autoReleaser.path ~= nil or autoReleaser.path ~= "" then
            AssetMgrProxy.Instance:DecreaseReferenceCount(autoReleaser.path)
            image.sprite = nil
        end
    end
    autoReleaser.path = self.path
    AssetMgrProxy.Instance:IncreaseReferenceCount(self.path)
    image.sprite = self.assetLoader:Pop(self.path)
    if self.assetLoader ~= nil then
        self.assetLoader:DeleteMe()
        self.assetLoader = nil
    end
    self.path = nil
    self.gameObject = nil
    self.resList = nil

    if self.callback ~= nil then
        self.callback()
    end
end
