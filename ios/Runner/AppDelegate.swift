import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.yourapp/search_engine_detection"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

    methodChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getInstalledSearchEngines" {
        result(self.getInstalledBrowsers())
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getInstalledBrowsers() -> [String] {
    var browsers = [String]()
    let urlSchemes = [
      "googlechrome://": "Chrome",
      "firefox://": "Firefox",
      "microsoft-edge://": "Edge",
      "opera://": "Opera",
      "brave://": "Brave",
      "http://": "Safari"  // Safari is always available on iOS
    ]

    for (scheme, name) in urlSchemes {
      if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
        browsers.append(name)
      }
    }
    return browsers
  }
}
