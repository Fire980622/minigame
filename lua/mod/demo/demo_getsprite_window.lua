-- 测试GetSprite方法
-- 设置Icon的几种方式

DemoGetSpriteWindow = DemoGetSpriteWindow  or BaseClass(BaseWindow)

function DemoGetSpriteWindow:__init(model)
    self.model = model
    self.name = "DemoGetSpriteWindow"
    self.icon3Path =  "Textures/Icon/Single/ItemIcon/20004.png";
    self.resList = {
        {path = AssetConfig.demo_window_prefab, type = AssetType.Prefab, holdTime = 63}
        ,{path = self.icon3Path, type = AssetType.Object, holdTime = 55}
    }

    self.icon1 = nil
    self.icon2 = nil
    self.icon3 = nil

    self.micon1 = nil
    self.micon2 = nil
    self.micon3 = nil

    self.closeBut = nil
    self.okBut = nil
    self.playBgmBut = nil

    self.miconLoader1 = nil
    self.miconLoader2 = nil
    self.miconLoader3 = nil
end

function DemoGetSpriteWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function DemoGetSpriteWindow:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.demo_window_prefab)
    self.gameObject.name = self.name
    self.gameObject:SetActive(false)
    UtilsUI.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.icon1 = self.gameObject.transform:Find("Window/ItemCon/Icon1").gameObject
    self.icon2 = self.gameObject.transform:Find("Window/ItemCon/Icon2").gameObject
    self.icon3 = self.gameObject.transform:Find("Window/ItemCon/Icon3").gameObject
    self.icon4 = self.gameObject.transform:Find("Window/ItemCon/Icon4").gameObject

    self.micon1 = self.gameObject.transform:Find("Window/ItemCon/MIcon1").gameObject
    self.micon2 = self.gameObject.transform:Find("Window/ItemCon/MIcon2").gameObject
    self.micon3 = self.gameObject.transform:Find("Window/ItemCon/MIcon3").gameObject

    -- 使用SingleIconLoader显示Icon，异步
    SingleIconLoader.New(self.icon1, "Textures/Icon/Single/ItemIcon/20002.png")
    SingleIconLoader.New(self.icon2, "Textures/Icon/Single/ItemIcon/20005.png")
    -- 使用AssetBatchLoader加载显示，同步
    self:SetIcon(self.icon3, self.icon3Path)

    -- 多图Icon
    self.miconLoader1 = MultipleIconLoader.New(self.micon1, {"Textures/Icon/Mutliple/Drop.png"}, "7")

    self.miconLoader2 = MultipleIconLoader.New(self.micon2, {"Textures/Icon/Mutliple/Task.png", "Textures/Icon/Single/ItemIcon/20002.png"}, "40001")

    self.miconLoader3 = MultipleIconLoader.New(self.micon3, {"Textures/Icon/Mutliple/Task.png", "Textures/Icon/Mutliple/Drop.png"}, "9")

    self.closeBut = self.gameObject.transform:Find("Window/CloseButton").gameObject
    self.closeBut:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnCloseButtonClick() end)

    self.okBut = self.gameObject.transform:Find("Window/BtnOneKeyLian").gameObject
    self.okBut:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnOkButClick() end)

    self.playBgmBut = self.gameObject.transform:Find("Window/BtnPlayBGM").gameObject
    self.playBgmBut:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnPlayBtnClick() end)

    self.gameObject:SetActive(true)
end

function DemoGetSpriteWindow:OnCloseButtonClick()
    self.model:CloseDemoSpriteWindow()
end

function DemoGetSpriteWindow:OnOkButClick()
    self.miconLoader1:SetIcon("8")
    self.miconLoader2:SetIcon("20002")
    self.miconLoader3:SetIcon("40005")
    PreloadManager.Instance:SetIcon(self.icon4, AssetConfig.demo_multiple_icon_task, "40007")

    AssetMgrProxy.Instance:ChangeSprite(self.okBut, "DefaultButton1")
end

function DemoGetSpriteWindow:OnPlayBtnClick()
    SoundManager.Instance:PlayBGM(403)
end
