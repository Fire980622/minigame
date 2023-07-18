GmWindow = GmWindow or BaseClass(BaseWindow)

function GmWindow:__init(model)
    self.model = model
    self.name = "DemoLayoutWindow"
    self.resList = {
        {path = AssetConfig.gm_window, type = AssetType.Prefab}
    }

    self.closeButton = nil

    self.typeContainer = nil
    self.typeCloner = nil
    self.cmdContainer = nil
    self.cmdCloner = nil

    self.typeGrid = nil
    self.cmdGrid = nil

    self.cmd = GmManager.Instance.cmd
    self.list = GmManager.Instance.list

    self.gmDataList = {
        {"CreateSomeRole 10"},{"CreateSomeNpc 10"},
        {"gm 预设的GM命令1","gm 预设的GM命令2","gm 预设的GM命令3"},
        {"gm 预设的GM命令4","gm 预设的GM命令5","gm 预设的GM命令6"},
    }
    self.itemDic = {}
    self.isShowHisPanel = false
end

function GmWindow:__delete()
    if self.typeGrid == nil then
        self.typeGrid:DeleteMe()
        self.typeGrid = nil
    end
    if self.cmdGrid == nil then
        self.cmdGrid:DeleteMe()
        self.cmdGrid = nil
    end
end

function GmWindow:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.gm_window)
    self.gameObject.name  =  "GmWindow"
    self.transform = self.gameObject.transform
    UtilsUI.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.closeButton = self.gameObject.transform:Find("Window/Close").gameObject
    self.closeButton:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnCloseButtonClick() end)

    self.typeContainer = self.gameObject.transform:Find("Window/TypePanel/Container").gameObject
    self.typeCloner = self.typeContainer.transform:Find("Cloner").gameObject
    self.cmdContainer = self.gameObject.transform:Find("Window/CmdPanel/Container").gameObject
    self.cmdCloner = self.cmdContainer.transform:Find("Cloner").gameObject
    self.memoryPanel = self.transform:Find("Window/CmdPanel/MemoryPanel")

    local setting = {
        column = 6
        ,bordertop = 5
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 104.5
        ,cellSizeY = 31.5
    }
    self.typeGrid = LuaGridLayout.New(self.typeContainer, setting)

    setting = {
        column = 3
        ,bordertop = 5
        ,borderleft = 10
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 201.8
        ,cellSizeY = 43.3
    }
    self.cmdGrid = LuaGridLayout.New(self.cmdContainer, setting)

    self:InitTypePanel()

    self.consolePanel = self.gameObject.transform:Find("Window/ConsolePanel").gameObject
    self.consoleInputField = self.consolePanel.transform:Find("Cloner/InputField").gameObject:GetComponent(typeof(InputField))
    self.hisPanel = self.consolePanel.transform:Find("HistoryPanel").gameObject
    local layoutContainer = self.hisPanel.transform:Find("ScrollPanel/Grid")
    self.layout_1 = LuaBoxLayout.New(layoutContainer.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 2})
    self.item = layoutContainer:Find("Item").gameObject
    self.item:SetActive(false)
    self.hisPanel:SetActive(false)
    self.isShowHisPanel = false
    -- self.consoleInputField.onEndEdit:AddListener(function()
    --         self.cmd:Run(self.consoleInputField.text)
    --         -- self.consoleInputField.text = ""
    --     end)
    self.consolePanel.transform:Find("Cloner/Submit"):GetComponent(typeof(Button)).onClick:AddListener(
        function()
            self.cmd:Run(self.consoleInputField.text)
            -- self.consoleInputField.text = ""
            self:CheckNeedAdd(self.consoleInputField.text)
        end
    )
    self.consolePanel.transform:Find("Cloner/More"):GetComponent(typeof(Button)).onClick:AddListener(
        function()
            if self.isShowHisPanel == false then
                self.isShowHisPanel = true
                self.hisPanel:SetActive(true)
                self:UpdateHisPanel()
            else
                self.isShowHisPanel = false
                self.hisPanel:SetActive(false)
            end
        end
    )
end

function GmWindow:CheckNeedAdd(txt)
    local isNeed = true
    for i,v in ipairs(self.gmDataList) do
        for j,value in ipairs(v) do
            if value == txt then
                isNeed = false
                break
            end
        end
        if isNeed == false then
            break
        end
    end
    if isNeed == true then
        if #self.gmDataList[1] == 3 then
            local newData = {}
            table.insert(newData,self.consoleInputField.text)
            table.insert(self.gmDataList,1,newData)
        else
            table.insert(self.gmDataList[1],self.consoleInputField.text)
        end
        if self.isShowHisPanel == true then
            self:UpdateHisPanel()
        end
    end
end

function GmWindow:UpdateHisPanel()
    for i,v in pairs(self.itemDic) do
        if v.thisObj ~= nil then
            GameObject.DestroyImmediate(v.thisObj)
        end
    end
    self.layout_1:ReSet()
    self.itemDic = {}
    for i,v in pairs(self.gmDataList) do
        local itemTemp = self.itemDic[i]
        if itemTemp == nil then
            local obj = GameObject.Instantiate(self.item)
            obj.name = tostring(i)

            local itemTable = {
                index = i,
                thisObj = obj,
                btn_1 = obj.transform:Find("Btn_1"):GetComponent(typeof(Button)),
                txt_1 = obj.transform:Find("Btn_1/Text"):GetComponent(typeof(Text)),
                btn_2 = obj.transform:Find("Btn_2"):GetComponent(typeof(Button)),
                txt_2 = obj.transform:Find("Btn_2/Text"):GetComponent(typeof(Text)),
                btn_3 = obj.transform:Find("Btn_3"):GetComponent(typeof(Button)),
                txt_3 = obj.transform:Find("Btn_3/Text"):GetComponent(typeof(Text)),
            }
            self.layout_1:AddCell(obj)

            self.itemDic[i] = itemTable
            itemTemp = itemTable
            itemTemp.btn_1.onClick:AddListener(
                function()
                    self.cmd:Run(itemTemp.txt_1.text)
                end
            )
            itemTemp.btn_2.onClick:AddListener(
                function()
                    self.cmd:Run(itemTemp.txt_2.text)
                end
            )
            itemTemp.btn_3.onClick:AddListener(
                function()
                    self.cmd:Run(itemTemp.txt_3.text)
                end
            )
        end
        itemTemp.thisObj:SetActive(true)
        itemTemp.value = v
        self:updateItemBtn(itemTemp)
    end
