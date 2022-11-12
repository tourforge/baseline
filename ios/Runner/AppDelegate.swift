import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
    weak var registrar = self.registrar(forPlugin: "opentourbuilder_guide")!
      
      let factory = MapLibreNativeViewFactory(messenger: registrar!.messenger())
      
    registrar!.register(
      factory,
      withId: "org.opentourbuilder.guide.MapLibrePlatformView")
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
