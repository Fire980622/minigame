-- 纵横布局测试
-- hzf

DemoHVTestPanel = DemoHVTestPanel or BaseClass(BasePanel)

function DemoHVTestPanel:__init(model, parent)
    self.name = "DemoHVTestPanel"
    self.model = model
    self.parent = parent
    self.resList = {
        {path = AssetConfig.uihv_panel_prefab, type = AssetType.Prefab}
    }

end


function DemoHVTestPanel:__delete()
end

function DemoHVTestPanel:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.uihv_panel_prefab)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.transform:SetParent(self.parent.transform)
    self.transform.localPosition = Vector3.zero
    self.transform.localScale = Vector3.one

    self.cloneH = self.transform:Find("cloneH").gameObject
    self.cloneV = self.transform:Find("cloneV").gameObject
    self.HListCon = self.transform:Find("MaskScrollH/List")
    self.VListCon = self.transform:Find("MaskScrollV/List")
    self.HScrollRect = self.transform:Find("MaskScrollH")
    self.VScrollRect = self.transform:Find("MaskScrollV")

    self.VLayout = LuaBoxLayout.New(self.VListCon, {axis = BoxLayoutAxis.Y, cspacing = 0, scrollRect = self.VScrollRect, Left = 8})
    self.HLayout = LuaBoxLayout.New(self.HListCon, {axis = BoxLayoutAxis.X, cspacing = 0, scrollRect = self.HScrollRect})
    self:LoadList()
end

function DemoHVTestPanel:LoadList()
    for i=1, 20 do
        local item = GameObject.Instantiate(self.cloneH)
        local trans = item.transform
        trans:Find("Text"):GetComponent(typeof(Text)).text = string.format("第%s条", i)
        self.HLayout:AddCell(item)
    end
    for i=1, 20 do
        local item = GameObject.Instantiate(self.cloneV)
        local trans = item.transform
        trans:Find("Text"):GetComponent(typeof(Text)).text = string.format("第%s条", i)
        self.VLayout:AddCell(item)
    end
end