#import "TourForgeBaselinePlugin.h"
#if __has_include(<tourforge_baseline/tourforge_baseline-Swift.h>)
#import <tourforge_baseline/tourforge_baseline-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tourforge_baseline-Swift.h"
#endif

@implementation TourForgeBaselinePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTourForgeBaselinePlugin registerWithRegistrar:registrar];
}
@end
