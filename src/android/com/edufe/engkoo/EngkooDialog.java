package com.edufe.engkoo;

import android.app.Dialog;
import android.content.Context;
import android.view.View;
import android.widget.Button;

import com.github.lzyzsd.jsbridge.BridgeWebView;

public class EngkooDialog extends Dialog {

    public BridgeWebView webview = null;

    public EngkooDialog(Context context) {


        super(context, android.R.style.Theme_NoTitleBar);

        setContentView(getIdentifier("engkoodialog", "layout"));

        webview = (BridgeWebView) findViewById("webview");

        Button button = (Button) findViewById("close");

        button.setOnClickListener(new View.OnClickListener(){
            @Override
            public void onClick(View view){
                dismiss();
            }
        });
    }


    public void onBackPressed () {

        if(this.webview.canGoBack()) {
            this.webview.goBack();
        } else {
            this.dismiss();
        }

    }


    @Override
    public void dismiss() {
        super.dismiss();
    }


    /**
     * findViewById
     *
     * @param viewId
     * @return
     */
    private View findViewById(String viewId) {
        return this.findViewById(getIdentifier(viewId, "id"));
    }

    /**
     * getIdentifier
     *
     * @param viewId
     * @param type
     * @return
     */
    private int getIdentifier(String viewId, String type) {
        Context activity = this.getContext();
        return activity.getResources().getIdentifier(viewId, type, activity.getPackageName());
    }
}