end

function GmWindow:updateItemBtn(item)
    if item.value[1] ~= nil then
        item.btn_1.gameObject:SetActive(true)
        item.txt_1.text = item.value[1]
    else
        item.btn_1.gameObject:SetActive(false)
    end
    if item.value[2] ~= nil then
        item.btn_2.gameObject:SetActive(true)
        item.txt_2.text = item.value[2]
    else
        item.btn_2.gameObject:SetActive(false)
    end
    if item.value[3] ~= nil then
        item.btn_3.gameObject:SetActive(true)
        item.txt_3.text = item.value[3]
    else
        item.btn_3.gameObject:SetActive(false)
    end
end

function GmWindow:InitTypePanel()
    for key, _ in pairs(self.list) do
        local cell = GameObject.Instantiate(self.typeCloner)
        cell.transform:Find("Text"):GetComponent(typeof(Text)).text = key
        cell:GetComponent(typeof(Button)).onClick:AddListener(function() self:OnTypeButClick(key) end)
        self.typeGrid:AddCell(cell)
    end
    local cell = GameObject.Instantiate(self.typeCloner)
    cell.transform:Find("Text"):GetComponent(typeof(Text)).text = TI18N("内存信息")
    cell:GetComponent(typeof(Button)).onClick:AddListener(function() self:OpenMemoryInfo(key) end)
    self.typeGrid:AddCell(cell)
end

function GmWindow:OnCloseButtonClick()
    WindowManager.Instance:CloseWindow(self)
end

function GmWindow:OnTypeButClick(key)
    self.memoryPanel.gameObject:SetActive(false)
    self.cmdContainer:SetActive(true)
    self.cmdGrid:Clear()
    local list = self.list[key]
    if list ~= nil then
        for _, data in ipairs(list) do
            local cell = GameObject.Instantiate(self.cmdCloner)
            cell.transform:Find("Text"):GetComponent(typeof(Text)).text = data.desc
            local inputField = cell.transform:Find("InputField").gameObject
            -- local text = inputField.transform:Find("Text"):GetComponent(typeof(Text))
            local text = inputField.transform:GetComponent(typeof(InputField))
            local hasParam = true
            if string.find(data.command,"{param}") == nil then
                inputField:SetActive(false)
                hasParam = false
            end
            cell.transform:Find("Submit"):GetComponent(typeof(Button)).onClick:AddListener(function() self:onCmdButClick(data, text, hasParam) end)
            self.cmdGrid:AddCell(cell)
        end
    end
end

function GmWindow:onCmdButClick(data, text, hasParam)
    local cmd = nil
    local param = text.text
    if hasParam then
        cmd = string.gsub(data.command, "{param}", param)
    else
        cmd = data.command
    end
    if cmd == "glory" then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window, {})
        return
    end
    if string.find(data.command,"gm") == nil then
        self.cmd:Run(data.command)
        return
    end
    local cmds = self:split(cmd, ";")
    for _, data in pairs(cmds) do
        data = string.sub(data, 3, -1)
        Connection.Instance:Send(9900, {cmd = data})
    end
end

function GmWindow:split(_str,split_char)
    if #_str == o then
        return
    end
    if _str == split_char then
        return _str
    end

    local sub_str_tab = {}
    while (true) do
        local pos = string.find(_str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = _str;
            break;
        end
        local sub_str = string.sub(_str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        _str = string.sub(_str, pos + 1, #_str);
    end
    return sub_str_tab;
end

function GmWindow:OpenMemoryInfo()
    self.memoryPanel.gameObject:SetActive(true)
    self.cmdContainer:SetActive(false)
    local kbSize = 1024*1024
    self.memoryPanel:Find("unityTotalReservedMemory"):GetComponent(typeof(Text)).text = string.format("UnityTotalReservedMemory: %sM", tostring(Profiler.GetTotalReservedMemory()/kbSize))
    self.memoryPanel:Find("unityTotalAllocatedMem"):GetComponent(typeof(Text)).text = string.format("UnityTotalAllocatedMem: %sM", tostring(Profiler.GetTotalAllocatedMemory()/kbSize))
    self.memoryPanel:Find("unityUnusedReservedMemory"):GetComponent(typeof(Text)).text = string.format("UnityUnusedReservedMemory: %sM", tostring(Profiler.GetTotalUnusedReservedMemory()/kbSize))
    self.memoryPanel:Find("MonoHeapSize"):GetComponent(typeof(Text)).text = string.format("MonoHeapSize: %sM", tostring(Profiler.GetMonoHeapSize()/kbSize))
    self.memoryPanel:Find("MonoUsedHeapSize"):GetComponent(typeof(Text)).text = string.format("LuaMemory: %sM", tostring(math.ceil(collectgarbage("count"))/1024))
end
