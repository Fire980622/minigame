-- 视图组件基类，BasePanel和BaseWindow继承该类
-- @author huangyq
BaseView = BaseView or BaseClass()

function BaseView:__init()
    self.name = "<Unknown View>"
    self.viewType = ViewType.BaseView
    -- 根节点
    self.gameObject = nil
    -- 优先级不同的使用分帧加载
    -- {{path, type, callback, priority}}
    self.resList = {}
    self.assetLoader = nil
end

function BaseView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.assetLoader ~= nil then
        self.assetLoader:DeleteMe()
        self.assetLoader = nil
    end
end

-- 资源加载完毕事件
function BaseView:OnResLoadCompleted()
    self:InitPanel()
    self:__OnInitCompleted()
end

-- 窗口初始化(需要重写)
function BaseView:InitPanel()
end

function BaseView:__OnInitCompleted()
    self:OnInitCompleted()
end

-- 窗口初始化完成(需要重写)
function BaseView:OnInitCompleted()
end

-- 资源加载
function BaseView:LoadAllAsset()
    if self.assetLoader ~= nil then
        local errorInfo = "BaseView<" .. self.name .. ">assetWrapper不可以重复使用"
        for key, _ in pairs(self.resList) do
            errorInfo = errorInfo .. " /r/n" .. key
        end
        Log.Error(errorInfo)
    end
    self.assetLoader = AssetBatchLoader.New("BaseView<" .. self.name)
    local callback = function()
        self:OnResLoadCompleted()
    end
    self.assetLoader:AddListener(callback)
    self.assetLoader:LoadAll(self.resList)
end

function BaseView:GetGameObject(path)
    return self.assetLoader:Pop(path)
end

function BaseView:GetObject(path)
    return self.assetLoader:Pop(path)
end

function BaseView:SetIcon(gameObject, path)
    AssetMgrProxy.Instance:SetIcon(gameObject, self:GetObject(path), path)
end
