#import "FlutterZipArchivePlugin.h"
#import "SSZipArchive.h"

@implementation FlutterZipArchivePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_zip_archive"
            binaryMessenger:[registrar messenger]];
  FlutterZipArchivePlugin* instance = [[FlutterZipArchivePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"zip" isEqualToString:call.method]) {
    [self zip:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(NSString *)isStringEmpty:(NSString *)str {
     if(str == nil || [str isKindOfClass:[NSNull class]] || str.length==0) {
       return nil;
     }
     return str;
}

- (void)zip:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *src = call.arguments[@"src"];
    NSString *dest = call.arguments[@"dest"];
    NSString *pass = call.arguments[@"password"];
    NSLog(@"Zip %@->%@",src,dest);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir,success;

    [fileManager fileExistsAtPath:src isDirectory:&isDir];
    if(isDir) {
         success = [SSZipArchive createZipFileAtPath:dest
                             withContentsOfDirectory:src
                                 keepParentDirectory:NO
                                    compressionLevel:-1
                                            password:[self isStringEmpty:pass]
                                                 AES:NO
                                     progressHandler:nil];
    } else {
         SSZipArchive *zipArchive = [[SSZipArchive alloc] initWithPath:dest];
         success = [zipArchive open];
         if(success) {
            success &= [zipArchive writeFileAtPath:src
                                      withFileName:src.lastPathComponent
                                   compressionLevel:-1
                                           password:[self isStringEmpty:pass]
                                                AES:NO];
            success &= [zipArchive close];
         }
    }

    if(success){
        //NSLog(@"Len %d",[[fileManager attributesOfItemAtPath: dest error:nil] fileSize]);
        result(@"Success");
    } else {
        result([FlutterError
            errorWithCode:@"Error zip"
            message:@"Error zip"
            details:nil]);
    }
}

@end
