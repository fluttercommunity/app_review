import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class AppReview {
  static const MethodChannel _channel = const MethodChannel('app_review');

  static Future<String> get requestReview async {
    if (Platform.isIOS) {
      final String details = await _channel.invokeMethod('requestReview');
      return details;
    } else {
      final String details = await storeListing;
      return details;
    }
  }

  static Future<String> get writeReview async {
    if (Platform.isIOS) {
      String _appID = await getiOSAppID;
      String details = '';
      String _url =
          'itunes.apple.com/us/app/id$_appID?mt=8&action=write-review';
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

  static Future<String> get storeListing async {
    String details = '';
    if (Platform.isIOS) {
      String _appID = await getiOSAppID;
      await launch('https://itunes.apple.com/us/app/id$_appID?');
      details = 'Launched App Store';
    } else {
      String details = '';
      String _appID = await getAppID;
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

  static Future<String> get getAppID async {
    final String details = await _channel.invokeMethod('getAppID');
    return details;
  }

  static Future<String> get getiOSAppID async {
    final String _appID = await getAppID;
    String _id = '';
    await http
        .get('http://itunes.apple.com/lookup?bundleId=$_appID')
        .then((response) {
      Map<String, dynamic> _json = json.decode(response.body);
      _id = _json['results'][0]['trackId'].toString();
      print('Track ID: $_id');
    });
    return _id;
  }
}
