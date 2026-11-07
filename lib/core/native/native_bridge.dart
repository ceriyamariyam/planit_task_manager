import 'package:flutter/services.dart';

class NativeBridge {
  // Unique channel identifier matching native Android and iOS configurations
  static const MethodChannel _channel =
      MethodChannel('com.ceriya.offline_task_manager/native');

  // Fetch device battery percentage from native platform
  static Future<int> getBatteryLevel() async {
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException {
      // Return -1 in case of native platform error or unavailable battery info
      return -1;
    }
  }

  // Trigger native tactile/haptic feedback on Android and iOS
  static Future<void> triggerNativeHaptic() async {
    try {
      await _channel.invokeMethod('triggerHaptic');
    } on PlatformException {
      // Gracefully ignore if the device does not support vibration
    }
  }
}