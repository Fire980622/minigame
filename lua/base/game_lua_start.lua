-- lus 入口
--
GameLuaStart = GameLuaStart or BaseClass()

function GameLuaStart:__init()
    GameLuaStart.Instance = self
    self.moduleManager = ModuleManager.New()

end

function GameLuaStart:Start()
    -- local breakSocketHandle,debugXpCall = require("LuaDebugjit")("localhost",7003)
    -- breakSocketHandle()
    if Application.platform == RuntimePlatform.Android then
        Application.targetFrameRate = 45
    else
        Application.targetFrameRate = 60
    end
    UnityEngine.Time.fixedDeltaTime = 0.025
    QualitySettings.skinWeights = SkinWeights.OneBone
    QualitySettings.antiAliasing = 0
    QualitySettings.anisotropicFiltering = AnisotropicFiltering.Disable
    ctx.MainCamera.useOcclusionCulling = false
    ctx.UICamera.nearClipPlane = -15
    if ctx.IsDebug then
        IS_DEBUG = true
    else
        Log.SetLev(3) -- Info
        IS_DEBUG = false
    end

    --是否使用lua解析proto(默认不用)
    ctx.ProtocolDispatcher.IsUseLuaParser = false
    --使用此全局变量理论上减少开销
    IS_USE_LUA_PARSER = ctx.ProtocolDispatcher.IsUseLuaParser

    self.moduleManager:Activate()
    EventMgr.Instance:Fire(event_name.end_mgr_init)
    EventMgr.Instance:AddListener(event_name.start_player, function() self:OnStartPlayer() end)
    print(_VERSION) 
end

function GameLuaStart:Update()
    self.moduleManager:Update()
    if(self.startplayer)then
        PlayerController.Instance:Update()
    end
    
end
function GameLuaStart:OnStartPlayer()
    self.startplayer=true
end

function GameLuaStart:LateUpdate()

end

function GameLuaStart:FixedUpdate()

end