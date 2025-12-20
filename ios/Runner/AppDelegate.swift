import Flutter
import UIKit

import flutter_livepush_plugin

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 2. 关键：在这里手动注册插件，不完全依赖 GeneratedPluginRegistrant
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    // 如果下面这行报错，可以尝试先注释掉，看看能否编译通过
    // AlivcLivePusherPlugin.register(with: self.registrar(forPlugin: "AlivcLivePusherPlugin")!)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}