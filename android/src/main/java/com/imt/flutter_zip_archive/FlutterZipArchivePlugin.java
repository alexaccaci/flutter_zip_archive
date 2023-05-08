package com.imt.flutter_zip_archive;

import android.os.AsyncTask;
import android.content.Context;

import net.lingala.zip4j.core.ZipFile;
import net.lingala.zip4j.exception.ZipException;
import net.lingala.zip4j.model.FileHeader;
import net.lingala.zip4j.model.ZipParameters;
import net.lingala.zip4j.util.Zip4jConstants;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterZipArchivePlugin */
public class FlutterZipArchivePlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_zip_archive");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if(call.method.equals("zip")) {
        new ZipTask(call, result).execute();
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private class ZipTask extends AsyncTask<Void, Void, String> {
    private MethodCall call;
    private Result result;

    public ZipTask(MethodCall call, Result result) {
      this.call = call;
      this.result = result;
    }

    @Override
    protected String doInBackground(Void... params) {
      return zip(call, result);
    }

    @Override
    protected void onPostExecute(String data) {
      super.onPostExecute(data);
      if(data == null)
        this.result.success("Success");
      else
        this.result.error(data, null, null);
    }
  }

  public String zip(MethodCall call, Result result) {
    String src = call.argument("src");
    String dest = call.argument("dest");
    String passwd = call.argument("password");
    File srcFile = new File(src);
    dest = buildDestinationZipFilePath(srcFile, dest);
    ZipParameters parameters = new ZipParameters();
    parameters.setCompressionMethod(Zip4jConstants.COMP_DEFLATE);           // 压缩方式
    parameters.setCompressionLevel(Zip4jConstants.DEFLATE_LEVEL_NORMAL);    // 压缩级别
    if (passwd != null && passwd != "") {
      parameters.setEncryptFiles(true);
      parameters.setEncryptionMethod(Zip4jConstants.ENC_METHOD_STANDARD); // 加密方式
      parameters.setPassword(passwd.toCharArray());
    }
    try {
      ZipFile zipFile = new ZipFile(dest);
      if (srcFile.isDirectory()) {
        File[] subFiles = srcFile.listFiles();
        ArrayList<File> temp = new ArrayList<File>();
        Collections.addAll(temp, subFiles);
        zipFile.addFiles(temp, parameters);
      } else {
        zipFile.addFile(srcFile, parameters);
      }
    } catch (Exception e) {
      e.printStackTrace();
      return Arrays.toString(e.getStackTrace());
    }
    return null;
  }

  private String buildDestinationZipFilePath(File srcFile, String destParam) {
    if (destParam == null || destParam == "") {
      if (srcFile.isDirectory()) {
        destParam = srcFile.getParent() + File.separator + srcFile.getName() + ".zip";
      } else {
        String fileName = srcFile.getName().substring(0, srcFile.getName().lastIndexOf("."));
        destParam = srcFile.getParent() + File.separator + fileName + ".zip";
      }
    } else {
      createDestDirectoryIfNecessary(destParam);
      if (destParam.endsWith(File.separator)) {
        String fileName = "";
        if (srcFile.isDirectory()) {
          fileName = srcFile.getName();
        } else {
          fileName = srcFile.getName().substring(0, srcFile.getName().lastIndexOf("."));
        }
        destParam += fileName + ".zip";
      }
    }
    return destParam;
  }

  private void createDestDirectoryIfNecessary(String destParam) {
    File destDir = null;
    if (destParam.endsWith(File.separator)) {
      destDir = new File(destParam);
    } else {
      destDir = new File(destParam.substring(0, destParam.lastIndexOf(File.separator)));
    }
    if (!destDir.exists()) {
      destDir.mkdirs();
    }
  }

}
