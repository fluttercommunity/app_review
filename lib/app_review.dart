import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AppReview {
  static const Duration kDefaultDuration = Duration(minutes: 5);
  static const MethodChannel _channel = MethodChannel('app_review');

  //----------------------------------------------------------------------------
  // Maintain original interface
  //----------------------------------------------------------------------------

  /// Returns package name for application.
  static Future<String> get getAppID => getBundleName();

  /// Returns Apple ID for iOS application.
  ///
  /// If there is no such application in App Store - returns empty string.
  static Future<String> get getiOSAppID => getIosAppId();

  /// Request review.
  ///
  /// Tells StoreKit / Play Store to ask the user to rate or review your app, if appropriate.
  /// Supported only in iOS 10.3+ and Android with Play Services installed (see [isRequestReviewAvailable]).
  ///
  /// Returns string with details message.
  static Future<String> get requestReview async {
    if (Platform.isIOS) {
      return openIosReview();
    }

    if (Platform.isAndroid) {
      return openAndroidReview();
    }

    return null;
  }

  /// Request review.
  ///
  /// Tells StoreKit to ask the user to rate or review your app, if appropriate.
  /// Supported only in iOS 10.3+ and Android with Play Services installed (see [isRequestReviewAvailable]).
  ///
  /// Returns string with details message.
  static Future<Timer> requestReviewDelayed(
      [Duration duration = kDefaultDuration]) async {
    final Timer _timer = Timer(duration, () => requestReview);
    return _timer;
  }

  /// Check if [requestReview] feature available.
  static Future<bool> get isRequestReviewAvailable async {
    if (Platform.isIOS || Platform.isAndroid) {
      final String result =
          await _channel.invokeMethod('isRequestReviewAvailable');
      return result == "1";
    } else {
      return false;
    }
  }

  /// Open store page with action write review.
  ///
  /// Supported only for iOS, on Android [storeListing] will be executed.
  static Future<String> get writeReview async {
    if (Platform.isIOS) {
      return openIosReview(compose: true);
    }

    if (Platform.isAndroid) {
      return openAndroidReview();
    }

    return null;
  }

  /// Navigates to Store Listing in Google Play/App Store.
  ///
  /// Returns string with details message.
  static Future<String> get storeListing async {
    if (Platform.isIOS) {
      return openAppStore();
    }

    if (Platform.isAndroid) {
      return openGooglePlay();
    }

    return null;
  }

  //----------------------------------------------------------------------------
  // Helper methods (added by @shinsenter)
  //----------------------------------------------------------------------------

  static PackageInfo _packageInfo;
  static String _appCountry;
  static String _appBundle;
  static String _appId;

  /// It would be great if I could add country code into AppStore lookup URL.
  /// Eg: AppReview.setCountryCode('jp');
  static void setCountryCode(String code) =>
      _appCountry = code.isEmpty ? null : code;

  /// Require app review for iOS
  static Future<String> openIosReview({bool compose = false}) async {
    if (compose) {
      final appId = await getIosAppId() ?? '';
      final reviewUrl =
          'itunes.apple.com/app/id$appId?mt=8&action=write-review';

      if (await canLaunch('itms-apps://$reviewUrl')) {
        print('launching store page');
        launch('itms-apps://$reviewUrl');
        return 'Launched App Store Directly: $reviewUrl';
      }

      launch('https://$reviewUrl');
      return 'Launched App Store: $reviewUrl';
    }

    try {
      return _channel.invokeMethod<String>('requestReview');
    } finally {}
  }

  /// Require app review for Android
  static Future<String> openAndroidReview() {
    try {
      return _channel.invokeMethod('requestReview');
    } catch (e) {
      return openGooglePlay();
    }
  }

  /// Open in AppStore
  static Future<String> openAppStore({String fallbackUrl}) async {
    final appId = await getIosAppId() ?? '';

    if (appId.isNotEmpty) {
      launch('https://itunes.apple.com/app/id$appId');
      return 'Launched App Store';
    }

    if (fallbackUrl != null) {
      launch(fallbackUrl);
      return 'Launched App Store via $fallbackUrl';
    }

    return 'Not found in App Store';
  }

  /// Open in GooglePlay
  static Future<String> openGooglePlay({String fallbackUrl}) async {
    final bundle = await getBundleName() ?? '';
    final markerUrl = 'market://details?id=$bundle';

    if (await canLaunch(markerUrl)) {
      print('launching store page');
      launch(markerUrl);
      return 'Launched Google Play Directly: $bundle';
    }

    if (fallbackUrl != null) {
      launch(fallbackUrl);
      return 'Launched Google Play via $fallbackUrl';
    }

    launch('https://play.google.com/store/apps/details?id=$bundle');
    return 'Launched Google Play: $bundle';
  }

  /// Get app bundle name
  static Future<String> getBundleName() async {
    if (_appBundle == null) {
      _packageInfo ??= await PackageInfo.fromPlatform();
      _appBundle ??= _packageInfo?.packageName ?? '';

      print('App Name: ${_packageInfo.appName}\n'
          'Package Name: ${_packageInfo.packageName}\n'
          'Version: ${_packageInfo.version}\n'
          'Build Number: ${_packageInfo.buildNumber}');
    }

    // return _appBundle;
    return 'net.webike.app01';
  }

  /// Get app's AppStore ID (public app only)
  static Future<String> getIosAppId({String countryCode}) async {
    if (_appId == null) {
      final String bundleId = await getBundleName();
      final String country = countryCode ?? _appCountry ?? '';

      try {
        final result = await http
            .get('http://itunes.apple.com/$country/lookup?bundleId=$bundleId')
            .timeout(const Duration(seconds: 5));
        final Map json = jsonDecode(result.body ?? '');
        _appId = json['results'][0]['trackId']?.toString();
      } finally {
        if (_appId?.isNotEmpty == true) {
          print('Track ID: $_appId');
        } else {
          print('Application with bundle $bundleId is not found on App Store');
        }
      }
    }

    return _appId ?? '';
  }
}
