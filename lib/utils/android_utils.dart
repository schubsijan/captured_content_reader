import 'package:flutter/services.dart';

class AndroidUtils {
  static const _platform = MethodChannel(
    'com.example.captured_content_reader/android',
  );

  static Future<void> minimizeApp() async {
    try {
      await _platform.invokeMethod('minimizeApp');
    } catch (e) {
      print("Minimize Error: $e");
    }
  }

  static Future<void> closeAppCompletely() async {
    try {
      await _platform.invokeMethod('finishAndRemoveTask');
    } catch (e) {
      // Fallback auf Standard-Pop, falls der native Channel nicht antwortet
      SystemNavigator.pop();
    }
  }
}
