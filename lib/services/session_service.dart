import 'package:flutter/services.dart';

/// Foreground Session Service — Flutter ↔ Android MethodChannel
class SessionService {
  static const _channel = MethodChannel('com.oracleprompter/session');

  /// Start 24h background session
  static Future<bool> start() async {
    try {
      return await _channel.invokeMethod('startSession') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Stop background session
  static Future<bool> stop() async {
    try {
      return await _channel.invokeMethod('stopSession') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if session is running
  static Future<bool> isRunning() async {
    try {
      return await _channel.invokeMethod('isSessionRunning') ?? false;
    } catch (e) {
      return false;
    }
  }
}
