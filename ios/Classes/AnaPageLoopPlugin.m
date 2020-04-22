#import "AnaPageLoopPlugin.h"
#if __has_include(<ana_page_loop/ana_page_loop-Swift.h>)
#import <ana_page_loop/ana_page_loop-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ana_page_loop-Swift.h"
#endif

@implementation AnaPageLoopPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAnaPageLoopPlugin registerWithRegistrar:registrar];
}
@end
