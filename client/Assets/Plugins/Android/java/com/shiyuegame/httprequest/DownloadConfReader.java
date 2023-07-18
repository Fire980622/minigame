package com.shiyuegame.httprequest;


import com.shiyuegame.util.SYUtil;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.Queue;
import java.util.concurrent.LinkedBlockingQueue;

public class DownloadConfReader {

    private Queue<VersionAsset> list = new LinkedBlockingQueue<VersionAsset>();

    public DownloadConfReader(String downloadConf) {
        Parse(downloadConf);
    }

    private void Parse(String path) {
        try {
            BufferedReader dis = new BufferedReader(new FileReader(path));
            String line = dis.readLine();
            while(line != null) {
                String [] items = line.split("<#>");
                if (items.length != 4)
                    continue;
                VersionAsset asset = new VersionAsset(items[0], items[1], items[2], items[3]);
                list.add(asset);
                line = dis.readLine();
            }
            dis.close();
            SYUtil.Log("==========list size:" + list.size());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public int GetSize() {
        synchronized (list) {
            return list.size();
        }
    }

    public VersionAsset SyncPoll() {
        synchronized (list) {
            if (list != null) {
                return list.poll();
            } else {
                return null;
            }
        }
    }

    public  void SyncAdd(VersionAsset asset) {
        synchronized (list) {
            if (list != null) {
                list.add(asset);
            }
        }
    }
    public  void SyncClear() {
        if (list == null) {
            return;
        }
        synchronized (list) {
            list.clear();
            list = new LinkedBlockingQueue<VersionAsset>();
        }
    }
}
