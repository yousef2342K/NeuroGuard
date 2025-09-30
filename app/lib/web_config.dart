import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebConfig {
  static void configureWebRenderer() {
    if (kIsWeb) {
      // Configure web-specific settings
      debugPrint('Configuring web renderer for NeuroGuard App');
      
      // Note: Locale setting is handled by the app's MaterialApp widget
      // No need to set platformDispatcher.locale directly
    }
  }
}
