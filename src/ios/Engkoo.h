#import <Cordova/CDV.h>
#import "CDVInAppBrowser.h"
#import "WebViewJavascriptBridge.h"
#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVFoundation.h>

@interface Engkoo : CDVPlugin {
    NSString *callbackId;
}

@property (nonatomic) CDVInAppBrowser *inAppBrowser;
@property WebViewJavascriptBridge* bridge;
@property AVAudioRecorder *audioRecorder;
@property UIView *containerView;
@property WKWebView *webview;

- (void) show:(CDVInvokedUrlCommand*) command;

@end
