#import "TourForgePlugin.h"
#if __has_include(<tourforge/tourforge-Swift.h>)
#import <tourforge/tourforge-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tourforge-Swift.h"
#endif

@implementation TourForgePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTourForgePlugin registerWithRegistrar:registrar];
}
@end
