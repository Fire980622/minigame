-- -----------------------------
-- 暂时用来预加载slot的预设
-- hosr
-- -----------------------------
SlotManager = SlotManager or BaseClass()

function SlotManager:__init()
	if SlotManager.Instance then
		return
	end
	SlotManager.Instance = self

	self.assetLoader = nil
	self.resList = {
		{path = AssetConfig.item_slot, type = AssetType.Object}
	}
	self.callback = function() self:OnLoad() end

	-- 缓存itemslot预设资源
	self.asset = nil
	self:PreLoad()
end

function SlotManager:PreLoad()
	if self.assetLoader == nil then
		self.assetLoader = AssetBatchLoader.New("SlotManagerLoader");
	end
    self.assetLoader:AddListener(self.callback)
    self.assetLoader:LoadAll(self.resList)
end

function SlotManager:OnLoad()
	self.asset = self.assetLoader:Pop(AssetConfig.item_slot)
	AssetMgrProxy.Instance:IncreaseReferenceCount(AssetConfig.item_slot)
end

function SlotManager:GetSlot()
	if self.asset == nil then
		print(AssetConfig.item_slot .. " 未加载")
		return
	end
	
    local go = AssetMgrProxy.Instance:CloneGameObject(self.asset)
    return go

	-- AssetMgrProxy.Instance:IncreaseReferenceCount(AssetConfig.item_slot)
	-- local gameObject = GameObject.Instantiate(self.asset)
	-- local script = gameObject:GetComponent(typeof(AssetAutoReleaser))
	-- script:Add(AssetConfig.item_slot)
	-- return gameObject
end
