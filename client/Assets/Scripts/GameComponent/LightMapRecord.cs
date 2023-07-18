using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Rendering;
using XLua;


[LuaCallCSharp]
[DisallowMultipleComponent]
public class LightMapRecord : MonoBehaviour
{

    [SerializeField]
    public LightingRendererData[] rendererData = new LightingRendererData[0];

    [SerializeField]
    public LightingMapData[] mapData = new LightingMapData[0];

    [SerializeField]
    public LightingFogData fogData = new LightingFogData();

    [SerializeField]
    public RenderSettingData renderSettingData = new RenderSettingData();

    [SerializeField]
    public LightingBakingOutputData[] lightingBakingOutputData = new LightingBakingOutputData[0];


    protected void Start()
    {
        Debug.Log("LightmapRecord");
        Load();
    }

    public void Load()
    {
        LightingRendererData[] renders = rendererData;
        LightingMapData[] mapdatas = mapData;
        LightingFogData fogInfo = fogData;
        RenderSettingData renderSetting = renderSettingData;

        LightmapData[] lightmapAsset = new LightmapData[mapdatas.Length];
        for (int i = 0; i < mapdatas.Length; i++)
        {
            int mindex = mapdatas[i].originIndex;
            lightmapAsset[mindex] = new LightmapData();
            lightmapAsset[mindex].lightmapColor = mapdatas[i].lightMapFar;
            lightmapAsset[mindex].lightmapDir = mapdatas[i].lightMapNear;
            lightmapAsset[mindex].shadowMask = mapdatas[i].lightMapShadowMask;
        }
        LightmapSettings.lightmaps = lightmapAsset;


        if (renders != null)
        {
            foreach (LightingRendererData data in renders)
            {
                data.renderer.lightmapIndex = data.lightmapIndex;
                data.renderer.lightmapScaleOffset = data.lightmapScaleOffset;
            }
        }

        if (fogInfo != null)
        {
            RenderSettings.fog = fogInfo.isFog;
            RenderSettings.fogMode = fogInfo.fogMode;
            RenderSettings.fogColor = fogInfo.fogColor;
            RenderSettings.fogStartDistance = fogInfo.fogStartDistance;
            RenderSettings.fogEndDistance = fogInfo.fogEndDistance;
            RenderSettings.fogDensity = fogInfo.fogDensity;
        }

        if (renderSetting != null)
        {
            RenderSettings.ambientIntensity = renderSetting.ambientIntensity;
            RenderSettings.ambientMode = renderSetting.ambientMode;
            RenderSettings.ambientLight = renderSetting.ambientLight;
            RenderSettings.ambientGroundColor = renderSetting.ambientGroundColor;
            RenderSettings.ambientSkyColor = renderSetting.ambientSkyColor;
            RenderSettings.ambientEquatorColor = renderSetting.ambientEquatorColor;
            RenderSettings.skybox = renderSetting.skyBox;
        }

        foreach (LightingBakingOutputData data in lightingBakingOutputData)
        {
            if (data.light != null)
            {
                data.light.bakingOutput = new LightBakingOutput()
                {
                    probeOcclusionLightIndex = data.probeOcclusionLightIndex,
                    occlusionMaskChannel = data.occlusionMaskChannel,
                    lightmapBakeType = data.lightmapBakeType,
                    mixedLightingMode = data.mixedLightingMode,
                    isBaked = data.isBaked
                };
            }
        }

        LightmapSettings.lightmapsMode = LightmapsMode.NonDirectional;
    }

}

[Serializable]
public class LightingMapData
{
    public int originIndex;
    public Texture2D lightMapFar;
    public Texture2D lightMapNear;
    public Texture2D lightMapShadowMask;

}

[Serializable]
public class RenderSettingData
{
    public AmbientMode ambientMode;
    public Color ambientLight;
    public Color ambientGroundColor;
    public Color ambientSkyColor;
    public Color ambientEquatorColor;
    public float ambientIntensity;
    public Material skyBox;
}


[Serializable]
public class LightingFogData
{
    public bool forceRef = true;
    public bool isFog;
    public FogMode fogMode;
    public Color fogColor;
    public float fogStartDistance;
    public float fogEndDistance;
    public float fogDensity;
}

[Serializable]
public class LightingRendererData
{
    public Renderer renderer;
    public int lightmapIndex;
    public Vector4 lightmapScaleOffset;
}

[Serializable]
public class LightingBakingOutputData
{
    public Light light;
    public int probeOcclusionLightIndex;
    public int occlusionMaskChannel;
    public LightmapBakeType lightmapBakeType;
    public MixedLightingMode mixedLightingMode;
    public bool isBaked;

    public LightingBakingOutputData(Light light)
    {
        this.light = light;
        var bakingOutput = light.bakingOutput;
        this.probeOcclusionLightIndex = bakingOutput.probeOcclusionLightIndex;
        this.occlusionMaskChannel = bakingOutput.occlusionMaskChannel;
        this.lightmapBakeType = bakingOutput.lightmapBakeType;
        this.mixedLightingMode = bakingOutput.mixedLightingMode;
        this.isBaked = bakingOutput.isBaked;
    }
}

