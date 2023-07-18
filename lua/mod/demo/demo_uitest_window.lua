-- UI测试demo窗口
-- hzf

UITestWindow = UITestWindow or BaseClass(BaseWindow)

function UITestWindow:__init(model)
    self.model = model
    self.name = "UITestWindow"
    self.resList = {
        {path = AssetConfig.uitest_window_prefab, type = AssetType.Prefab}
    }
end

function UITestWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function UITestWindow:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.uitest_window_prefab)
    self.gameObject.name = self.name
    self.gameObject:SetActive(false)
    self.transform = self.gameObject.transform
    UtilsUI.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.closeBut = self.gameObject.transform:Find("Window/CloseButton").gameObject
    self.closeBut:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnCloseButtonClick() end)
    self.gameObject:SetActive(true)

    self.ChildContent = self.transform:Find("Window/Con")
    self.tabpanelList = {
        [1] = DemoGridTestPanel.New(self.model, self.ChildContent),
        [2] = DemoHVTestPanel.New(self.model, self.ChildContent),
        [3] = DemoTabTestPanel.New(self.model, self.ChildContent),
        [4] = DemoCycleTestPanel.New(self.model, self.ChildContent),
        [5] = DemoTweenTestPanel.New(self.model, self.ChildContent),
        [6] = DemoPreviewTestPanel.New(self.model, self.ChildContent),
    }
    self.tabgroup = TabGroup.New(self.transform:Find("Window/TabButtonGroup").gameObject, function (tab) self:OnTabChange(tab) end)
end

function UITestWindow:OnCloseButtonClick()
    self.model:CloseUITestWindow()
end

function UITestWindow:OnTabChange(index)
    for k,v in pairs(self.tabpanelList) do
        if k ~= index then
            v:Hiden()
        else
            v:Show()
        end
    end
end