import '../app_review.dart';

/// Get app bundle name
Future<String?> getAppId() => AppReview.getBundleName();

/// Require app review for Android
Future<String?> openAndroidReview() => AppReview.openAndroidReview();

/// Open in GooglePlay
Future<String> openGooglePlay({String? fallbackUrl}) =>
    AppReview.openGooglePlay(fallbackUrl: fallbackUrl);
