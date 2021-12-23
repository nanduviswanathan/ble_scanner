import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'device_result.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'firebase_options.dart';

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

// void main() => runApp(const MyApp());
Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(const MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  static List<DeviceResult> scanResult = [];
  List<DeviceResult> _searchResult = [];
  late Timer bleScan;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late Future<void> _initializeFlutterFireFuture;

  bool isLoading = true;
  bool search = false;

  TextEditingController searchController = TextEditingController();

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  void scanDevices() {
    print("scan started");
    setState(() {
      isLoading = false;
    });

    flutterBlue.startScan(timeout: const Duration(minutes: 4));
    flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResult = [];
      });
      for (ScanResult r in results) {
        print(
            '${r.device.name} found! rssi: ${r.rssi} ${r.advertisementData.serviceUuids}');
        r.advertisementData.serviceUuids.forEach((uuid) => print(uuid));
        print('${r.advertisementData.serviceData}');
        print('${r.device.id}');
        if (r.device.type != BluetoothDeviceType.unknown) {}
        scanResult.add(DeviceResult(r.device.name,
            r.advertisementData.localName, r.rssi, r.device.id.toString()));
      }
    });
    print("Scanned device" + scanResult.length.toString());
    for (DeviceResult r in scanResult) {
      print('${r.name} found! rssi: ${r.rssi}');
    }
  }

  void hideRefreshBtn() async {
    Future.delayed(const Duration(seconds: 4), () {
      //asynchronous delay
      //checks if widget is still active and not disposed
      setState(() {
        //tells the widget builder to rebuild again because ui has updated
        isLoading =
            true; //update the variable declare this under your class so its accessible for both your widget build and initState which is located under widget build{}
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // scanDevices();
    hideRefreshBtn();
    flutterBlue.isScanning.listen((event) {
      print("scannign status" + event.toString());
      if (!event) {
        print("Scanning stopped ");
        scanDevices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom==0.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE Devices"),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Visibility(
                visible: isLoading,
                child: GestureDetector(
                  onTap: () async {
                    print("refresh pressed");
                    hideRefreshBtn();
                    flutterBlue.stopScan();
                    await FirebaseAnalytics.instance
                        .logEvent(name: 'view_product', parameters: {
                      'product_id': 1234,
                    });
                  },
                  child: const Icon(
                    Icons.refresh,
                    size: 26.0,
                  ),
                ),
              )),
          IconButton(
              onPressed: () {
                print("Search pressed");
                setState(() {
                  search = true;
                });
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: Column(
        children: <Widget>[
          Visibility(
            visible: search,
            child: TextField(
              keyboardType: TextInputType.text,
              controller: searchController,
              onChanged: onSearchTextChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search...',
                contentPadding:
                    const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      search = false;
                      _searchResult.clear();
                      searchController.text = '';
                    });
                  },
                ),
                focusColor: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _searchResult.isNotEmpty || searchController.text.isNotEmpty
                ? RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 20.0),
                      text: "Showing ",
                      children: <TextSpan>[
                        TextSpan(
                            text: '${_searchResult.length} ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text: 'of ',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                        TextSpan(
                            text: '${scanResult.length}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          fontSize: 20.0),
                      text: "Showing ",
                      children: <TextSpan>[
                        TextSpan(
                            text: '${scanResult.length} ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text: 'Devices',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
          ),
          _searchResult.isNotEmpty || searchController.text.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                      itemCount: _searchResult.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DeviceResult r = _searchResult[index];
                        return r.createCard();
                      }),
                )
              : Expanded(
                  child: ListView.builder(
                      itemCount: scanResult.length,
                      itemBuilder: (BuildContext context, int index) {
                        final DeviceResult r = scanResult[index];
                        return r.createCard();
                      }),
                )
        ],
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: showFab? FloatingActionButton.extended(
        onPressed: () async {
          // Add your onPressed code here!
          // try {
          //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          //     content: Text('Recorded Error  \n'
          //         'Please crash and reopen to send data to Crashlytics'),
          //     duration: Duration(seconds: 5),
          //   ));
          //   throw Error();
          // } catch (e, s) {
          //   // "reason" will append the word "thrown" in the
          //   // Crashlytics console.
          //   await FirebaseCrashlytics.instance.recordError(e, s,
          //       reason: 'as an example of non-fatal error from flutter');
          // }
          FirebaseCrashlytics.instance.crash();
        },
        label: const Text('Force Crash'),
        icon: const Icon(Icons.power_settings_new_outlined),
        backgroundColor: Colors.red,
      ) : null
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    print(
        "text is- ${searchController.text} && ${searchController.text.isEmpty}");
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    scanResult.forEach((r) {
      if (r.name.toLowerCase().startsWith(text.toLowerCase())) {
        _searchResult.add(r);
      }
    });

    setState(() {});
  }
}
