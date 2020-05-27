package com.appleeducate.appreview;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AppReviewPlugin */
public class AppReviewPlugin implements FlutterPlugin, MethodCallHandler {
  private static final String CHANNEL_NAME = "app_review";

  /** Plugin registration. */
  private Registrar registrar;

  private Result result;
  String appPackageName = "";

  private MethodChannel channel;

  public AppReviewPlugin() {
  }

  private AppReviewPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    AppReviewPlugin simplePermissionsPlugin = new AppReviewPlugin(registrar);
    simplePermissionsPlugin.setupChannel(registrar.messenger());
    //    registrar.addRequestPermissionsResultListener(simplePermissionsPlugin);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    setupChannel(binding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    teardownChannel();
  }

  private void setupChannel(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, CHANNEL_NAME);
    channel.setMethodCallHandler(this);
  }

  private void teardownChannel() {
    channel.setMethodCallHandler(null);
    channel = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    String method = call.method;
    switch (method) {
        // case "getAppID":
        //   result.success("" + BuildConfig.APPLICATION_ID);
        //   break;
      default:
        result.notImplemented();
        break;
    }
  }

  // private void openListing(String appID) {
  //     Activity activity = registrar.activity();
  //     try {
  //         activity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + appID)));
  //     } catch (android.content.ActivityNotFoundException anfe) {
  //         activity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=" + appID)));
  //     }
  // }

}
