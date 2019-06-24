#import "Engkoo.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import "CDVInAppBrowser.h"
#import "WebViewJavascriptBridge.h"

#define    TOOLBAR_HEIGHT 44.0
#define    STATUSBAR_HEIGHT 20.0
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation Engkoo

- (void) show:(CDVInvokedUrlCommand*)command
{
    NSString *token = [command.arguments objectAtIndex:0];
    
    NSString *address = @"https://dev-mtutor.chinacloudsites.cn/dist/app-scenario-lesson/?origin=ios-xinfangxiang";
    
    [self initView];
    
    
    NSURL* url = [NSURL URLWithString:address];
    NSURLRequest* request = [NSURLRequest requestWithURL: url];
    [_webview loadRequest:request];
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webview];
    [_bridge setWebViewDelegate:self];
    
    [_bridge registerHandler:@"Log_In" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(token);
    }];
    
    
    [_bridge registerHandler:@"startRecord" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
//        [self stopRecordingAudio];
        [self startRecording];
        responseCallback(@"");
    }];
    
    [_bridge registerHandler:@"stopRecord" handler:^(id data, WVJBResponseCallback responseCallback) {
        
    
//        [self stopRecordingAudio];
        [self stopRecording];

        NSError *error;
        
        NSString *file = [NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, @"engkoo.caf"];
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:file ofType:nil];
        
        NSData *fileData = [[NSData alloc] initWithContentsOfFile: file options:NSDataReadingMappedIfSafe error:&error];
        NSString *base64String = [fileData base64EncodedStringWithOptions:0];
       
        NSLog(@"testObjcCallback called: %@", data);
        
        responseCallback(base64String);
    }];
}


- (void) initView {
    
    UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    
    UIView *rootView = rootViewController.view ;
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    _containerView.backgroundColor = UIColor.blueColor;
    
    [rootView addSubview:_containerView];
    
    /////////  toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, TOOLBAR_HEIGHT+STATUSBAR_HEIGHT)];
    
    toolbar.tintColor = [UIColor blackColor];
    toolbar.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    
    UIBarButtonItem *titleItem = [[UIBarButtonItem alloc] initWithTitle:@"微软小英" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    toolbar.items = @[cancelButton, flexibleSpaceItem, titleItem, flexibleSpaceItem, flexibleSpaceItem];
    
    [_containerView addSubview:toolbar];
    
    
    //////  webview
    _webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, frame.size.width, frame.size.height - 64)];
    _webview.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [_containerView addSubview:_webview];
}


- (void) close{
    NSLog(@"close");
    
    [_containerView removeFromSuperview];
}

- (void)startRecordingAudio
{
    NSMutableDictionary *audioSettings = [NSMutableDictionary dictionaryWithDictionary:
                                          @{AVSampleRateKey: @(44100),
                                            AVNumberOfChannelsKey: @(1),
                                            }];
    
    audioSettings[AVFormatIDKey]=@(kAudioFormatLinearPCM);
    audioSettings[AVLinearPCMBitDepthKey]=@(16);
    audioSettings[AVLinearPCMIsBigEndianKey]=@(false);
    audioSettings[AVLinearPCMIsFloatKey]=@(false);
    
    NSString *file = [NSString stringWithFormat:@"%@/Documents/engkoo.wav",NSHomeDirectory()];
    NSURL *url = [NSURL fileURLWithPath: file];

    NSError *err = nil;
    self.audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url
                                                 settings: audioSettings
                                                    error:&err];
    
    //prepare to record
    [_audioRecorder setDelegate:self];
    [_audioRecorder prepareToRecord];
    _audioRecorder.meteringEnabled = YES;
    [_audioRecorder recordForDuration:(NSTimeInterval)10000000000];
    bool result = [_audioRecorder record];
    
    NSLog(@"");
}

- (void)stopRecordingAudio
{
    if(self.audioRecorder != nil)
        [self.audioRecorder stop];
}

- (void) pluginInitialize{
    NSLog(@"初始化插件");
    //    [[TICManager sharedInstance] initSDK: @"1400204887"];
}






- (void) startRecording{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    [audioSession overrideOutputAudioPort: AVAudioSessionPortOverrideSpeaker error:&err];
    
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

    
    // Create a new dated file
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    
    NSString *recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, @"engkoo.caf"];
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    _audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!_audioRecorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    }
    
    //prepare to record
    [_audioRecorder setDelegate:self];
    [_audioRecorder prepareToRecord];
    _audioRecorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        NSLog(@"!audioHWAvailable");
    }
    
    // start recording
    [_audioRecorder recordForDuration:(NSTimeInterval) 10];

}

- (void) stopRecording{
    
    [_audioRecorder stop];
    
    NSString *recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, @"engkoo.caf"];
    
    NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
    NSError *err = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if(!audioData)
    NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    
    //[recorder deleteRecording];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    err = nil;
//    [fm removeItemAtPath:[url path] error:&err];
    if(err)
    NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
    
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
    
    NSLog (@"audioRecorderDidFinishRecording:successfully:");
    // your actions here
    
}


@end



