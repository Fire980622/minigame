-- ---------------------------------
-- 道具格子
-- hosr
-- ---------------------------------
ItemSlot = ItemSlot or BaseClass(BaseView)

function ItemSlot:__init()
	self.clickListener = function() self:ClickSelf() end
	self.iconLoaded = function() self:IconLoadCallback() end
	self:Create()
end

function ItemSlot:__delete()
    GameObject.DestroyImmediate(self.gameObject)
end

function ItemSlot:Create()
	self.gameObject = SlotManager.Instance:GetSlot()
	self.transform = self.gameObject.transform
	self.transform:GetComponent(typeof(Button)).onClick:RemoveAllListeners()
	self.transform:GetComponent(typeof(Button)).onClick:AddListener(self.clickListener)
	-- 道具图标
	self.item = self.transform:Find("ItemImg").gameObject
	-- 道具品质
	self.quality = self.transform:Find("Quality").gameObject
	-- 锁定状态
	self.lock = self.transform:Find("Lock").gameObject
	-- 加号状态
	self.add = self.transform:Find("Add").gameObject
	self.num = self.transform:Find("Num").gameObject
	self.numTxt = self.transform:Find("Num/Text"):GetComponent(typeof(Text))

	self:Reset()
end

function ItemSlot:Reset()
	self.quality:SetActive(false)
	self.lock:SetActive(false)
	self.add:SetActive(false)
	self.num:SetActive(false)
	self.item:SetActive(false)
end

function ItemSlot:SetData(data)
	self:Reset()
	self.data = data
	local a = 20000 + math.random(4, 6)
	SingleIconLoader.New(self.item, string.format("Textures/Icon/Single/ItemIcon/%s.png", a), self.iconLoaded)
	-- if self.data == nil then
	-- 	self:Reset()
	-- 	return
	-- end
end

function ItemSlot:SetNum(num)
	self.numTxt.text = tostring(num)
	self.num:SetActive(num > 1)
end

function ItemSlot:ClickSelf()
end

function ItemSlot:IconLoadCallback()
	self.item:SetActive(true)
end