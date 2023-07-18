-- 翻页测试
-- hzf

DemoTabTestPanel = DemoTabTestPanel or BaseClass(BasePanel)

function DemoTabTestPanel:__init(model, parent)
    self.name = "DemoTabTestPanel"
    self.model = model
    self.parent = parent
    self.resList = {
        {path = AssetConfig.uitab_panel_prefab, type = AssetType.Prefab}
    }

end


function DemoTabTestPanel:__delete()
end

function DemoTabTestPanel:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.uitab_panel_prefab)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.transform:SetParent(self.parent.transform)
    self.transform.localPosition = Vector3.zero
    self.transform.localScale = Vector3.one
    local panel = self.transform:Find("MaskScroll").gameObject
    self.tabpage = TabbedPanel.New(panel, 4, 433)
    self.tabpage.MoveEndEvent:AddListener(
        function(page)
            print(page)
            -- for i=1,3 do
            --     self.ToggleGroup:Find(tostring(i)):GetComponent(typeof(Toggle)).isOn = (i==page)
            -- end
        end
    )
    panel.transform.anchoredPosition = Vector2(-207.28, -23.15001)
    -- self:LoadList()
end

function DemoTabTestPanel:LoadList()
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