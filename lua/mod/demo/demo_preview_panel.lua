
-- 网格布局测试
-- hzf

DemoPreviewTestPanel = DemoPreviewTestPanel or BaseClass(BasePanel)

function DemoPreviewTestPanel:__init(model, parent)
    self.name = "DemoPreviewTestPanel"
    self.model = model
    self.parent = parent
    self.resList = {
        {path = AssetConfig.uipreview_panel_prefab, type = AssetType.Prefab}
    }
    self.preview_loaded = function (texture, modelDataList)
        self:PreviewLoaded(texture, modelDataList)
    end
    self.OnHideEvent:Add(function()
        self:OnHide()
    end)
    -- 窗口打开事件
    self.OnOpenEvent:Add(function()
        self:OnShow()
    end)
end


function DemoPreviewTestPanel:__delete()
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
    end
end

function DemoPreviewTestPanel:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.uipreview_panel_prefab)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.transform:SetParent(self.parent.transform)
    self.transform.localPosition = Vector3.zero
    self.transform.localScale = Vector3.one

    self.Target = self.transform:Find("Target")
    Tween.Instance:MoveLocalY(self.Target.gameObject, self.Target.localPosition.y - 30, 0.7, function() end, LeanTweenType.easeInOutQuad):setLoopPingPong()

    self.transform:Find("Button"):GetComponent(typeof(Button)).onClick:AddListener(function()
        self:DoHorizontal()
    end)
    self.transform:Find("Button (1)"):GetComponent(typeof(Button)).onClick:AddListener(function()
        self:DoRotate()
    end)
    self.transform:Find("Button (2)"):GetComponent(typeof(Button)).onClick:AddListener(function()
        self:DoScale()
    end)

    self:LoadPreview()
end

function DemoPreviewTestPanel:OnHide()
    if self.previewComp1~= nil then
        self.previewComp1:Hide()
    end
end

function DemoPreviewTestPanel:OnShow()
    if self.previewComp1~= nil then
        self.previewComp1:Show()
    end
end


function DemoPreviewTestPanel:LoadPreview()
    local unit_data = {id = 71004, name = "地狱熔魔", name_color = "#ff0000", type = 6, fun_type = 1, animation_id = 71006, res = 71006, show_blood = 1, res_type = 1, skin = 71006, lev = 70, sex = 2, classes = 0, speed = 0, looks = {{52,2,103,""}}, data_cli = "", buttons = {{button_id = 29,button_args = {1},button_desc = "击杀熔魔",button_show = "[]"},{button_id = 22,button_args = {1,14,1},button_desc = "便捷组队",button_show = "[]"}}, plot_talk = "体型意味着力量！", forward = 0, rand_forward = {}, scale = 160, sounds_id = 0, effects = {{effect_id = 100600}}, honorid = 0, honor_text = "70级世界BOSS", map_text = "", collider = {}}

    local setting = {
        name = "DemoPreviewTestPanel"
        ,L = -0.1
        ,R = 0.2
        ,B = -0.2
        ,T = 0.2
        ,parent = self.transform:Find("bg")
        ,localPos = Vector3(0, 0, -400)
    }
    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1}
    self.previewComp1 = PreviewModel.New(self.preview_loaded, setting, modelData)
end

function DemoPreviewTestPanel:PreviewLoaded(composite)
    -- self.rawImage = composite.rawImage
    -- if self.rawImage ~= nil then
    --     self.rawImage.transform:SetParent(self.transform)
    --     self.rawImage.transform.localPosition = Vector3(0, 0, 0)
    --     self.rawImage.transform.localScale = Vector3(1, 1, 1)
    --     -- self.preview.texture = rawImage.texture
    -- end
    -- composite.tpose.transform.position = self.transform.position + Vector3(0,0,-1)
    if self.transform == nil then
        return
    end
end

function DemoPreviewTestPanel:DoHorizontal()
    if self.rawImage ~= nil then
        if self.modeltween ~= nil then
            Tween.Instance:Cancel(self.modeltween.id)
            self.modeltween = nil
        end
        self.rawImage.transform.localPosition = Vector3.zero
        self.modeltween = Tween.Instance:MoveLocalX(self.rawImage.gameObject, self.rawImage.transform.localPosition.x - 60, 0.7, function() end, LeanTweenType.easeInOutQuad):setLoopPingPong()
    end
end

function DemoPreviewTestPanel:DoRotate()
    if self.rawImage ~= nil then
        if self.modeltween ~= nil then
            Tween.Instance:Cancel(self.modeltween.id)
            self.modeltween = nil
        end
        self.rawImage.transform.localPosition = Vector3.zero
        self.modeltween = Tween.Instance:Rotate(self.previewComp1.tpose, Vector3.one*179, 0.5, function() end, LeanTweenType.easeInOutQuad):setLoopPingPong()
    end
end


function DemoPreviewTestPanel:DoScale()
    if self.rawImage ~= nil then
        if self.modeltween ~= nil then
            Tween.Instance:Cancel(self.modeltween.id)
            self.modeltween = nil
        end
        self.rawImage.transform.localPosition = Vector3.zero
        self.rawImage.transform.localScale = Vector3(1, 1, 1)
        self.modeltween = Tween.Instance:Scale(self.rawImage.gameObject, Vector3.one*0.2, 0.7, function() end, LeanTweenType.easeInOutQuad):setLoopPingPong()
    end
end