package com.shiyuegame.httprequest;

import com.shiyuegame.util.SYUtil;
import com.unity3d.player.UnityPlayer;

import java.util.HashMap;

public class DownloadPatchManager {

    private String downloadConf = null;
    private DownloadConfReader reader = null;
    private String root = null;
    private String patchPath = null;

    private int threadCount = 3;
    private HashMap<String, String> failPathMap = null;

    public DownloadPatchManager(String downloadConf, String root, String patchPath, int threadCount) {
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
        }
    }

    public void Clear() {
        if (reader != null) {
            reader.SyncClear();
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
                        long starttime = System.currentTimeMillis();
                        VersionAsset asset = reader.SyncPoll();
                        while (asset != null) {
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
                        }
                        long endtime = System.currentTimeMillis();
                        long diff = endtime - starttime;
                        long minutes = (diff / 1000) / 60;
                        long seconds = (diff / 1000) % 60;
                        SYUtil.Log("========Done!========" + minutes + ":" + seconds);
                    } catch (Exception e) {
                        SYUtil.LogErr("Download Error:" + e.getMessage());
                        SYUtil.Log("Unity", e);
                    }
                }
            }).start();
        }
    }

    public void OnDownloadFailure(String path, String msg) {
        UnityPlayer.UnitySendMessage("JavaCompoent", "JavaDownloadPatchFail", path + "<#>" + msg);
    }

    public void OnDownloadSucc(String path) {
        UnityPlayer.UnitySendMessage("JavaCompoent", "JavaDownloadPatchSucc", path);
    }
}
