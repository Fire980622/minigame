-- demo窗口
DemoWindow = DemoWindow or BaseClass(BaseWindow)

function DemoWindow:__init(model)
    self.model = model
    self.name = "DemoWindow"
    self.resList = {
        {path = AssetConfig.demo_window_prefab, type = AssetType.Prefab}
    }
    self.itemList = {}
    self.index = 5
end

function DemoWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function DemoWindow:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.demo_window_prefab)
    self.gameObject.name = self.name
    self.gameObject:SetActive(false)
    UtilsUI.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBut = self.gameObject.transform:Find("Window/CloseButton").gameObject
    self.closeBut:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnCloseButtonClick() end)
    self.gameObject:SetActive(true)

    self.transform:Find("Window/BtnOneKeyLian"):GetComponent(typeof(Button)).onClick:AddListener(function() self:Click() end)

    for i = 1, 5 do
        local slot = ItemSlot.New()
        slot.transform:SetParent(self.gameObject.transform)
        slot.transform.localScale = Vector3.one
        slot.transform.localPosition = Vector3((i - 1) * 75, 0, 0)
        table.insert(self.itemList, slot)
    end
end

function DemoWindow:OnCloseButtonClick()
    self.model:CloseDemoWindow()
end

function DemoWindow:Click()
    local slot = table.remove(self.itemList, self.index)
    GameObject.DestroyImmediate(slot.gameObject)
    self.index = self.index - 1
end