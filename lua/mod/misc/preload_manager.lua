-- 资源预加载
PreloadManager = PreloadManager or BaseClass()

function PreloadManager:__init()
    if PreloadManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    PreloadManager.Instance = self;

    self.cellbc = function(filePath)
        self:UpdateProgress(filePath)
    end

    self.resList = {
        {path = AssetConfig.font, type = AssetType.Asset, callback = self.cellbc},
        {path = AssetConfig.unlit_texture_shader, type = AssetType.Asset, callback = self.cellbc},
        {path = AssetConfig.sound_effct_214_path, type = AssetType.Asset, callback = self.cellbc},
    }

    self.assetCache = {}

    self.assetLoader = nil
    self.progress = 0
    self.total = #self.resList
end

function PreloadManager:__delete()
end

function PreloadManager:Preload(callback)
    ctx.LoadingPage:Show(TI18N("预加载文件(0%)"))
    if self.assetLoader == nil then
        local cbfunc = function()
            self.finish = true
            callback()
        end
        self.assetLoader = AssetBatchLoader.New("PreloadManager")
        self.assetLoader:AddListener(cbfunc)
        self.assetLoader:LoadAll(self.resList)
    else
        Log.Error("PreloadManager不可以重复加载")
    end
end

-- 更新进度条
function PreloadManager:UpdateProgress(filePath)
        self.progress = self.progress + 1
    if self.progress > self.total then
        self.progress = self.total
    end

    local percent = (self.progress / self.total) * 100
    ctx.LoadingPage:Progress(string.format(TI18N("预加载文件(%0.1f%%)"), tostring(percent)), percent)
end

function PreloadManager:GetGameObject(path)
    self:GetObject(path)
end

function PreloadManager:GetObject(path)
    if self.assetCache[path] ~= nil then
        return self.assetCache[path]
    else
        local asset = self.assetLoader:Pop(path)
        self.assetCache[path] = asset
        AssetMgrProxy.Instance:IncreaseReferenceCount(path)
        return asset
    end
end

-- 设置Icon
function PreloadManager:SetIcon(gameObject, path, name)
    if not self.assetLoader:Contain(path) then
        Log.Error("PreloadManager:GetSprite出错，该文件并没有预加载:" .. path)
    else
        -- 这一句不能直接调用
        local sprite = AssetManager.GetSubObject(path, name)
        AssetMgrProxy.Instance:SetIcon(gameObject, sprite, path)
    end
end

function PreloadManager:GetEffectSoundClip(name)
    return self:GetSubObject("sound$effect.folder", name)
end

-- 获取子资源
-- 预加载文件才可以这样写
function PreloadManager:GetSubObject(physicalPath, name)
    local obj = AssetManager.GetSubObjectByPhysicalPath(physicalPath, name)
    if obj ~= nil then
        return obj
    else
        return nil
    end
end
