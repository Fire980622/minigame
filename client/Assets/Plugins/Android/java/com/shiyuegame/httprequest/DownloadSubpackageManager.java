package com.shiyuegame.httprequest;

import com.shiyuegame.util.SYUtil;
import com.unity3d.player.UnityPlayer;

import java.util.HashMap;

public class DownloadSubpackageManager {

    public static final String ST_INIT = "Init";
    public static final String ST_LOADING = "Loading";
    public static final String ST_PAUSE = "Pause";
    public static final String ST_UNKNOWN = "Unknown";

    private String downloadConf = null;
    private DownloadConfReader reader = null;
    private String root = null;
    private String patchPath = null;

    private int threadCount = 3;
    private HashMap<String, String> failPathMap = null;

    private String status = ST_INIT;

    public DownloadSubpackageManager(String downloadConf, String root, String patchPath, int threadCount) {
        this.root = root;
        this.patchPath = patchPath;
        this.downloadConf = downloadConf;

        if (threadCount >= 1 && threadCount <= 10) {
            this.threadCount = threadCount;
        }
    }

    public void Init() {
        if (reader == null) {
            reader = new DownloadConfReader(downloadConf);
            failPathMap = new HashMap<String, String>();
            status = ST_INIT;
        }
    }

    public void Clear() {
        if (reader != null) {
            try {
                reader.SyncClear();
            } catch (Exception e) {
                SYUtil.Log("Unity", e);
            }
        }
    }

    public void ChangeStatus(String status) {
        if (ST_INIT.equals(status)
        || ST_LOADING.equals(status)
        || ST_PAUSE.equals(status)) {
            SYUtil.Log("==================ChangeStatus:" + status);
            this.status = status;
        } else  {
            SYUtil.Log("==================ChangeStatus:" + ST_UNKNOWN + "<>" + status);
            this.status = ST_UNKNOWN;
        }
    }

    public void Download() {
        SYUtil.Log("=====StartDownload===22==threadCount:"  + threadCount);
        DownloadFailInterface failCallBack = new DownloadFailInterface() {
            @Override
            public void CallBack(VersionAsset asset, String msg) {
                if (failPathMap.containsKey(asset.GetPath())) {
                    // 尝试两次
                    SYUtil.LogErr("第两次失败：" + asset.GetPath());
                    OnDownloadFailure(asset.GetPath(), msg);
                } else {
                    SYUtil.LogErr("第一次失败：" + asset.GetPath());
                    reader.SyncAdd(asset);
                    failPathMap.put(asset.GetPath(), asset.GetPath());
                }
            }
        };
        DownloadSuccInterface succCallBack = new DownloadSuccInterface() {
            @Override
            public void CallBack(String path) {
                OnDownloadSucc(path);
            }
        };
        for(int i = 0; i < threadCount; i++) {
            new Thread( new Runnable() {
                @Override
                public void run() {
                    try {
                        // long starttime = System.currentTimeMillis();
                        VersionAsset asset = reader.SyncPoll();
                        while (asset != null) {
                            if (status.equals(ST_LOADING)) {
                                String downPath = patchPath + "/" + asset.GetPatchVersion() + "/" + asset.GetPath();
                                String savePath = root + "/" + asset.GetPath();
                                // SYUtil.Log("=====Download=2=====" + downPath);
                                WebRequestInfo webRequest = new WebRequestInfo();
                                webRequest.path = downPath;
                                webRequest.outputPath = savePath;
                                webRequest.tryCount = 3;
                                IHttpRequest request = null;
                                if (Integer.parseInt(asset.GetSize()) > 3 * 1024 * 1024) {
                                    request = new HttpRangeRequest(webRequest, asset);
                                } else {
                                    request = new HttpNormalRequest(webRequest, asset);
                                }
                                request.SetDownloadFailCallBack(failCallBack);
                                request.SetDownloadSuccCallBack(succCallBack);
                                request.Get();
                                asset = reader.SyncPoll();
                            } else {
                                Thread.sleep(300);
                            }
                        }
                        // long endtime = System.currentTimeMillis();
                        // long diff = endtime - starttime;
                        // long minutes = (diff / 1000) / 60;
                        // long seconds = (diff / 1000) % 60;
                        SYUtil.Log("========Done!========");
                    } catch (Exception e) {
                        SYUtil.LogErr("Download Error:" + e.getMessage());
                        SYUtil.Log("Unity", e);
                    }
                }
            }).start();
        }
    }

    public void OnDownloadFailure(String path, String msg) {
        UnityPlayer.UnitySendMessage("JavaCompoent", "JavaDownloadSubpackageFail", path + "<#>" + msg);
    }

    public void OnDownloadSucc(String path) {
        UnityPlayer.UnitySendMessage("JavaCompoent", "JavaDownloadSubpackageSucc", path);
    }
}
