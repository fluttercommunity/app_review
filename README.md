[![Flutter Community: app_review](https://fluttercommunity.dev/_github/header/app_review)](https://github.com/fluttercommunity/community)

[![Buy Me A Coffee](https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-yellow.svg)](https://www.buymeacoffee.com/rodydavis)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=WSH3GVC49GNNJ)
![github pages](https://github.com/fluttercommunity/app_review/workflows/github%20pages/badge.svg)
[![GitHub stars](https://img.shields.io/github/stars/fluttercommunity/app_review?color=blue)](https://github.com/fluttercommunity/app_review)

# app_review

![alt text](https://github.com/fluttercommunity/app_review/blob/master/screenshots/IMG_0024.PNG)

Online Demo: https://fluttercommunity.github.io/app_review/

## Description
Flutter Plugin for Requesting and Writing Reviews in Google Play and the App Store. Apps have to be published for the app to be found correctly.

## How To Use
It's important to note that the App ID must match the App ID in Google Play and iTunes Connect. This can be changed in the Info.plist on iOS and app/build.gradle on Android. You will use this App ID for other services like Firebase, Admob and publishing the app. 

#### Android
Opens In App Review but only if Play Services are installed on the device and the App is downloaded through the Play Store. Check out the [![official documentation](https://developer.android.com/guide/playcore/in-app-review)].

#### iOS
iOS manages the pop-up requesting review within an app. You can call the code through `AppReview.requestReview` and if the user has "rate in apps" turned on, iOS will send "the request for the review" pop up. This is the required way for requesting reviews after iOS 10.3.

In debug mode it will always display. In apps through TestFlight, the `AppReview.requestReview` does nothing.

``` dart
import 'dart:io';
import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      AppReview.requestReview.then((onValue) {
        print(onValue);
      });
    }
  }
```

## Example

``` dart
import 'package:app_review/app_review.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    AppReview.getAppID.then((onValue) {
      setState(() {
        appID = onValue;
      });
      print("App ID" + appID);
    });
  }

  String appID = "";
  String output = "";

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('App Review'),
        ),
        body: new SingleChildScrollView(
          child: new ListBody(
            children: <Widget>[
              new Container(
                height: 40.0,
              ),
              new ListTile(
                leading: new Icon(Icons.info),
                title: new Text('App ID'),
                subtitle: new Text(appID),
                  onTap: () {
                  AppReview.getAppID.then((onValue) {
                    setState(() {
                      output = onValue;
                    });
                    print(onValue);
                  });
                },
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: new Icon(
                  Icons.shop,
                ),
                title: new Text('View Store Page'),
                onTap: () {
                  AppReview.storeListing.then((onValue) {
                    setState(() {
                      output = onValue;
                    });
                    print(onValue);
                  });
                },
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: new Icon(
                  Icons.star,
                ),
                title: new Text('Request Review'),
                onTap: () {
                  AppReview.requestReview.then((onValue) {
                    setState(() {
                      output = onValue;
                    });
                    print(onValue);
                  });
                },
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                leading: new Icon(
                  Icons.note_add,
                ),
                title: new Text('Write a New Review'),
                onTap: () {
                  AppReview.writeReview.then((onValue) {
                    setState(() {
                      output = onValue;
                    });
                    print(onValue);
                  });
                },
              ),
              new Divider(
                height: 20.0,
              ),
              new ListTile(
                title: new Text(output),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```
