import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class AppReview {
  static const MethodChannel _channel = const MethodChannel('app_review');

  static Future<String> get requestReview async {
    final String details = await _channel.invokeMethod('requestReview');
    return details;
  }

  static Future<String> get writeReview async {
    if (Platform.isIOS) {
      String _appID = await getiOSAppID;
      String details = '';
      String _url = 'itunes.apple.com/app/id$_appID?action=write-review';
      if (await canLaunch("itms-apps://")) {
        print('launching store page');
        _url = "itms-apps://" + _url;
        await launch(_url);
        details = 'Launched App Store Directly: $_url';
      } else {
        _url = "https://" + _url;
        await launch(_url);
        details = 'Launched App Store: $_url';
      }
      return details;
    } else {
      final String details = await _channel.invokeMethod('writeReview');
      return details;
    }
  }

  static Future<String> get storeListing async {
    String details = '';
    if (Platform.isIOS) {
      String _appID = await getiOSAppID;
      await launch(
          'https://itunes.apple.com/app/id$_appID?action=write-review');
      details = 'Launched App Store';
    } else {
      details = await _channel.invokeMethod('storeListing');
    }
    return details;
  }

  static Future<String> get getAppID async {
    final String details = await _channel.invokeMethod('getAppID');
    return details;
  }

  static Future<String> get getiOSAppID async {
    final String _appID = await _channel.invokeMethod('getAppID');
    String _id = '';
    await http
        .get('http://itunes.apple.com/lookup?bundleId=$_appID')
        .then((response) {
      Map<String, dynamic> _json = json.decode(response.body);
      _id = _json['results'][0]['artistId'].toString();
      print('Artist ID: $_id');
    });
    return _id;
  }
}
