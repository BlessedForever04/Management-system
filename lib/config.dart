import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class Config {
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
<<<<<<< HEAD
    if (_apiBaseUrl.isNotEmpty) {
      return _apiBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      // Android emulator reaches host machine through 10.0.2.2.
=======
    if (kIsWeb) {
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
>>>>>>> 8d4a326 (start date selection , projects loading in admin , seach on member and title)
      return 'http://10.0.2.2:8080';
    } else {
      return 'http://localhost:8080';
    }
  }
}

