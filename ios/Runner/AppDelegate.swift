import UIKit
import Flutter

// 插入这段代码来修复阿里 SDK 的协议冲突
protocol Launcher {
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?)
}

extension UIApplication: Launcher {
    // 阿里 SDK 要求的兼容性代码
      func open(_ url: URL, options: [OpenExternalURLOptionsKey : Any], completionHandler completion: ((Bool) -> Void)?) {
            self.open(url, options: options, completionHandler: completion)
            }
}


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
