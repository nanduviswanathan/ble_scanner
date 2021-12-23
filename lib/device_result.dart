import 'package:flutter/material.dart';

class DeviceResult {
  final String name;
  final String localeName;
  final int rssi;
  final String macAddress;
  const DeviceResult(this.name, this.localeName, this.rssi, this.macAddress);

  Widget createCard() {
    return Card(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Text(rssi.toString()),
              title: Text( name == '' ? 'Unknown' : '$name ($localeName)'),
              subtitle: Text(macAddress),
            ),
          ],
        ));
  }
}