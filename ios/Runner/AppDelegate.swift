import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)

    // Register MethodChannel using Plugin Registrar (works 100% even if window is nil)
    let registrar = self.registrar(forPlugin: "NativeBridgePlugin")
    if let messenger = registrar?.messenger() {
      let nativeChannel = FlutterMethodChannel(
        name: "com.ceriya.offline_task_manager/native",
        binaryMessenger: messenger
      )
      
      nativeChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "getBatteryLevel" {
          #if targetEnvironment(simulator)
          // Simulator does not have a physical battery, return mock 100%
          result(100)
          #else
          let device = UIDevice.current
          device.isBatteryMonitoringEnabled = true
          if device.batteryState == .unknown {
            result(FlutterError(code: "UNAVAILABLE", message: "Battery info unavailable", details: nil))
          } else {
            result(Int(device.batteryLevel * 100))
          }
          #endif
        } else if call.method == "triggerHaptic" {
          let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
          feedbackGenerator.prepare()
          feedbackGenerator.impactOccurred()
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }

    // Set notification center delegate for foreground banners
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .list, .sound, .badge])
    } else {
      completionHandler([.alert, .sound, .badge])
    }
  }
}