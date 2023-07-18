-- 窗口基类，拥有窗口属性
-- prefab一般包含canvas组件
-- @author huangyq
BaseWindow = BaseWindow or BaseClass(BaseView)

function BaseWindow:__init(model)
    self.model = model
    self.name = "<Unknown Window>"
    self.windowId = 0

    -- 缓存类型
    self.cacheMode = CacheMode.Destroy
    self.viewType = ViewType.Window
    self.winLinkType = WinLinkType.Link
    -- 缓存时间(秒)
    self.hideTime = 0

    self.holdTime = UtilsBase.DefaultHoldTime()
    -- 打开窗口传入参数
    self.openArgs = nil

    -- 窗口隐藏事件
    self.OnHideEvent = EventLib.New()
    -- 窗口打开事件
    self.OnOpenEvent = EventLib.New()
    -- 初始化完成事件
    self.OnInitCompletedEvent = EventLib.New()

    self.loading = false
    WindowManager.Instance:AddWindow(self)

    self.baseRect = nil
    self.isOpen = false
end

function BaseWindow:__delete()
    -- print(self)
    self.openArgs = nil
    self.OnHideEvent:DeleteMe()
    self.OnHideEvent = nil
    self.OnOpenEvent:DeleteMe()
    self.OnOpenEvent = nil
    self.OnInitCompletedEvent:DeleteMe()
    self.OnInitCompletedEvent = nil
    WindowManager.Instance:RemoveWindow(self)
end

-- 打开窗口
function BaseWindow:Open(arge)
    if self.loading then
        return
    end
    self.openArgs = arge

    if self.gameObject ~= nil then
        WindowManager.Instance:OnOpenWindow(self)
        if self.baseRect == nil then
            self.baseRect = self.gameObject:GetComponent(typeof(RectTransform))
        end
        self.baseRect.anchoredPosition = Vector2.zero
        self.gameObject:SetActive(true)
        self.OnOpenEvent:Fire()
        self.loading = false
        self.isOpen = true

    else
         -- 如果有资源则加载资源，否则直接调用初始化接口
        self.loading = true
        if self.resList ~= nil and #self.resList > 0 then
            self:LoadAllAsset()
        else
            self:OnResLoadCompleted()
        end
    end
end

function BaseWindow:__OnInitCompleted()
    self.loading = false
    self.isOpen = true
    WindowManager.Instance:OnOpenWindow(self)
    self:__DoClickPanel()
    self.OnInitCompletedEvent:Fire()
    self:OnInitCompleted()
end

-- 默认:如果预设有Panel节点，并有Button组件，点击关闭窗口，可能自己重写
function BaseWindow:__DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:Find("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(typeof(Button))
            if panelBut ~= nil then
                local onClick = function()
                    WindowManager.Instance:CloseWindow(self)
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

-- 隐藏，只能由WindowManager调用
function BaseWindow:Hide()
    if self.baseRect == nil then
        self.baseRect = self.gameObject:GetComponent(typeof(RectTransform))
    end
    self.baseRect.anchoredPosition = Vector2(0, -2000)
    self.OnHideEvent:Fire()
    self.hideTime = Time.time
    self.isOpen = false
end

-- 检测是否销毁[false 不销毁; true 销毁]
function BaseWindow:CheckToDestroy(nowTime)
    if self.gameObject then
        if not self.isOpen then
            if (nowTime - self.hideTime) > self.holdTime then
                return true
            end
        end
    end
    return false
end

