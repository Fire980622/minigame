using UnityEngine;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using Game.Asset;

using Object = UnityEngine.Object;
using UnityEngine.UI;

public class LoadTest : MonoBehaviour {
    private int _index = 0;
    private Image _iconImage0;
    private Image _iconImage1;

    private GameObject maingo = null;
    private GameObject model = null;

    void Awake() {
        GameObject.DontDestroyOnLoad(this);

        //Debug.LogError ("=================LoadTest Awake=================");
        ////public const string FILE_HEAD = "file://d:/output5.4";
        ////AssetBridge.Parse = ComponentAssembler.Parse;
        ////AssetManager.ASSET_ROOT_PATH = "http://192.168.0.26/";
        //AssetManager.ASSET_ROOT_PATH = "http://127.0.0.1/framework/pc/";
        ////AssetManager.ASSET_ROOT_PATH = "file:///" + Directory.GetCurrentDirectory () + "/../release/";
        //// AssetManager.ASSET_ROOT_PATH = "file:///D:/data/framework.dev/release/pc/";
        //Image.GetMaterial = AssetManager.GetUIAssemblyObject;
        //Image.GetSprite = AssetManager.GetUIAssemblyObject;
        //Text.GetFont = AssetManager.GetUIAssemblyObject;

        //AssetManager.GetInstance ();

        //_iconImage0 = GameObject.Find("IconDemo").GetComponent<Image>();
        //_iconImage1 = GameObject.Find("IconDemo1").GetComponent<Image>();

        //AssetManager.GetObject("NPC/11001/idle7.anim", OnObjectLoaded);
        //AssetManager.GetGameObject("Unit/Role/Prefab/X3test_01_chunk5.prefab", 100, OnObjectLoaded);
    }

    private void OnGUI()
    {
        if(GUI.Button(new Rect(0, 0, 200, 200), "Test"))
        {
            //AssetManager.GetGameObject("Unit/Role/Prefab/X3test_01_chunk5.prefab", 100, OnObjectLoaded);
        }
    }

    //void Update() {
    //    _index++;
    //    if (_index == 100) {
    //        Debug.Log("Load Record");
    //        AssetManager.GetAssetRecord("_resources.asset", OnAssetRecordLoaded);
    //    }
    //}

    //private void OnAssetRecordLoaded() {
    //    //AssetManager.GetObject("NPC/11001/idle7.anim", OnObjectLoaded);
    //    // AssetManager.GetGameObject("Prefabs/UI/Alchemy/AlchemyWindow.prefab", 30, OnGameOjectLoadedUI);
    //    // AssetManager.GetGameObject ("Unit/Npc/Prefab/71006.prefab", 30, OnGameOjectLoadedModel);

    //    //Icon异步加载示例

    //    GetIcon("Icon/Mutliple_out/Drop.png", "1", OnIconLoaded0);
    //    GetIcon("Icon/Single_out/3.png", "3", OnIconLoaded1);
    //    // AssetManager.GetGameObject("Prefabs/BigTextures/combatMap.prefab", OnBigTexturePrefabLoaded);
    //}

    private void OnObjectLoaded(Object obj)
    {
        GameObject.Instantiate<GameObject>(obj as GameObject);
        Debug.Log(obj);
    }

    //private void OnMaterialLoaded(Object obj) {
    //    Debug.Log(obj);
    //}

    //private void OnFontLoaded(Object obj) {
    //    Debug.Log(obj);
    //}

    //private void OnGameOjectLoaded(GameObject go) {
    //    Debug.Log("======================" + go.name);
    //}

    //private void OnGameOjectLoadedModel(GameObject go) {
    //    model = go;
    //    GetAnimationClip("Unit/Npc/Animation/71006/move1.anim", "move1", OnGameOjectLoadedClip);
    //}

    //private void OnGameOjectLoadedClip (AnimationClip clip) {
    //    Debug.Log("======================" + clip.name);
    //    Animation anim = model.transform.Find ("tpose").GetComponent<Animation> ();
    //    anim.AddClip (clip, clip.name);
    //    anim.Play (clip.name);
    //}

    //private void OnGameOjectLoadedUI(GameObject go) {
    //    go.name = "test";
    //    go.transform.SetParent (GameObject.Find ("Canvas").transform);

