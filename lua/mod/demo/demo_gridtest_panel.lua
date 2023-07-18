-- 网格布局测试
-- hzf

DemoGridTestPanel = DemoGridTestPanel or BaseClass(BasePanel)

function DemoGridTestPanel:__init(model, parent)
    self.name = "DemoGridTestPanel"
    self.model = model
    self.parent = parent
    self.resList = {
        {path = AssetConfig.uigrid_panel_prefab, type = AssetType.Prefab}
    }

end


function DemoGridTestPanel:__delete()
end

function DemoGridTestPanel:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.uigrid_panel_prefab)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.transform:SetParent(self.parent.transform)
    self.transform.localPosition = Vector3.zero
    self.transform.localScale = Vector3.one

    self.clone = self.transform:Find("MaskScroll/List/clone").gameObject
    self.clone.transform.sizeDelta = Vector2(228, 69)
    self.ListCon = self.transform:Find("MaskScroll/List")
    local setting1 = {
        column = 3
        ,cspacing = 0
        ,rspacing = 0
        ,cellSizeX = 228
        ,cellSizeY = 69
    }
    self.Layout1 = LuaGridLayout.New(self.ListCon, setting1)
    self:LoadList()
end

function DemoGridTestPanel:LoadList()
    for i=1, 15 do
        local item = GameObject.Instantiate(self.clone)
        local trans = item.transform
        trans:Find("Text"):GetComponent(typeof(Text)).text = string.format("第%s条", i)
        self.Layout1:AddCell(item)
    end
end