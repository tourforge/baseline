import Flutter
import UIKit

public class SwiftTourForgeBaselinePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      let factory = MapLibreNativeViewFactory(messenger: registrar.messenger())
      registrar.register(
          factory,
          withId: "org.tourforge.baseline.MapLibrePlatformView")
  }
}
