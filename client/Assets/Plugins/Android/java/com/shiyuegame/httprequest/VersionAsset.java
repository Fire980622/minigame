package com.shiyuegame.httprequest;


public class VersionAsset {
    private String path = null;
    private String size = null;
    private String patchVersion = null;
    private String md5 = null;

    public String GetPath() {
        return path;
    }

    public String GetSize() {
        return size;
    }

    public String GetPatchVersion() {
        return patchVersion;
    }

    public String GetMd5() {
        return md5;
    }

    public VersionAsset(String path, String patchVersion, String size, String md5) {
        this.path = path;
        this.patchVersion = patchVersion;
        this.size = size;
        this.md5 = md5;
    }
}
