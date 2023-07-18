-- 循环列表测试
-- hzf

DemoCycleTestPanel = DemoCycleTestPanel or BaseClass(BasePanel)

function DemoCycleTestPanel:__init(model, parent)
    self.name = "DemoCycleTestPanel"
    self.model = model
    self.parent = parent
    self.resList = {
        {path = AssetConfig.uicyclescroll_panel_prefab, type = AssetType.Prefab}
    }
    self.lastcheck = Time.time
    self.cachdata = {}
    self.index = 0
end


function DemoCycleTestPanel:__delete()
end

function DemoCycleTestPanel:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.uicyclescroll_panel_prefab)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.transform:SetParent(self.parent.transform)
    self.transform.localPosition = Vector3.zero
    self.transform.localScale = Vector3.one
    self.MaskScroll = self.transform:Find("MaskScroll")
    self.List = self.transform:Find("MaskScroll/List")
    self.item_list = {}
    local num = self.List.childCount
    for i=1,num do
        local go = self.List:GetChild(i-1).gameObject
        local item = {}
        item.gameObject = go
        item.transform = go.transform
        item.str = go.transform:Find("Text"):GetComponent(typeof(Text))
        table.insert(self.item_list, item)
    end
    self.setting_data = {
       item_list = self.item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.List  --item列表的父容器
       ,single_item_height = self.item_list[1].transform:GetComponent(typeof(RectTransform)).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.List:GetComponent(typeof(RectTransform)).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.MaskScroll:GetComponent(typeof(RectTransform)).sizeDelta.y--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
       ,set_item_func = function(item, data, index)
           self:SetItem(item, data, index)
       end
    }
    self.vScroll = self.MaskScroll:GetComponent(typeof(ScrollRect))
    self.vScroll.onValueChanged:AddListener(function()
        LuaCycleList.on_value_change(self.setting_data)
    end)
    self.vScroll.onValueChanged:AddListener(function()
        self:CheckCachData()
    end)
    LuaCycleList.refresh_circular_list(self.setting_data)
    self:UpdateLiveData()
end

function DemoCycleTestPanel:SetItem(item, data, index)
    item.str.text = data.str
end

function DemoCycleTestPanel:UpdateLiveData()
    if self.gameObject == nil or self.index > 20 then
        return
    end
    self.index = self.index + 1
    TimerManager.Add(Random.Range(500, 800), function()
        self:UpdateLiveData()
    end)
    local temp = {index = self.index, str = string.format("<color='#%s6%s70%s'>这是第%s条数据</color>", Random.Range(0, 9), Random.Range(0, 9), Random.Range(0, 9), self.index), isfight = Random.Range(0,1)}
    if self.List:GetComponent(typeof(RectTransform)).anchoredPosition.y > 70 then
        table.insert(self.cachdata, temp)
        return
    end
    table.insert(self.setting_data.data_list, temp)
    table.sort(self.setting_data.data_list, function(a, b)
        return a.index > b.index
    end)
    -- LuaCycleList.static_refresh_circular_list(self.setting_data)
    LuaCycleList.refresh_circular_list(self.setting_data)
end


function DemoCycleTestPanel:CheckCachData(force)
    if not force and (Time.time - self.lastcheck < 0.3 or self.List:GetComponent(typeof(RectTransform)).anchoredPosition.y > 70) then
        return
    end
    self.lastcheck = Time.time
    if #self.cachdata > 0 then
        for k,v in pairs(self.cachdata) do
            table.insert(self.setting_data.data_list, v)
        end
    else
        return
    end
    self.cachdata = {}
    table.sort(self.setting_data.data_list, function(a, b)
        return a.index > b.index
    end)
    LuaCycleList.refresh_circular_list(self.setting_data)
end