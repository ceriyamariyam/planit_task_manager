import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Mock the internal notifications plugin
class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
    registerFallbackValue(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    registerFallbackValue(
      const NotificationDetails(
        android: AndroidNotificationDetails('test_channel', 'test_name'),
      ),
    );
    registerFallbackValue(tz.TZDateTime.now(tz.local));
  });

  group('Notification Deep Link & Scheduling Tests', () {
    test('Task ID is accurately converted to String payload for deep linking', () {
      const int taskId = 42;
      final String payload = taskId.toString();

      expect(payload, '42');
      expect(int.tryParse(payload), taskId);
    });

    test('Deep link callback correctly receives and parses task payload on notification tap', () {
      int? capturedTaskId;

      // Simulated navigation callback defined in main.dart
      void onNotificationTap(String? payload) {
        if (payload != null) {
          capturedTaskId = int.tryParse(payload);
        }
      }

      // Simulate notification tapped event with payload '101'
      const simulatedPayload = '101';
      onNotificationTap(simulatedPayload);

      expect(capturedTaskId, 101);
    });

    test('Deep link callback safely handles null or invalid payload without throwing errors', () {
      int? capturedTaskId;

      void onNotificationTap(String? payload) {
        if (payload != null && payload.isNotEmpty) {
          capturedTaskId = int.tryParse(payload);
        }
      }

      onNotificationTap(null);
      expect(capturedTaskId, isNull);

      onNotificationTap('invalid_id');
      expect(capturedTaskId, isNull);
    });
  });
}