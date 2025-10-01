import 'package:flutter/foundation.dart';

class NotificationMock {
  static void show(String title, String body) {
    if (kDebugMode) {
      print('[NOTIFICATION] $title — $body');
    }
    
    // In a real app, you would use Firebase Cloud Messaging or local notifications
    // For now, we just print to console for debugging
    debugPrint('🔔 Notification: $title');
    debugPrint('📝 Body: $body');
  }
  
  static void showSuccess(String message) {
    show('نجح', message);
  }
  
  static void showError(String message) {
    show('خطأ', message);
  }
  
  static void showWarning(String message) {
    show('تحذير', message);
  }
  
  static void showInfo(String message) {
    show('معلومات', message);
  }
}
