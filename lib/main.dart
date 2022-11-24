import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'package:network_info_plus/network_info_plus.dart';

String? wifiName = '';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];

  Future<void> setNetwork() async {
    final info = NetworkInfo();
    wifiName = await info.getWifiName();
    print('wifiName $wifiName');
  }

  Future<void> _getScannedResults(BuildContext context) async {
    final results = await WiFiScan.instance.getScannedResults();
    setState(() => accessPoints = results);
    }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Поиск сетей wi-fi'),
        ),
        body: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Text('Текущая сеть: $wifiName'),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Поиск сетей'),
                      onPressed: () async {
                        _getScannedResults(context);
                        setNetwork();
                      }
                    ),

                  ],
                ),
                const Divider(),
                Flexible(
                  child: Center(
                    child: accessPoints.isEmpty
                        ? const Text("Нет результатов поиска")
                        : ListView.builder(
                        itemCount: accessPoints.length,
                        itemBuilder: (context, i) =>
                            _CamerasPointTile(accessPoint: accessPoints[i])),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CamerasPointTile extends StatelessWidget {
  final WiFiAccessPoint accessPoint;

  const _CamerasPointTile({Key? key, required this.accessPoint})
      : super(key: key);

  // отобразить строку: параметр и значение
  Widget _buildInfo(String label, dynamic value) => Container(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey)),
    ),
    child: Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value.toString()))
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    String title = accessPoint.ssid.isNotEmpty ? accessPoint.ssid : "**EMPTY**";
    // title = accessPoint.ssid.contains('IPCAP_', 0) ? 'Это IP-камера:\n' + accessPoint.ssid : accessPoint.ssid;
    final signalIcon = accessPoint.level >= -70
        ? Icons.signal_wifi_4_bar : Icons.signal_wifi_0_bar;
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(signalIcon),
      title: Text(title),
      // subtitle: Text((accessPoint.capabilities.contains('WPA2') ? 'WPA2 ' :(accessPoint.capabilities.contains('WPA-') ? 'WPA ' : 'not WPAx!'))
      //     + ': ' +(accessPoint.capabilities.contains('CCMP') ? 'AES' : '')),
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title.contains('IPCAP_', 0) ? 'Это новая IP-камера:\n' + accessPoint.ssid : accessPoint.ssid),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //  _buildInfo("BSSDI", accessPoint.bssid),
              _buildInfo("уровень сигнала", accessPoint.level>-70 ? 'высокий (рядом)' : 'слабый (далеко)' ),
              SizedBox(height: 16),
              TextButton(
                  style: ButtonStyle(
                    foregroundColor:
                    MaterialStateProperty
                        .all<Color>(
                        Colors
                            .blue),
                  ),
                  onPressed: () {
                    // ConnectToWiFi(accessPoint.ssid);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Подключить камеру к данной сети ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}