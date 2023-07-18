package com.shiyuegame.httprequest;

import com.shiyuegame.util.SYUtil;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Random;

public class HttpNormalRequest implements IHttpRequest {
	
	private float process = 0;
	
	
	private WebRequestInfo requestInfo = null;
	private VersionAsset asset = null;
    private int BufferSize = 2048;
    private DownloadFailInterface failCallBack = null;
	private DownloadSuccInterface succCallBack = null;

	private HttpURLConnection conn = null;
    
    public void SetBufferSize(int size) {
        BufferSize = size;
    }

    public void SetDownloadFailCallBack(DownloadFailInterface callback) {
    	this.failCallBack = callback;
	}

	public void SetDownloadSuccCallBack(DownloadSuccInterface callback) {
		this.succCallBack = callback;
	}

	public HttpNormalRequest(WebRequestInfo requestInfo, VersionAsset asset) {
        this.requestInfo = requestInfo;
        this.asset = asset;
    }

	@Override
	public void Get() {
		String path = requestInfo.path;
		if (requestInfo.useRandom) {
			Random random = new Random();
			path = path + "?random=" + random.nextInt(1000);
		}
		Dispose();
		try {
			URL url = new URL(path);
        	HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        	// conn.setRequestProperty("Connection", "Keep-Alive");
        	conn.setRequestMethod("GET");
        	conn.setConnectTimeout(requestInfo.timeout * 1000);
        	conn.setReadTimeout(requestInfo.timeout * 1000);
        	conn.connect();
        	int responseCode = conn.getResponseCode();
        	if (responseCode == HttpURLConnection.HTTP_OK || responseCode == HttpURLConnection.HTTP_PARTIAL) {
        		int length = Integer.parseInt(conn.getHeaderField("Content-Length"));
        		InputStream inStream = conn.getInputStream();
        		ByteArrayOutputStream output = new ByteArrayOutputStream();
        		byte[] buffer = new byte[BufferSize];
        		int n = 0;
        	    while (-1 != (n = inStream.read(buffer))) {
        	        output.write(buffer, 0, n);
        	    }
        	    if (output.size() == length) {
        	    	File file = new File(requestInfo.outputPath);
        	    	if (!file.exists()) {
        	    		if (!file.getParentFile().exists()) {
        	    			file.getParentFile().mkdirs();
        	    		}
        	    		file.createNewFile();
        	    	}
        	    	FileOutputStream fos = new FileOutputStream(file);
        	    	fos.write(output.toByteArray());
        	    	output.close();
        	    	fos.close();
        	    	process = 1;
        	    	Dispose();
					OnSucc(asset.GetPath());
					return;
//        	    	System.out.println("=======download finish:" + path);
        	    } else {
        	    	FailDeal(asset, "Download Size Error:" + path);
        	    	return;
        	    }
        	} else {
        	    FailDeal(asset, "StatusCode Error:" + responseCode);
        	    return;
        	}
		} catch(Exception e) {
			SYUtil.Log("=======下载异 常:" + e.getMessage(), e);
			FailDeal(asset, "StatusCode Error:" + e.getMessage());
		}
	}

	@Override
	public float GetProgress() {
		return process;
	}

	@Override
	public void Dispose() {
		if (conn != null) {
			conn.disconnect();
			conn = null;
		}
	}

	private void OnSucc(String path) {
    	if (succCallBack != null) {
    		succCallBack.CallBack(path);
    		succCallBack = null;
		}
	}

	private void FailDeal(VersionAsset asset, String msg) {
		Dispose();
		requestInfo.tryCount = requestInfo.tryCount - 1;
		if (requestInfo.tryCount <= 0) {
			if (failCallBack != null) {
				failCallBack.CallBack(asset, msg);
			} else {
				SYUtil.LogErr("下载文件失败：" + asset.GetPath() + " msg:" + msg);
			}
		} else {
			Get();
		}
	}
}

interface DownloadFailInterface {
	void CallBack(VersionAsset asset, String msg);
}

interface DownloadSuccInterface {
	void CallBack(String path);
}
