#import "OpenTourGuidePlugin.h"
#if __has_include(<opentourguide/opentourguide-Swift.h>)
#import <opentourguide/opentourguide-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "opentourguide-Swift.h"
#endif

@implementation OpenTourGuidePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftOpenTourGuidePlugin registerWithRegistrar:registrar];
}
@end
