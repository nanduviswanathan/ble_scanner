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
  List<DeviceResult> _searchResult = [];
  late Timer bleScan;

  bool isLoading = true;
  bool search = false;

  TextEditingController searchController = TextEditingController();

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
    print("scan stopped");
    setState(() {
      isLoading = true;
    });
  }

  void hideRefreshBtn() async {
    Future.delayed(const Duration(seconds: 2), () {
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
                    // scanDevices();
                    flutterBlue.stopScan();
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
      body:
          // !isLoading
          //     ? const Center(child: CircularProgressIndicator())
          //     : isLoading && scanResult.isEmpty
          //         ? const Center(
          //             child: Text("No BLE Devices found. Scan Again!!"),
          //           )
          //         :
          Column(
        children: <Widget>[
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
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text: 'of ',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                         TextSpan(
                            text: '${scanResult.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
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
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text: 'Devices',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
          ),
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
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    print("text is- ${searchController.text} && ${searchController.text.isEmpty}");
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
