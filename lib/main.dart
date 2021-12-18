import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'device_result.dart';

void main() => runApp(const MyApp());

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
  late Timer bleScan;

 bool isLoading  = true;

  void scanDevices() {
    print("scan started");
    flutterBlue.startScan(timeout: Duration(seconds: 4));
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
        if (r.device.type != BluetoothDeviceType.unknown) {
          scanResult.add(DeviceResult(r.device.name,
              r.advertisementData.localName, r.rssi, r.device.id.toString()));
        }
      }
    });
    print("Scanned device" + scanResult.length.toString());
    for (DeviceResult r in scanResult) {
      print('${r.name} found! rssi: ${r.rssi}');
    }
    flutterBlue.stopScan();
    print("scan stopped");
    // setState(() {
    //   isLoading = true;
    // });
  }

  @override
  void initState() {
    super.initState();
    scanDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE Devices"),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Visibility(
                visible: isLoading,
                child: GestureDetector(
                  onTap: () {
                    print("refresh pressed");
                    scanDevices();
                  },
                  child: const Icon(
                    Icons.refresh,
                    size: 26.0,
                  ),
                ),
              )
          ),
        ],
      ),
      body: scanResult.isEmpty ? const Center(child: CircularProgressIndicator())  : ListView.builder(
          itemCount: scanResult.length,
          itemBuilder: (BuildContext context, int index) {
            final DeviceResult r = scanResult[index];
            return r.createCard();
          }),
    );
  }
}