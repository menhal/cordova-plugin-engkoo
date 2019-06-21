package com.edufe.engkoo;

import android.database.Cursor;
import android.net.Uri;
import android.util.Base64;

import com.github.lzyzsd.jsbridge.BridgeHandler;
import com.github.lzyzsd.jsbridge.BridgeWebView;
import com.github.lzyzsd.jsbridge.CallBackFunction;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;

import java.io.File;
import java.io.FileInputStream;

public class Engkoo extends CordovaPlugin implements Runnable, BridgeHandler{

    EngkooDialog dialog = null;
    String accessToken = "";
    String engkooHomeUrl = "https://dev-mtutor.chinacloudsites.cn/dist/app-scenario-lesson/?origin=android-xinfangxiang
    ";
    AudioRecoder audioHandler = null;


    @Override
    protected void pluginInitialize() {
        audioHandler = new AudioRecoder(this, "engkoo", "engkoo.amr");
//        audioHandler.webView = this.webView;
//        audioHandler.cordova = this.cordova;
    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) {

        if("show".equals(action)){
            accessToken = args.optString(0);
            this.cordova.getActivity().runOnUiThread(this);
        }

        return true;
    }


    @Override
    public void run(){

        BridgeWebView webView = new BridgeWebView(cordova.getActivity());

        dialog = new EngkooDialog(cordova.getActivity());
        dialog.setWebview(webView);

        webView.loadUrl(engkooHomeUrl);
        webView.registerHandler("voiceRequestFromWeb", this);

        dialog.show();

    }

    @Override
    public void handler(String data, CallBackFunction function) {


        if("Log_In".equals(data)){

            function.onCallBack(accessToken);

        } else if("Voice_Start".equals(data)){

            audioHandler.startRecording("engkoo.amr");
            function.onCallBack("");

        } else if("Voice_Stop".equals(data)){

            String filePath = audioHandler.stopRecording();
            audioHandler.destroy();

            String base64 = this.encodeFile(filePath);
            function.onCallBack(base64);
        }

    }


    private String encodeFile(String filePath) {
        String imgStr = "";
        try {
            Uri _uri = Uri.parse(filePath);
            if (_uri != null && "content".equals(_uri.getScheme())) {
                Cursor cursor = cordova
                        .getActivity()
                        .getContentResolver()
                        .query(_uri,
                                new String[] { android.provider.MediaStore.Images.ImageColumns.DATA },
                                null, null, null);
                cursor.moveToFirst();
                filePath = cursor.getString(0);
                cursor.close();
            } else {
                filePath = _uri.getPath();
            }
            File imageFile = new File(filePath);
            if (!imageFile.exists())
                return imgStr;

            byte[] bytes = new byte[(int) imageFile.length()];

            FileInputStream fileInputStream = new FileInputStream(imageFile);
            fileInputStream.read(bytes);

            imgStr = Base64.encodeToString(bytes, Base64.NO_WRAP);
//            imgStr = "data:image/*;charset=utf-8;base64," + imgStr;
        } catch (Exception e) {
            return imgStr;
        }
        return imgStr;
    }
}
