import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // MethodChannel configured with the matching bundle ID
    let nativeChannel = FlutterMethodChannel(
      name: "com.ceriya.offline_task_manager/native",
      binaryMessenger: controller.binaryMessenger
    )
    
    nativeChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getBatteryLevel" {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState == .unknown {
          result(FlutterError(code: "UNAVAILABLE", message: "Battery info unavailable", details: nil))
        } else {
          result(Int(device.batteryLevel * 100))
        }
      } else if call.method == "triggerHaptic" {
        // Trigger haptic impact for iOS devices
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    // Present notifications as banners even when app is running in foreground
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}