// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field

import 'dart:async';
import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'package:nadiku/size.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';
import 'model/health_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _timeHMString = "";
  String _timeDateString = "";
  QuerySnapshot? onSnapshot;
  BluetoothConnection? connection;
  bool? isBluetoothAvailable;
  String dataFromBluetooth = "";
  int systole = 0, diastole = 0;
  bool isConnected = false;

  Future<bool> initBluetoothConnection() async {
    // Get the list of paired devices
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    BluetoothDevice? bdev;
    for (BluetoothDevice device in devices) {
      if (device.name == "nadiku") {
        bdev = device;
        break;
      }
    }

    if (bdev != null) {
      // Establish a Bluetooth connection
      BluetoothConnection newConnection = await BluetoothConnection.toAddress(bdev.address);
      log(newConnection.toString());
      setState(() {
        connection = newConnection;
      });
      return true;
      // Start listening for incoming data
    }
    return false;
  }

  void getData() {
    connection!.input!.listen(
      (Uint8List data) {
        // setState(() {
        //   isLoading = true;
        // });
        // Handle the received data
        String message = String.fromCharCodes(data).trim();
        log("Received: $message");
        if (message.isNotEmpty) {
          var userID = FirebaseAuth.instance.currentUser!.uid;
          var sysdia = _convertStringToInt(message);
          // add data to firestore
          log(sysdia.toString());
          setState(() {
            systole = sysdia[0];
            diastole = sysdia[1];
            isConnected = true;
          });
          addDocs(
            HealthDetail(
              userId: userID,
              systole: sysdia[0],
              diastole: sysdia[1],
              recordedTime: Timestamp.fromDate(
                DateTime.now(),
              ),
            ),
          );
          processData(message);
          // connection!.close();
        }
        // Process the received data as needed
      },
    );
  }

  void processData(String data) {
    // Handle the received data here
    // You can perform any required parsing or further processing
    setState(() {
      dataFromBluetooth = data;
    });
    log("Processed Data: $data");
  }

  Future<void> getIsBluetoothAvailable() async {
    var getBluetoothInfo = await FlutterBluetoothSerial.instance.isEnabled;
    setState(() {
      isBluetoothAvailable = getBluetoothInfo;
    });
  }

  bool isPermissionGranted = false;
  bool isLoading = false;
  Future<void> getPermission() async {
    var bluetoothConnectPerm = await Permission.bluetoothConnect.request();
    var bluetoothScanPerm = await Permission.bluetoothScan.request();
    var bluetoothPerm = await Permission.bluetooth.request();
    if (bluetoothConnectPerm == PermissionStatus.granted && bluetoothScanPerm == PermissionStatus.granted && bluetoothPerm == PermissionStatus.granted) {
      initBluetoothConnection();
      setState(() {
        isPermissionGranted = true;
      });
    } else {
      setState(() {
        isPermissionGranted = false;
      });
    }
  }

  @override
  void initState() {
    var user_id = FirebaseAuth.instance.currentUser!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIsBluetoothAvailable();
      getPermission();
      getDocs(user_id);
    });
    _timeHMString = _formatHourMinute(DateTime.now());
    _timeDateString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  @override
  void dispose() {
    _getTime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(15),
          ),
          height: Sizes.height(context) * .275,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      FirebaseAuth.instance.currentUser!.email!,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      _timeHMString,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              if (isLoading) CircularProgressIndicator(),
              if (isBluetoothAvailable != null && !isBluetoothAvailable! && !isLoading)
                Center(
                  child: Text("Bluetooth Not Available"),
                ),
              if ((isBluetoothAvailable != null && isBluetoothAvailable!) && (connection == null || !connection!.isConnected) && !isLoading)
                Center(
                  child: Text("Connect To Nadiku First"),
                ),
              if ((isBluetoothAvailable != null && isBluetoothAvailable!) && (connection != null && connection!.isConnected) && onSnapshot == null && !isLoading)
                Center(
                  child: Text("Press Test Button Then Press Button On The Nadiku"),
                ),
              if ((isBluetoothAvailable != null && isBluetoothAvailable!) && (connection != null && connection!.isConnected) && onSnapshot != null && !isLoading)
                Column(
                  children: [
                    Text(
                      "Sistol/Diastol",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Text(
                      isConnected ? "$systole/$diastole" : "0/0",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      logout(context);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    child: Text(
                      "Disconnect",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      _timeDateString,
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        // Hapus nanti
        if (isBluetoothAvailable != null && isBluetoothAvailable!)
          GestureDetector(
            onTap: () async {
              if (isBluetoothAvailable != null && !isBluetoothAvailable!) {
                // do nothing
              } else if ((isBluetoothAvailable != null && isBluetoothAvailable!) && (connection == null || !connection!.isConnected)) {
                // press to connect
                var conn = await initBluetoothConnection();
                if (!conn) {
                  _jumpToSetting();
                }
              } else if ((isBluetoothAvailable != null && isBluetoothAvailable!) && (connection != null && connection!.isConnected) && onSnapshot == null) {
                getData();
              } else if ((isBluetoothAvailable != null && isBluetoothAvailable!) && (connection != null && connection!.isConnected) && onSnapshot != null) {
                getData();
              }
            },
            child: Container(
              height: 50,
              width: 150,
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                "Test",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.only(
            right: 15,
            left: 15,
          ),
          // padding: EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(15),
          ),
          height: Sizes.height(context) * .56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                height: double.infinity,
                width: Sizes.width(context) * .3,
                child: Column(
                  children: [
                    Text(
                      "Systole/Diastole",
                      style: TextStyle(color: Colors.white),
                    ),
                    if (onSnapshot != null)
                      ...onSnapshot!.docs.map(
                        (e) => Text(
                          "${e['sistol']}/${e['diastol']}",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                ),
                height: double.infinity,
                width: Sizes.width(context) * .3,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    height: Sizes.height(context) * .1,
                    width: Sizes.width(context) * .3,
                    child: Column(
                      children: [
                        Text(
                          "Waktu",
                          style: TextStyle(color: Colors.white),
                        ),
                        if (onSnapshot != null)
                          ...onSnapshot!.docs.map(
                            (e) => Text(
                              DateFormat('dd/MM/yy/hh:mm').format(DateTime.parse(e['recorded_time'].toDate().toString())),
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                      ],
                    )),
              ),
            ],
          ),
        )
      ],
    );
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = "${diff.inDays.toString()}DAY AGO";
      } else {
        time = "${diff.inDays.toString()}DAYS AGO";
      }
    }

    return time;
  }

  Future logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      log(e.toString());
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedHourMinute = _formatHourMinute(now);
    final String formattedDate = _formatDateTime(now);
    setState(() {
      _timeHMString = formattedHourMinute;
      _timeDateString = formattedDate;
    });
  }

  String _formatHourMinute(DateTime dateTime) {
    return DateFormat('hh:mm').format(dateTime);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE/dd/MM/yy').format(dateTime);
  }

  Future getDocs(String userID) async {
    CollectionReference records = FirebaseFirestore.instance.collection('health_nadiku');
    var fetchedRecords = await records.get();
    log("isi database" + fetchedRecords.docs.length.toString());
    setState(() {
      onSnapshot = fetchedRecords;
    });
  }

  Future addDocs(HealthDetail detail) async {
    FirebaseFirestore.instance.collection('health_nadiku').add(detail.toJson()).then((value) => getDocs(detail.userId));
  }

  _jumpToSetting() {
    AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  }

  List<int> _convertStringToInt(String data) {
    log("sini bro" + data);
    final splitted = data.split('/');
    List<int> intlist = [];
    for (var i = 0; i < splitted.length; i++) {
      double result = getDoubleData(splitted[i]);

      intlist.add(result.toInt());
    }
    log(intlist.toString());
    return intlist;
  }

  double getDoubleData(String str) {
    if (str.contains(",")) {
      return double.parse(str.substring(0, str.indexOf(',')));
    } else {
      return double.parse(str);
    }
  }
}
