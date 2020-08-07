import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const kItunesUrl = 'https://itunes.apple.com/app/id';
String iosReviewUrlBase(String appId) =>
    'itunes.apple.com/app/id$appId?mt=8&action=write-review';

/// Returns Apple ID for iOS application.
///
/// If there is no such application in App Store - returns empty string.
Future<String> getIosAppId(String appId) async {
  String _id = '';
  final response =
      await http.get('http://itunes.apple.com/lookup?bundleId=$appId');
  final Map<String, dynamic> _json = json.decode(response.body);
  if (_json['resultCount'] > 0) {
    _id = _json['results'][0]['trackId'].toString();
    print('Track ID: $_id');
  } else {
    print('Application with bundle "$appId" is not found on App Store');
  }
  return _id;
}

Future<String> writeIosReview(String appId) async {
  String details = '';
  final String _url = iosReviewUrlBase(appId);
  if (await canLaunch("itms-apps://")) {
    print('launching store page');
    await launch("itms-apps://" + _url);
    details = 'Launched App Store Directly: $_url';
  } else {
    await launch("https://" + _url);
    details = 'Launched App Store: $_url';
  }
  return details;
}
