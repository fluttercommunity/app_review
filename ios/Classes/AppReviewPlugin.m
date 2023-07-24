#import "AppReviewPlugin.h"
#import <app_review_plus/app_review_plus-Swift.h>

@implementation AppReviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppReviewPlugin registerWithRegistrar:registrar];
}
@end
