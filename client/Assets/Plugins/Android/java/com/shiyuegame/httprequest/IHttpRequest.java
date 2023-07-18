package com.shiyuegame.httprequest;

public interface IHttpRequest {

	public void Get();
	public float GetProgress();
	public void Dispose();
	public void SetBufferSize(int size);
	public void SetDownloadFailCallBack(DownloadFailInterface callback);
	public void SetDownloadSuccCallBack(DownloadSuccInterface callback);
}
