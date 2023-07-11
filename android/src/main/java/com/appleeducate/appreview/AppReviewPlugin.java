package com.appleeducate.appreview;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.android.play.core.review.ReviewInfo;
import com.google.android.play.core.review.ReviewManager;
import com.google.android.play.core.review.ReviewManagerFactory;
import com.google.android.play.core.tasks.OnCompleteListener;
import com.google.android.play.core.tasks.Task;

import java.lang.ref.WeakReference;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AppReviewPlugin */
public class AppReviewPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  private static final String CHANNEL_NAME = "app_review";

  private WeakReference<Activity> currentActivity;

  private MethodChannel channel;

  @Nullable
  private ReviewInfo reviewInfo;

  public AppReviewPlugin() {
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    AppReviewPlugin simplePermissionsPlugin = new AppReviewPlugin();
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
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    String method = call.method;
    switch (method) {
      case "isRequestReviewAvailable":
        isRequestReviewAvailable(result);
        break;
      case "requestReview":
        requestReview(result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  private void isRequestReviewAvailable(final Result result) {
    if (currentActivity == null || currentActivity.get() == null) {
      result.error("error", "Android activity not available", null);
      return;
    }
    ReviewManager manager = ReviewManagerFactory.create(currentActivity.get());
    Task<ReviewInfo> request = manager.requestReviewFlow();
    request.addOnCompleteListener(new OnCompleteListener<ReviewInfo>() {
      @Override
      public void onComplete(@NonNull Task<ReviewInfo> task) {
        if (task.isSuccessful()) {
          reviewInfo = task.getResult();
          result.success("1");
        } else {
          result.success("0");
        }
      }
    });
  }

  private void requestReview(final Result result) {
    if (currentActivity == null || currentActivity.get() == null) {
      result.error("error", "Android activity not available", null);
      return;
    }
    if (reviewInfo == null) {
      getReviewInfoAndRequestReview(result);
      return;
    }
    ReviewManager manager = ReviewManagerFactory.create(currentActivity.get());
    Task<Void> task = manager.launchReviewFlow(currentActivity.get(), reviewInfo);
    task.addOnCompleteListener(new OnCompleteListener<Void>() {
      @Override
      public void onComplete(@NonNull Task<Void> task) {
        result.success("Success: " + task.isSuccessful());
      }
    });
  }

  private void getReviewInfoAndRequestReview(final Result result) {
    ReviewManager manager = ReviewManagerFactory.create(currentActivity.get());
    Task<ReviewInfo> request = manager.requestReviewFlow();
    request.addOnCompleteListener(new OnCompleteListener<ReviewInfo>() {
      @Override
      public void onComplete(@NonNull Task<ReviewInfo> task) {
        if (task.isSuccessful()) {
          reviewInfo = task.getResult();
          requestReview(result);
        } else {
          result.error("Requesting review not possible", null, null);
        }
      }
    });
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    currentActivity = new WeakReference<>(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    currentActivity = null;
  }

}
