CombatPanel=CombatPanel or BaseClass(BasePanel)
function CombatPanel:__init(window)
    self.window = window
    -- Panel信息
    self.name = "CombatPanel"
    self.mgr = CombatManager.Instance
    self.model=self.mgr.model
    self.resList = {
        {path = AssetConfig.combat_panel, type = AssetType.Prefab}
    }
    self.gameObject=nil
end
function CombatPanel:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.combat_panel)
    self.gameObject.name = self.name
    UtilsUI.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(true)
    self.Main=self.transform:Find("Main")
    self.ground=self.transform:Find("Ground")
    self.btn = self.transform:Find("Button"):GetComponent(typeof(Button))
    self.btn.onClick:AddListener(function() 
        self:OnStart() end)
    self.BronPoint=self.transform:Find("bronPoint")
    self:OnStart()

end
function CombatPanel:OnHide()

end
function CombatPanel:OnStart()
    PlayerController.New(self.BronPoint)
   
end

function CombatPanel:OnShow()
    self.isShow=true
end