import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppReview {
  static const Duration kDefaultDuration = Duration(minutes: 5);
  static const MethodChannel _channel = MethodChannel('app_review');

  //----------------------------------------------------------------------------
  // Maintain original interface
  //----------------------------------------------------------------------------

  /// Returns package name for application.
  static Future<String?> get getAppID => getBundleName();

  /// Returns Apple ID for iOS application.
  ///
  /// If there is no such application in App Store - returns empty string.
  static Future<String?> get getiOSAppID => getIosAppId();

  /// Request review.
  ///
  /// Tells StoreKit / Play Store to ask the user to rate or review your app, if appropriate.
  /// Supported only in iOS 10.3+ and Android with Play Services installed (see [isRequestReviewAvailable]).
  ///
  /// Returns string with details message.
  static Future<String?> get requestReview async {
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
  static Future<Timer> requestReviewDelayed([Duration? duration]) async =>
      Timer(duration ?? kDefaultDuration, () => requestReview);

  /// Check if [requestReview] feature available.
  static Future<bool> get isRequestReviewAvailable async {
    if (Platform.isIOS || Platform.isAndroid) {
      try {
        final result =
            await _channel.invokeMethod<String>('isRequestReviewAvailable');
        return result == '1';
      } finally {}
    }

    return false;
  }

  /// Open store page with action write review.
  ///
  /// Supported only for iOS, on Android [storeListing] will be executed.
  static Future<String?> get writeReview async {
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
  static Future<String?> get storeListing async {
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

  static PackageInfo? _packageInfo;
  static String? _appCountry;
  static String? _appBundle;
  static String? _appId;

  /// It would be great if I could add country code into AppStore lookup URL.
  /// Eg: AppReview.setCountryCode('jp');
  static void setCountryCode(String code) =>
      _appCountry = code.isEmpty ? null : code;

  /// Require app review for iOS
  static Future<String?> openIosReview({
    String? appId,
    bool compose = false,
  }) async {
    if (compose) {
      final id = appId ?? (await getIosAppId()) ?? '';
      final reviewUrl = 'itunes.apple.com/app/id$id?mt=8&action=write-review';
      final uri = Uri.parse('itms-apps://$reviewUrl');
      if (await canLaunchUrl(uri)) {
        debugPrint('launching store page');
        await launchUrl(uri);
        return 'Launched App Store Directly: $reviewUrl';
      }

      await launchUrl(Uri.parse('https://$reviewUrl'));
      return 'Launched App Store: $reviewUrl';
    }

    try {
      return _channel.invokeMethod<String>('requestReview');
    } finally {}
  }

  /// Require app review for Android
  static Future<String?> openAndroidReview() {
    try {
      return _channel.invokeMethod<String>('requestReview');
    } on Error {
      return openGooglePlay();
    }
  }

  /// Open in AppStore
  static Future<String> openAppStore({String? fallbackUrl}) async {
    final appId = await getIosAppId() ?? '';

    if (appId.isNotEmpty) {
      launchUrl(Uri.parse('https://itunes.apple.com/app/id$appId'),
          mode: LaunchMode.externalApplication);
      return 'Launched App Store';
    }

    if (fallbackUrl != null) {
      launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
      return 'Launched App Store via $fallbackUrl';
    }

    return 'Not found in App Store';
  }

  /// Open in GooglePlay
  static Future<String> openGooglePlay({String? fallbackUrl}) async {
    final bundle = await getBundleName() ?? '';
    final markerUrl = 'market://details?id=$bundle';
    final uri = Uri.parse(markerUrl);
    if (await canLaunchUrl(uri)) {
      debugPrint('launching store page');
      launchUrl(uri, mode: LaunchMode.externalApplication);
      return 'Launched Google Play Directly: $bundle';
    }

    if (fallbackUrl != null) {
      launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
      return 'Launched Google Play via $fallbackUrl';
    }

    launchUrl(
        Uri.parse('https://play.google.com/store/apps/details?id=$bundle'));
    return 'Launched Google Play: $bundle';
  }

  /// Lazy load package info instance
  static Future<PackageInfo?> getPackageInfo() async {
    _packageInfo ??= await PackageInfo.fromPlatform();

    debugPrint('App Name: ${_packageInfo!.appName}\n'
        'Package Name: ${_packageInfo!.packageName}\n'
        'Version: ${_packageInfo!.version}\n'
        'Build Number: ${_packageInfo!.buildNumber}');

    return _packageInfo;
  }

  /// Get app bundle name
  static Future<String?> getBundleName() async {
    _appBundle ??= (await getPackageInfo())?.packageName ?? '';
    return _appBundle;
  }

  /// Get app's AppStore ID (public app only)
  static Future<String?> getIosAppId({
    String? countryCode,
    String? bundleId,
  }) async {
    // If bundle name is not provided
    // then fetch and return the app ID from cache (if available)
    if (bundleId == null) {
      _appId ??= await getIosAppId(
        bundleId: await getBundleName(),
        countryCode: countryCode,
      );

      return _appId;
    }

    // Else fetch from AppStore
    final String id = bundleId;
    final String country = countryCode ?? _appCountry ?? '';
    String? appId;

    if (id.isNotEmpty) {
      try {
        final result = await http
            .get(Uri.parse(
                'https://itunes.apple.com/$country/lookup?bundleId=$id'))
            .timeout(const Duration(seconds: 5));
        final Map json = jsonDecode(result.body);
        appId = json['results'][0]['trackId']?.toString();
      } finally {
        if (appId?.isNotEmpty == true) {
          debugPrint('Track ID: $appId');
        } else {
          debugPrint('Application with bundle $id is not found on App Store');
        }
      }
    }

    return appId ?? '';
  }
}
