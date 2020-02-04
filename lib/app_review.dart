import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AppReview {
  static const MethodChannel _channel = MethodChannel('app_review');

  /// Request review.
  ///
  /// Tells StoreKit to ask the user to rate or review your app, if appropriate.
  /// Supported only in iOS 10.3+ (see [isRequestReviewAvailable]).
  ///
  /// Returns string with details message.
  static Future<String> get requestReview async {
    if (Platform.isIOS) {
      final String details = await _channel.invokeMethod('requestReview');
      return details;
    } else {
      final String details = await storeListing;
      return details;
    }
  }

  /// Check if [requestReview] feature available.
  static Future<bool> get isRequestReviewAvailable async {
    if (Platform.isIOS) {
      final String result = await _channel.invokeMethod('isRequestReviewAvailable');
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
      final String _appID = await getiOSAppID;
      String details = '';
      final String _url =
          'itunes.apple.com/app/id$_appID?mt=8&action=write-review';
      if (await canLaunch("itms-apps://")) {
        print('launching store page');
        await launch("itms-apps://" + _url);
        details = 'Launched App Store Directly: $_url';
      } else {
        await launch("https://" + _url);
        details = 'Launched App Store: $_url';
      }
      return details;
    } else {
      final String details = await storeListing;
      return details;
    }
  }

  /// Navigates to Store Listing in Google Play/App Store.
  ///
  /// Returns string with details message.
  static Future<String> get storeListing async {
    String details = '';
    if (Platform.isIOS) {
      final String _appID = await getiOSAppID;
    if (_appID.isNotEmpty) {
        await launch('https://itunes.apple.com/app/id$_appID?');
        details = 'Launched App Store';
      } else {
        details = 'Not found in App Store';
      }
    } else {
      final String _appID = await getAppID;
      if (await canLaunch("market://")) {
        print('launching store page');
        await launch("market://details?id=" + _appID);
        details = 'Launched App Store Directly: $_appID';
      } else {
        await launch("https://play.google.com/store/apps/details?id=" + _appID);
        details = 'Launched App Store: $_appID';
      }
    }
    return details;
  }

  /// Returns package name for application.
  static Future<String> get getAppID async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final String appName = packageInfo.appName;
    final String packageName = packageInfo.packageName;
    final String version = packageInfo.version;
    final String buildNumber = packageInfo.buildNumber;

    print(
        "App Name: $appName\nPackage Name: $packageName\nVersion: $version\nBuild Number: $buildNumber");

    return packageName;
  }

  /// Returns Apple ID for iOS application.
  ///
  /// If there is no such application in App Store - returns empty string.
  static Future<String> get getiOSAppID async {
    final String _appID = await getAppID;
    String _id = '';
    await http
        .get('http://itunes.apple.com/lookup?bundleId=$_appID')
        .then((dynamic response) {
      final Map<String, dynamic> _json = json.decode(response.body);
      if (_json['resultCount'] > 0) {
        _id = _json['results'][0]['trackId'].toString();
        print('Track ID: $_id');
      } else {
        print('Application with bundle "$_appID" is not found on App Store');
      }
    });
    return _id;
  }
}
