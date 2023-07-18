package com.shiyuegame.util;

import android.util.Log;

import java.io.PrintWriter;
import java.io.StringWriter;

public class SYUtil {

    public static void Log(String msg) {
        Log.i("Unity", msg);
    }

    public static void Log(String tag, String msg) {
        Log.i(tag, msg);
    }

    public static void LogErr(String msg) {
        Log.e("Unity", msg);
    }

    public static void LogErr(String tag, String msg) {
        Log.e(tag, msg);
    }

    public  static  void Log(String tag, Exception e) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        e.printStackTrace(pw);
        pw.flush();
        sw.flush();
        Log.e(tag, "Message:" + e.getMessage() + ">>\n" + sw.toString());
    }
}
