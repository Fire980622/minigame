-- ----------------------------------------------------------
-- 公共函数库
-- ----------------------------------------------------------
-- import('UnityEngine')
-- import('UnityEngine.UI')
-- import('UnityEngine.Events')

-- import('Game.Logic')
-- import('Game.Asset')

-- UnityEngine
UnityEngine = CS.UnityEngine
Debug = CS.UnityEngine.Debug
LogError = CS.UnityEngine.Debug.LogError


Vector2 = UnityEngine.Vector2
Vector3 = UnityEngine.Vector3
Vector4 = UnityEngine.Vector4
Quaternion = UnityEngine.Quaternion
Color = UnityEngine.Color
Input = UnityEngine.Input
KeyCode = UnityEngine.KeyCode
GameObject = UnityEngine.GameObject
Transform = UnityEngine.Transform
RectTransform = UnityEngine.RectTransform
Canvas = UnityEngine.Canvas
CanvasGroup = UnityEngine.CanvasGroup
Application = UnityEngine.Application
QualitySettings = UnityEngine.QualitySettings
SkinWeights = UnityEngine.SkinWeights
AnisotropicFiltering = UnityEngine.AnisotropicFiltering
ShadowmaskMode = UnityEngine.ShadowmaskMode
RuntimePlatform = UnityEngine.RuntimePlatform
Screen = UnityEngine.Screen
Time = UnityEngine.Time
Shader = UnityEngine.Shader
Animator = UnityEngine.Animator
Animation = UnityEngine.Animation
PlayerPrefs = UnityEngine.PlayerPrefs
AudioListener = UnityEngine.AudioListener
AdditionalCanvasShaderChannels = UnityEngine.AdditionalCanvasShaderChannels
GraphicRaycaster = UnityEngine.GraphicRaycaster
SystemInfo = UnityEngine.SystemInfo
CharacterController = UnityEngine.CharacterController
Renderer = UnityEngine.Renderer
LayerMask = UnityEngine.LayerMask
TrailRenderer = UnityEngine.TrailRenderer
ParticleSystem = UnityEngine.ParticleSystem
AudioSource = UnityEngine.AudioSource
LineRenderer = UnityEngine.LineRenderer
BoxCollider = UnityEngine.BoxCollider
MaterialPropertyBlock = UnityEngine.MaterialPropertyBlock
PlayMode = UnityEngine.PlayMode
TextMesh = UnityEngine.TextMesh
RectTransformUtility = UnityEngine.RectTransformUtility
MeshRenderer = UnityEngine.MeshRenderer
AnimationCurve = UnityEngine.AnimationCurve
ParticleSystemRenderer = UnityEngine.ParticleSystemRenderer
RenderTextureFormat = UnityEngine.RenderTextureFormat
RenderTexture = UnityEngine.RenderTexture
Keyframe = UnityEngine.Keyframe
Physics = UnityEngine.Physics
Camera = UnityEngine.Camera
SkinnedMeshRenderer = UnityEngine.SkinnedMeshRenderer
WaitForSeconds = UnityEngine.WaitForSeconds
Rigidbody=UnityEngine.Rigidbody2D
-- 系统UI
Button = UnityEngine.UI.Button
RawImage = UnityEngine.UI.RawImage
Text = UnityEngine.UI.Text
RectMask2D = UnityEngine.UI.RectMask2D
ScrollRect = UnityEngine.UI.ScrollRect
Scrollbar = UnityEngine.UI.Scrollbar
Toggle = UnityEngine.UI.Toggle
Outline = UnityEngine.UI.Outline
Shadow = UnityEngine.UI.Shadow
Image = UnityEngine.UI.Image
Mask = UnityEngine.UI.Mask
Slider = UnityEngine.UI.Slider
InputField = UnityEngine.UI.InputField
Graphic = UnityEngine.UI.Graphic

UIBehaviour = CS.UnityEngine.EventSystems.UIBehaviour

-- 自定义
Log = CS.Game.Logic.Log
DataCollector = CS.Game.Logic.DataCollector
Utils = CS.Game.Logic.Utils
ThrDMapClickHandler = CS.Game.Logic.ThrDMapClickHandler

RenderManager = CS.RenderManager
AssetManager = CS.Game.Asset.AssetManager
IAutoReleaser = CS.Game.Asset.IAutoReleaser
AssetAutoReleaser = CS.Game.Asset.AssetAutoReleaser
IconAutoReleaser = CS.Game.Asset.IconAutoReleaser
LeanTween = CS.LeanTween
UtilsGmaeLogic = CS.UtilsGmaeLogic
SdkUtils = CS.SdkUtils
CSVersion = CS.Game.Logic.CSVersion
SceneAmbientSetting = CS.SceneAmbientSetting
MapOccusion = CS.MapOccusion
LightMapRecord = CS.LightMapRecord
HotUpdate = CS.HotUpdate
LeanTweenType = CS.LeanTweenType
Spine = CS.Spine
SortingOrderCtrl = CS.SortingOrderCtrl

LuaSvrManager = CS.Game.Logic.LuaSvrManager


-- 初始化后由ctx.IsDebug值替换，修改debug模式请在base_setting.txt文件中修改
IS_DEBUG = true 

print = function(...)
    if IS_DEBUG then
    	local args = {...}
    	local new_args = {}
    	for _, v in ipairs(args) do 
    		table.insert(new_args, tostring(v))
    	end
        -- 打印父节点
        local track_info = debug.getinfo(2, "Sln")
        local str = string.format("From %s:%d in function `%s`", track_info.short_src,track_info.currentline,track_info.name or "")

        Log.Debug(string.format("%s\n%s", table.concat(new_args, " "), str))
    end
end
