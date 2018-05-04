# app_review

Get the Version Name and Version Code on iOS and Android.
![alt text](https://github.com/AppleEducate/app_review)

## Installing

```
get_version:
    git:
      url: git://github.com/AppleEducate/app_review
```
## Import
```
import 'package:app_review/app_review.dart';
```
    
## Example

```
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
