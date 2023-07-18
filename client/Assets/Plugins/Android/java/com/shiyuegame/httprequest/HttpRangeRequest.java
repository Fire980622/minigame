package com.shiyuegame.httprequest;

import android.os.Debug;

import com.shiyuegame.util.SYUtil;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Random;

public class HttpRangeRequest implements IHttpRequest{
	
    private long totalSize = 0;
    private long currLength = 0;
    private int recSize = 0;

	private float process = 0;
	
	private WebRequestInfo requestInfo = null;
	private VersionAsset asset = null;
    private int BufferSize = 2048;
	private DownloadFailInterface failCallBack = null;
	private DownloadSuccInterface succCallBack = null;

	private HttpURLConnection conn = null;
    private FileOutputStream fs = null;
    private BufferedOutputStream bs = null;

    public void SetBufferSize(int size) {
        BufferSize = size;
    }

	public void SetDownloadFailCallBack(DownloadFailInterface callback) {
		this.failCallBack = callback;
	}

	public void SetDownloadSuccCallBack(DownloadSuccInterface callback) {
		this.succCallBack = callback;
	}

	public HttpRangeRequest(WebRequestInfo requestInfo, VersionAsset asset) {
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
		String outpath = null;
		try {
			outpath = requestInfo.outputPath + URLEncoder.encode(asset.GetMd5(), "UTF-8");
		} catch (UnsupportedEncodingException e) {
			outpath = requestInfo.outputPath + asset.GetMd5();
		}
		String targetpath = requestInfo.outputPath;
		File tfile = new File(targetpath);
		if (!tfile.exists()) {
			if (!tfile.getParentFile().exists()) {
				tfile.getParentFile().mkdirs();
        	}
		}
		Dispose();
		
		try {
			totalSize = 0;
			currLength = 0;
			URL url = new URL(path);
        	HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        	conn.setRequestMethod("HEAD");
        	conn.setConnectTimeout(requestInfo.timeout * 1000);
        	conn.setReadTimeout(requestInfo.timeout * 1000);
        	conn.connect();
        	int responseCode = conn.getResponseCode();
        	if (responseCode == HttpURLConnection.HTTP_OK || responseCode == HttpURLConnection.HTTP_PARTIAL) {
        		totalSize = Integer.parseInt(conn.getHeaderField("Content-Length"));
        	}
        	File ofile = new File(outpath);
        	if (ofile.exists() && ofile.isFile()) {
        		currLength = ofile.length();
        	}
        	if (conn != null) {
        		conn.disconnect();
        		conn = null;
        	}
        	if (currLength >= totalSize) {
        		Dispose();
        		ofile = new File(outpath);
        		if (ofile.exists() && ofile.isFile()) {
        			ofile.renameTo(new File(targetpath));
        			return;
        		}
        	}
        	recSize = 0;
        	conn = (HttpURLConnection)url.openConnection();
        	conn.setRequestMethod("GET");
        	conn.setConnectTimeout(requestInfo.timeout * 1000);
        	conn.setReadTimeout(requestInfo.timeout * 1000);
        	if (currLength > 0) {
        		conn.setRequestProperty("Range", "bytes=" + currLength + "-");
        	}
        	conn.connect();
        	responseCode = conn.getResponseCode();
        	if (responseCode == HttpURLConnection.HTTP_OK || responseCode == HttpURLConnection.HTTP_PARTIAL) {
        		InputStream inStream = conn.getInputStream();

        		fs = new FileOutputStream(outpath, true);
        		bs = new BufferedOutputStream(fs, BufferSize * 6) ;
        		byte[] buffer = new byte[BufferSize];
        		int n = 0;
        		int c = 0;
        	    while (-1 != (n = inStream.read(buffer))) {
        	        bs.write(buffer, 0, n);
        	        recSize = recSize + n;
        	        currLength = currLength + n;
        	        c++;
        	        if (c%3 == 0) {
        	        	bs.flush();
        	        }
        	    }
        	    bs.flush();
        	    bs.close();
        	    fs.close();
        	    bs = null;
        	    fs = null;
        	    if (currLength != totalSize) {
        	    	FailDeal(asset, "Download Size Error:" + path + " currlength:" + currLength + " totalSize:" + totalSize);
        	    	return;
        	    }
        	    Dispose();
        		File rfile = new File(outpath);
        		if (rfile.exists() && rfile.isFile()) {
        			File oldfile = new File(targetpath);
        			if (oldfile.exists() && oldfile.isFile()) {
        				oldfile.delete();
        			}
        			rfile.renameTo(new File(targetpath));
					process = 1;
					OnSucc(asset.GetPath());
        			SYUtil.Log("===============range download finish:" + path);
        		}
        	} else {
        	    FailDeal(asset, "StatusCode Error:" + responseCode);
        	    return;
        	}
		} catch (Exception e) {
			SYUtil.Log("Download Error:" + e.getMessage(), e);
			FailDeal(asset, "Download Error:" + e.getMessage());
		}
		Dispose();
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
		try {
			if (bs != null) {
				bs.close();
				bs = null;
			}
			if (fs != null) {
				fs.close();
				fs = null;
			}
		} catch (IOException e) {
			SYUtil.Log("HttpRangeRequest Dispose Error", e);
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
			SYUtil.LogErr("重新下载：" + asset.GetPath());
			Get();
		}
	}
}
