#import <Cordova/CDV.h>
#import "CDVInAppBrowser.h"
#import "WebViewJavascriptBridge.h"

@interface Engkoo : CDVPlugin {
    NSString *callbackId;
}

@property (nonatomic) CDVInAppBrowser *inAppBrowser;
@property WebViewJavascriptBridge* bridge;

- (void) show:(CDVInvokedUrlCommand*) command;

@end
