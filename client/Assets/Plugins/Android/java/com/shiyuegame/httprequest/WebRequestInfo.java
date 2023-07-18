package com.shiyuegame.httprequest;

public class WebRequestInfo {

    public String path = null;
    public String outputPath = null;
//    public Action<byte[], string> webSucceCallback = null;
//    public Action<VersionAsset, string> webFailCallback = null;
    public String alertTxt = "";
    public int tryCount = 3;
    public int timeout = 10;
    public boolean useRandom = false;
//    public UnityWebRequest webRequest = null;
//    public UnityWebRequest headRequest = null;
}
