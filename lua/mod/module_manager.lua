-- 模块管理
ModuleManager = ModuleManager or BaseClass()

local _Time = Time
function ModuleManager:__init()
    if ModuleManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    ModuleManager.Instance = self

    
    self.timeStamp = _Time.realtimeSinceStartup
    self.frameStamp = 0
    self.fps = 0
    self.avgfps = 0
    local realtimeSinceStartup = _Time.realtimeSinceStartup
    ModuleManager.realtimeSinceStartup = realtimeSinceStartup

    self.preloadManager = nil
end

function ModuleManager:Activate()
    Tween.New()
    EventMgr.New()
    AssetMgrProxy.New()
    self.preloadManager = PreloadManager.New()
    SoundManager.New()
    PreviewManager.New()
    WindowManager.New()
    DemoManager.New()
    ShaderManager.New()
    GmManager.New()

    -- 最后执行
    LoginManager.New()
    SlotManager.New()
    Connection.New()
    

    self.preloadManager:Preload(function () self:OnPreloadCompleted() end)

    self.timeMgr = TimerManager.getInstance()
    CombatManager.New()
end

function ModuleManager:OnPreloadCompleted()
    self:Login()
end

function ModuleManager:Release()
end

function ModuleManager:FixedUpdate()
end

function ModuleManager:Update()

    local deltatime = _Time.deltaTime
    local realtimeSinceStartup = _Time.realtimeSinceStartup
    ModuleManager.realtimeSinceStartup = realtimeSinceStartup
    self.frameStamp = self.frameStamp + 1
    if realtimeSinceStartup >= self.timeStamp + 1 then
        self.fps = self.frameStamp / (realtimeSinceStartup - self.timeStamp)
        self.avgfps = self.fps
    
        self.timeStamp = realtimeSinceStartup
        self.frameStamp = 0
    end

    -- if _Is3DGame then
    --     --3D
        Scene3DController.Instance:Update()
    -- else
    --     --2d
    --     SceneManager.Instance:FixedUpdate()
    -- end
    
   
    self.timeMgr:Update(deltatime)
    Connection.Instance:OnTick()
    UtilsBase.FloatTime = UtilsBase.FloatTime + _Time.unscaledDeltaTime

end

function ModuleManager:Login()
    -- 显示登录界面
    LoginManager.Instance.model:InitMainUI()
end
