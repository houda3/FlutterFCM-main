import 'dart:convert' as convert;
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:fcm_http/helper.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:fcm_http/fcm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COVID Stats',
      debugShowCheckedModeBanner: false,
      localeResolutionCallback: (
        Locale? locale,
        Iterable<Locale> supportedLocales,
      ) {
        return locale;
      },
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('fr', ''),
        Locale('en', ''),
      ],
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'COVID Stats'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String deviceName = "", deviceVersion = "", identifier = "";

  Future<void> getDeviceDetails() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceName = build.model;
          deviceVersion = build.version.toString();
          identifier = build.androidId; //UUID for Android
        });
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceName = data.name;
          deviceVersion = data.systemVersion;
          identifier = data.identifierForVendor;
        }); //UUID for iOS
      }
    } on PlatformException {
      print('Failed to get platform version');
    }
  }

  Map<String, dynamic> data = Map<String, dynamic>();

  Future<void> _sendData() async {
    showLoader(context);
    var url = Uri.parse(
        'https://corona.lmao.ninja/v2/countries/Morocco?yesterday=false&strict=true&query =');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        this.data = convert.jsonDecode(response.body) as Map<String, dynamic>;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    hideLoader(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FcmManager fcm = FcmManager();
    fcm.initFCM();
    this.initData();
  }

  buildHome() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(18.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.totalcases),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(data['cases'].toString())
                    ],
                  ),
                ),
                elevation: 10,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(18.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Text("Today's cases"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(data['todayCases'].toString())
                    ],
                  ),
                ),
                elevation: 10,
              ),
            )
          ],
        ),
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(18.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Text("Total deaths"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(data['deaths'].toString())
                    ],
                  ),
                ),
                elevation: 10,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(18.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Text("Today's deaths"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(data['todayDeaths'].toString())
                    ],
                  ),
                ),
                elevation: 10,
              ),
            )
          ],
        ),
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(18.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Text("Total recovered"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(data['recovered'].toString())
                    ],
                  ),
                ),
                elevation: 10,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(18.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Text("Today's recovered"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(data['todayRecovered'].toString())
                    ],
                  ),
                ),
                elevation: 10,
              ),
            )
          ],
        ),
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(18.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Text("Total tests"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(data['tests'].toString())
                    ],
                  ),
                ),
                elevation: 10,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.all(18.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Text(
                        "Tests / million",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(data['testsPerOneMillion'].toString())
                    ],
                  ),
                ),
                elevation: 10,
              ),
            )
          ],
        )
      ],
    );
  }

  initData() async {
    var url = Uri.parse(
        'https://corona.lmao.ninja/v2/countries/Morocco?yesterday=false&strict=true&query =');

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        this.data = convert.jsonDecode(response.body) as Map<String, dynamic>;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
            onPressed: () {
              getDeviceDetails();
            },
            child: Text('details device'),
          ),
          deviceVersion.isNotEmpty &&
                  deviceName.isNotEmpty &&
                  identifier.isNotEmpty
              ? Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text('Nom Device:-' + deviceName),
                    SizedBox(
                      height: 30,
                    ),
                    Text('Version de device:-' + deviceVersion),
                    SizedBox(
                      height: 30,
                    ),
                    Text('Identifier de device:-' + identifier),
                  ],
                )
              : Container(),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendData,
        tooltip: 'refresh',
        child: const Icon(Icons.refresh),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
