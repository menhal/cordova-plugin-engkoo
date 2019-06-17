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

- (void) show:(CDVInvokedUrlCommand*) command;

@end
