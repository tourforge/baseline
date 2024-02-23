import Flutter
import UIKit

public class SwiftTourForgePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let factory = MapLibreNativeViewFactory(messenger: registrar.messenger())
      registrar.register(
          factory,
          withId: "org.tourforge.guide.MapLibrePlatformView")
  }
}
