import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

Future<PackageInfo> getPackageInfo() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();

  final String appName = packageInfo.appName;
  final String packageName = packageInfo.packageName;
  final String version = packageInfo.version;
  final String buildNumber = packageInfo.buildNumber;

  debugPrint("""
App Name: $appName
Package Name: $packageName
Version: $version
Build Number: $buildNumber
""");

  return packageInfo;
}

Future<String> getPackageName() async {
  final info = await getPackageInfo();
  return info.packageName;
}
