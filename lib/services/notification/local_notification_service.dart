import 'dart:async';
import 'package:flutter/foundation.dart';

import 'notification_service.dart';

/// Stub class for PendingNotificationRequest
class PendingNotificationRequest {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  PendingNotificationRequest({
    required this.id,
    this.title,
    this.body,
    this.payload,
  });
}

/// Stub implementation of NotificationService when flutter_local_notifications is not available
class LocalNotificationService implements NotificationService {
  @override
  Future<bool> initialize() async {
    return false; // Always false for stub
  }
  @override
  Future<bool> requestPermissions() async {
    return false; // Always false for stub
  }
  @override
  Future<bool> get hasPermissions async {
    return false; // Always false for stub
  }

  void dispose() {
    // No-op for stub
  }
  @override
  noSuchMethod(Invocation invocation) {
    if (kDebugMode) {
      // print('Stub: NotificationService method ${invocation.memberName} called');
    }
    
    // Return appropriate default values based on return type
    final returnType = invocation.memberName.toString();
    if (returnType.contains('Future<bool>')) {
      return Future.value(false);
    } else if (returnType.contains('Future<int?>')) {
      return Future.value(null);
    } else if (returnType.contains('Future<List<')) {
      return Future.value([]);
    } else if (returnType.contains('Future<void>')) {
      return Future.value();
    } else if (returnType.contains('Stream<')) {
      return const Stream.empty();
    } else if (returnType.contains('Future<DateTime?>')) {
      return Future.value(null);
    }
    
    return super.noSuchMethod(invocation);
  }
}