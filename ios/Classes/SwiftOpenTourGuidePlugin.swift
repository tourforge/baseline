import Flutter
import UIKit

public class SwiftOpenTourGuidePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let factory = MapLibreNativeViewFactory(messenger: registrar.messenger())
      registrar.register(
          factory,
          withId: "org.opentourbuilder.guide.MapLibrePlatformView")
  }
}
