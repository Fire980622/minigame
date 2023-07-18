-- 背景音乐加载
-- @author huangyq
SoundLoader = SoundLoader or BaseClass()

function SoundLoader:__init(soundId, callback)
    self.soundId = soundId
    self.callback = callback

    self.soundPath = string.format("Sound/Bgm/%s.ogg", self.soundId)
    local resources = {
        {path = self.soundPath, type = AssetType.Object}
    }
    local callback = function()
        self:loadCompleted()
    end
    self.assetLoader = AssetBatchLoader.New("SoundLoader[" .. self.soundId .. "]");
    self.assetLoader:AddListener(callback)
    self.assetLoader:LoadAll(resources)
end

function SoundLoader:__delete()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function SoundLoader:loadCompleted()
    if self.callback ~= nil then
        local clip = self.assetLoader:Pop(self.soundPath)
        self.callback(self.soundId, clip, self.soundPath)
    end
    if self.assetLoader ~= nil then
        self.assetLoader:DeleteMe()
        self.assetLoader = nil
    end
end
