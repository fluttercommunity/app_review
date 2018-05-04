import 'dart:async';

import 'package:flutter/services.dart';

class AppReview {
  static const MethodChannel _channel = const MethodChannel('app_review');

  static Future<String> get requestReview async {
    final String details = await _channel.invokeMethod('requestReview');
    return details;
  }

  static Future<String> get writeReview async {
    final String details = await _channel.invokeMethod('writeReview');
    return details;
  }

  static Future<String> get storeListing async {
    final String details = await _channel.invokeMethod('storeListing');
    return details;
  }

  static Future<String> get getAppID async {
    final String details = await _channel.invokeMethod('getAppID');
    return details;
  }
}
