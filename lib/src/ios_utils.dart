import '../app_review.dart';

/// Returns Apple ID for iOS application.
///
/// If there is no such application in App Store - returns empty string.
Future<String?> getIosAppId(String appId, {String? countryCode}) async =>
    AppReview.getIosAppId(bundleId: appId, countryCode: countryCode);

/// Open store page with action write review.
///
/// Supported only for iOS, on Android [storeListing] will be executed.
Future<String?> writeIosReview(String appId, {bool compose = false}) async =>
    AppReview.openIosReview(appId: appId, compose: compose);

/// Open in AppStore
Future<String> openAppStore({String? fallbackUrl}) =>
    AppReview.openAppStore(fallbackUrl: fallbackUrl);
