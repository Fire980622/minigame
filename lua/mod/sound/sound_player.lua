-- 音源
-- @author huangyq
SoundPlayer = SoundPlayer or BaseClass()

function SoundPlayer:__init(audioType)
    self.audioType = audioType
    self.gameObject = nil
    self.audioSource = nil

    -- 用于判断是否覆盖播放
    self.priLevel = 5
    self.startTime = 0
    self.clipLenth = 0

    self.isMute = false

    self.oldVolume = 0.5
    -- 重复标志，重复播放跳过
    self.isrepeat = false
    self:Init()
end

function SoundPlayer:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
end

function SoundPlayer:Init()
    self.gameObject = GameObject("SoundPlayer" .. self.audioType)
    self.gameObject.transform:SetParent(GameObject.Find("MainCamera").transform)
    self.gameObject.transform.localPosition = Vector3.zero
    self.audioSource = self.gameObject:AddComponent(typeof(AudioSource))
    self.oldVolume = self.audioSource.volume
    self:Reset()
end

-- 当前音频剪辑
function SoundPlayer:SetClip(clip)
    if clip ~= nil and not UtilsBase.IsNull(self.audioSource) and not UtilsBase.IsNull(self.audioSource.clip) then
        if self.audioSource.isPlaying and self.audioSource.clip.name == clip.name then
            self.isrepeat = true
            return
        end
    end
    self.isrepeat = false
    self.audioSource.clip = clip
end
-- function SoundPlayer:GetClip()
--     return self.audioSource.clip
-- end

function SoundPlayer:StopId(id)
    if not UtilsBase.IsNull(self.audioSource) and not UtilsBase.IsNull(self.audioSource.clip) then
        if tostring(id) == self.audioSource.clip.name then
            self.audioSource:Stop()
        end
    end
end

-- 音量
function SoundPlayer:SetVolume(volume)
    if self.audioType == AudioSourceType.Combat then
        if volume > 0 then
            volume = volume * 0.6
        end
    end
    self.audioSource.volume = volume
    self.oldVolume = volume
end

function SoundPlayer:GetVolume()
    return self.audioSource.volume
end

-- 静音
function SoundPlayer:SetMute(mute)
    self.audioSource.mute = mute
    self.isMute = mute
end

-- 播放
function SoundPlayer:Play()
    if self.isrepeat then
        self.isrepeat = false
        return
    end
    if not UtilsBase.IsNull(self.audioSource) and not UtilsBase.IsNull(self.audioSource.clip) then
        self.audioSource:Play()
    end
    -- if self.isMute then
    --     -- if self.audioType == AudioSourceType.BGM then
    --     --     self.audioSource:Play()
    --     -- end
    -- else
    -- end
end

function SoundPlayer:IsPlaying()
    return self.audioSource.isPlaying
end

-- 暂停
function SoundPlayer:Pause()
    self.audioSource:Pause()
end

-- 停止
function SoundPlayer:Stop()
    self.audioSource:Stop()
end

-- 重置
function SoundPlayer:Reset()
    self.audioSource.playOnAwake = false
    self.audioSource.volume = 0.5
    if self.audioType == AudioSourceType.BGM then
        self.audioSource.loop = true
    else
        self.audioSource.loop = false
    end
end

function SoundPlayer:OnWakeUp()
    self.audioSource.volume = self.oldVolume
end

function SoundPlayer:OnSleep()
    self.oldVolume = self.audioSource.volume
    if self.oldVolume > 0.1 then
        self.audioSource.volume = 0.1
    end
end
