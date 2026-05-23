import 'package:flutter/services.dart';

class AppAlertService {
  static const _channel = MethodChannel('com.smartremind/app_alert');

  /// Check if all required permissions are granted
  Future<Map<String, bool>> checkPermissions() async {
    try {
      final result = await _channel.invokeMapMethod<String, bool>('checkPermissions');
      return result ?? {};
    } catch (e) {
      print('Error checking permissions: $e');
      return {};
    }
  }

  /// Request authorization (iOS: Screen Time, Android: Usage Stats + Overlay)
  Future<bool> requestAuthorization() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestAuthorization');
      return result ?? false;
    } catch (e) {
      print('Error requesting authorization: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('getSettings');
      return result ?? {};
    } catch (e) {
      print('Error loading app alert settings: $e');
      return {};
    }
  }

  Future<void> setSnoozeDuration(int minutes) async {
    try {
      await _channel.invokeMethod('setSnoozeDuration', {'minutes': minutes});
    } catch (e) {
      print('Error saving snooze duration: $e');
    }
  }

  /// Show the app picker (iOS: FamilyActivityPicker, Android: custom UI or fallback)
  Future<void> showAppPicker() async {
    try {
      await _channel.invokeMethod('showAppPicker');
    } catch (e) {
      print('Error showing app picker: $e');
    }
  }

  /// Start monitoring for target apps
  Future<void> startMonitoring() async {
    try {
      await _channel.invokeMethod('startMonitoring');
    } catch (e) {
      print('Error starting monitoring: $e');
    }
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    try {
      await _channel.invokeMethod('stopMonitoring');
    } catch (e) {
      print('Error stopping monitoring: $e');
    }
  }

  /// Update the pending task data that the shield/overlay reads
  Future<void> syncTaskData({
    required int pendingCount,
    required String topCategory,
  }) async {
    try {
      await _channel.invokeMethod('syncTaskData', {
        'pendingCount': pendingCount,
        'topCategory': topCategory,
      });
    } catch (e) {
      print('Error syncing task data: $e');
    }
  }
}
