CombatWindow = CombatWindow or BaseClass(BaseWindow)
function CombatWindow:__init(mgr)
    self.mgr = mgr
    self.name = "CombatWindow"
    self.windowId = WindowConfig.WinID.combat_panel
    self.resList = {
        {path = AssetConfig.combat_window_prefab, type = AssetType.Prefab}
    }
    self.gameObject = nil
    self.transform = nil
end
function CombatWindow:InitPanel()

    self.gameObject = self:GetGameObject(AssetConfig.combat_window_prefab)
    self.gameObject.name = self.name
    UtilsUI.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(true)
end
 
function CombatWindow:Show()
    self:Open()
    if self.combat_panel==nil then
        self.combat_panel=CombatPanel.New(self)
    end
    self.combat_panel:Show(args)
end 

