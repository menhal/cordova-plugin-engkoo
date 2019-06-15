package com.edufe.engkoo;

import android.app.Dialog;
import android.content.Context;
import android.view.WindowManager;
import android.webkit.WebView;

public class EngkooDialog extends Dialog {

    private WebView webview = null;

    public EngkooDialog(Context context) {
        super(context, android.R.style.Theme_NoTitleBar);
        this.getWindow().getAttributes().windowAnimations = android.R.style.Animation_Dialog;
    }


    @Override
    public void show(){
        super.show();

        WindowManager.LayoutParams lp = new WindowManager.LayoutParams();
        lp.copyFrom(this.getWindow().getAttributes());
        lp.width = WindowManager.LayoutParams.MATCH_PARENT;
        lp.height = WindowManager.LayoutParams.MATCH_PARENT;
        this.addContentView(webview, lp);
    }

    public void setWebview(WebView webview) {
        this.webview = webview;
    }

    public void onBackPressed () {

        if(this.webview.canGoBack()) {
            this.webview.goBack();
        } else {
            this.dismiss();
        }

    }
}
