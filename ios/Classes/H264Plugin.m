#import "H264Plugin.h"
#import <h264/h264-Swift.h>
#import <Foundation/Foundation.h>

@interface H264Plugin() {
    dispatch_queue_t queue;
}

@end

@implementation H264Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"asia.ivity.flutter/h264"
                                     binaryMessenger:[registrar messenger]];
    H264Plugin* instance = [[H264Plugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    if (self = [super init]) {
        queue = dispatch_queue_create("h264 decoder", nil);
    }
    
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"decode" isEqualToString:call.method]) {
        NSDictionary *params = call.arguments;
        [self handleDecode:params result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)handleDecode:(NSDictionary*)params result:(FlutterResult)result {
    dispatch_async(queue, ^{
        NSURL *source = [NSURL URLWithString:params[@"source"]];
        NSURL *target = [NSURL URLWithString:params[@"target"]];
        NSError *error;
        H264Reader *reader = [[H264Reader alloc] initWithUrl:source error:&error];
        if (error) {
            result([FlutterError errorWithCode:@"h264" message:nil details:nil]);
            return;
        }
        [reader convertWithTarget:target error:&error];
        if (error) {
            result([FlutterError errorWithCode:@"h264" message:nil details:nil]);
        } else {
            result(target.absoluteString);
        }
    });

}

@end