    //    Transform trans = go.transform;
    //    trans.localScale = Vector3.one;
    //    trans.localPosition = Vector3.zero;
    //    trans.localRotation = Quaternion.identity;

    //    RectTransform rect = trans.GetComponent<RectTransform> ();
    //    rect.anchorMax = Vector2.one;
    //	rect.anchorMin = Vector2.zero;
    //	rect.offsetMin = Vector2.zero;
    //	rect.offsetMax = Vector2.zero;
    //	rect.localScale = Vector3.one;
    //	rect.localPosition = Vector3.zero;
    //    maingo = go;
    //    // AssetManager.GetGameObject ("Textures/BigBgPref/SummerHappyBg.prefab", 30, OnGameOjectLoadedBigBg);
    //}

    //private void OnGameOjectLoadedBigBg (GameObject go) {
    //    GameObject bigbg = maingo.transform.Find ("MainCon/bigbg").gameObject;
    //    go.name = "bigbg";
    //    go.transform.SetParent (bigbg.transform);
    //    Transform trans = go.transform;
    //    trans.localScale = Vector3.one;
    //    trans.localPosition = Vector3.zero;
    //    trans.localRotation = Quaternion.identity;
    //}

    ////异步调用Icon示例
    //private void GetIcon(string atlasPath, string iconName, Action<Sprite> onIconLoaded) {
    //    AssetManager.GetAsset(atlasPath, 30, delegate(string path) { OnAtlasLoaded(atlasPath, iconName, onIconLoaded); });
    //}

    //private void OnAtlasLoaded(string atlasPath, string iconName, Action<Sprite> onIconLoaded) {
    //    string[] physicalPaths = AssetRecord.Instance.GetDependentPhysicalPaths(atlasPath);
    //    string physicalPath = physicalPaths[0];
    //    List<Object> objList = AssetManager.GetObjectListByPhysicalPath(physicalPath);
    //    for (int i = 0; i < objList.Count; i++) {
    //        Object o = objList[i];
    //        if (o.GetType() == typeof(Sprite) && o.name == iconName) {
    //            onIconLoaded(o as Sprite);
    //        }
    //    }
    //}

    //private void GetAnimationClip (string path, string name, Action<AnimationClip> OnLoaded) {
    //    AssetManager.GetAsset(path, 30, delegate(string s) { OnAnimationClipLoaded(path, name, OnLoaded); });
    //}

    //private void OnAnimationClipLoaded (string path, string name, Action<AnimationClip> OnLoaded) {
    //    string[] physicalPaths = AssetRecord.Instance.GetDependentPhysicalPaths(path);
    //    string physicalPath = physicalPaths[0];
    //    List<Object> objList = AssetManager.GetObjectListByPhysicalPath(physicalPath);
    //    for (int i = 0; i < objList.Count; i++) {
    //        Object o = objList[i];
    //        if (o.GetType() == typeof(AnimationClip) && o.name == name) {
    //            OnLoaded(o as AnimationClip);
    //        }
    //    }
    //}

    //private void OnIconLoaded0(Sprite sprite) {
    //    _iconImage0.sprite = sprite;
    //    Button button = _iconImage0.gameObject.AddComponent<Button> ();
    //    // Button button = go.transform.FindChild ("MainCon/BtnOneKeyLian").GetComponent<Button> ();
    //    button.onClick.AddListener (() => {
    //        AssetManager.UnloadUnusedAssets (true);
    //        Debug.LogError ("===============================UnloadUnusedAssets");
    //    });

    //    //Debug.Log("associatedAlphaSplitTexture:  " + _iconImage0.sprite.associatedAlphaSplitTexture);
    //}

    //private void OnIconLoaded1(Sprite sprite) {
    //    _iconImage1.sprite = sprite;
    //    //Debug.Log("associatedAlphaSplitTexture:  " + _iconImage1.sprite.associatedAlphaSplitTexture);
    //}

    //private void OnBigTexturePrefabLoaded(GameObject go) {
    //    Transform trans = GameObject.Find("Canvas").transform;
    //    go.transform.SetParent(trans);
    //    go.transform.localPosition = Vector2.zero;
    //}
}
