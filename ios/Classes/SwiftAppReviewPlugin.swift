import Flutter
import UIKit
import StoreKit

public class SwiftAppReviewPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "app_review", binaryMessenger: registrar.messenger())
    let instance = SwiftAppReviewPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    var appID = "com.apple.appstore" //Your App ID on App Store
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
        appID = bundleIdentifier
    }

    switch (call.method) {
        case "requestReview":
          //App Store Review
          if #available(iOS 10.3, *) {
              SKStoreReviewController.requestReview() // Requesting alert view for getting rating from the user.
            result("Later than iOS 10.3 the App will Request the App Review, Users can turn this off in settings for all apps, Apple will manage when to request the review from the user. In Debug it will always show. Requesting review for: " + appID)
          } else {
            // Fallback on earlier versions
            result("Prior to iOS 10.3 App Review from App is not available. You should go to Store Page of App: " + appID + ". If the app is not published the app will not be found.")
          }
        case "isRequestReviewAvailable":
          if #available(iOS 10.3, *) {
            result("1")
          } else {
            result("0")
          }
        default:
          result(FlutterMethodNotImplemented)
    }
  }

}
