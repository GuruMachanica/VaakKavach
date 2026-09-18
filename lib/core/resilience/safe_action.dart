import 'dart:async';
import 'package:flutter/foundation.dart';

class SafeAction {
  static Future<T> run<T>({
    required Future<T> Function() action,
    required T fallback,
    String? contextTag,
    void Function(Object error, StackTrace stack)? onError,
  }) async {
    try {
      return await action();
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[Resilience] ${contextTag ?? "Operation"} failed: $e');
      }
      onError?.call(e, stack);
      return fallback;
    }
  }

  static T runSync<T>({
    required T Function() action,
    required T fallback,
    String? contextTag,
    void Function(Object error, StackTrace stack)? onError,
  }) {
    try {
      return action();
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[Resilience] ${contextTag ?? "SyncOperation"} failed: $e');
      }
      onError?.call(e, stack);
      return fallback;
    }
  }
}
