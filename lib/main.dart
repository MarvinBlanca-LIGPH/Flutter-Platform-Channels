import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static MethodChannel channel = const MethodChannel('battery_level_channel');
  // static MethodChannel sensorChannel = const MethodChannel('sensor_channel');
  static EventChannel tempChannel = const EventChannel('temperature_channel');
  static EventChannel pressureChannel = const EventChannel('pressure_channel');

  String _batteryLevel = '';
  // List<Object?> _sensors = [];

  double _temperature = 0;
  double _pressure = 0;
  late dynamic subscription;

  void _startReading(EventChannel eventChannel) {
    subscription =
        eventChannel.receiveBroadcastStream().listen((dynamic event) {
      setState(() {
        if (eventChannel == tempChannel) {
          _temperature = event;
        } else {
          _pressure = event;
        }
      });
    });
  }

  void _stopReading() {
    setState(() {
      subscription.cancel();
      _pressure = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MaterialButton(
                color: Colors.lightBlueAccent,
                onPressed: _getBatteryLevel,
                child: const Text(
                  'Get Battery Percentage',
                ),
              ),
              Center(
                child: Text(
                  'Battery Level is at: $_batteryLevel',
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                ),
              ),

              // Temperature Sensor
              if (Platform.isAndroid)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(
                      height: 30.0,
                    ),
                    MaterialButton(
                      color: Colors.lightBlueAccent,
                      onPressed: () => _temperature != 0.0
                          ? _stopReading()
                          : _startReading(tempChannel),
                      child: Text(
                        '${_temperature != 0.0 ? 'Stop' : 'Start'} Temperature Monitor',
                      ),
                    ),
                    Center(
                      child: Text(
                        '${_temperature.toInt()}°C',
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.black),
                      ),
                    ),
                  ],
                ),

              const SizedBox(
                height: 20.0,
              ),
              // Pressure Sensor
              MaterialButton(
                color: Colors.lightBlueAccent,
                onPressed: () => _pressure != 0.0
                    ? _stopReading()
                    : _startReading(pressureChannel),
                child: Text(
                  '${_pressure != 0.0 ? 'Stop' : 'Start'} Pressure Monitor ',
                ),
              ),
              Center(
                child: Text(
                  '$_pressure',
                  style: const TextStyle(fontSize: 16.0, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await channel.invokeMethod('getBatteryLevel');
      batteryLevel = '$result% .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  // Future<void> _getSensorList() async {
  //   var sensors;
  //
  //   try {
  //     final List<Object?> result =
  //         await sensorChannel.invokeMethod('sensorMethod');
  //     sensors = result;
  //   } on PlatformException catch (e) {
  //     print(e.message);
  //   }
  //
  //   setState(() {
  //     _sensors = sensors;
  //   });
  // }
}
