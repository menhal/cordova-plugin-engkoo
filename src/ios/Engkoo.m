#import "Engkoo.h"
#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>
#import "CDVInAppBrowser.h"
#import "WebViewJavascriptBridge.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation Engkoo

- (void) show:(CDVInvokedUrlCommand*)command
{
    NSString *token = [command.arguments objectAtIndex:0];
    

    
    self.inAppBrowser = [[CDVInAppBrowser alloc] init];
    [self.inAppBrowser pluginInitialize];
    
    NSString *address = @"https://dev-mtutor.chinacloudsites.cn/dist/app-scenario-lesson/?origin=ios-bingdict";
    
    NSString *options = @"hideurlbar=yes&,hidenavigationbuttons=yes,toolbarcolor=#ffffff,toolbarposition=top,closebuttoncaption=关闭,location=no";

    NSArray *args =   [NSArray arrayWithObjects: address, @"_blank", options, nil];
    
    CDVInvokedUrlCommand *cmd = [[CDVInvokedUrlCommand alloc] initWithArguments: args callbackId: command.callbackId className:@"InAppBrowser" methodName:@"open"];
    
    [self.inAppBrowser open:cmd];
    
    
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView: self.inAppBrowser.inAppBrowserViewController.webView];
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



