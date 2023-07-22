// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:external_path/external_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:intl/intl.dart';
import 'package:nadiku/custom/dotted_border.dart';
import 'package:nadiku/dialog_box/custom_dialog_box.dart';
import 'package:nadiku/size.dart';
import 'package:permission_handler/permission_handler.dart';

import 'lifecycle/custom_lifecycle.dart';
import 'main.dart';
import 'model/health_detail.dart';
import 'model/readable_detail.dart';

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
  CustomWidgetBindingObserver? _widgetBindingObserver;
  bool triggerCheckBluetooth = false;

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

  Timer _startTimer() {
    return Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  @override
  void initState() {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIsBluetoothAvailable();
      getPermission();
      getDocs(userId);
    });
    _timeHMString = _formatHourMinute(DateTime.now());
    _timeDateString = _formatDateTime(DateTime.now());
    _startTimer();
    _widgetBindingObserver = CustomWidgetBindingObserver(onPaused: () {
      if (FirebaseAuth.instance.currentUser!.email != null && FirebaseAuth.instance.currentUser!.email!.isNotEmpty) {
        setState(() {
          triggerCheckBluetooth = true;
        });
      }
    }, onResume: () async {
      await getIsBluetoothAvailable();
      await getPermission();
      await getDocs(userId);
      setState(() {
        triggerCheckBluetooth = false;
      });
    });
    WidgetsBinding.instance.addObserver(_widgetBindingObserver!);
    super.initState();
  }

  @override
  void dispose() {
    _startTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.all(15),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
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
                      FirebaseAuth.instance.currentUser!.displayName != null && FirebaseAuth.instance.currentUser!.displayName!.isNotEmpty ? FirebaseAuth.instance.currentUser!.displayName! : FirebaseAuth.instance.currentUser!.email!,
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      _timeHMString,
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
              if (isLoading) CircularProgressIndicator(),
              if (isBluetoothAvailable != null && !isBluetoothAvailable! && !isLoading)
                Center(
                  child: Text(
                    "Perangkat belum dikenali\nsilahkan menghubungkan bluetooth nadiku disetting",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              if ((isBluetoothAvailable != null && isBluetoothAvailable!) && (connection == null || !connection!.isConnected) && !isLoading)
                DottedBorder(
                  color: Colors.black,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Icon(
                          Icons.bluetooth,
                          color: Colors.black,
                        ),
                        Text(
                          "Aplikasi ini membutuhkan koneksi\nke perangkat Nadiku",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              if ((isBluetoothAvailable != null && isBluetoothAvailable!) && (connection != null && connection!.isConnected) && onSnapshot == null && !isLoading)
                DottedBorder(
                  color: Colors.black,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                        Text(
                          "Tekan tombol hubungkan\nuntuk memunculkan data\ndari perangkat nadiku",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              if ((isBluetoothAvailable != null && isBluetoothAvailable!) && (connection != null && connection!.isConnected) && onSnapshot != null && !isLoading)
                Column(
                  children: [
                    Text(
                      "Sistol/Diastol",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    Text(
                      isConnected ? "$systole/$diastole" : "0/0",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      _timeDateString,
                      style: TextStyle(fontSize: 12, color: Colors.black),
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
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              margin: EdgeInsets.only(left: 15),
              decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(15)),
              child: Text(
                "Hubungkan",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ),
          ),
        SizedBox(
          height: 15,
        ),
        Container(
          margin: EdgeInsets.only(
            right: 15,
            left: 15,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          height: Sizes.height(context) * .4,
          width: double.infinity,
          child: onSnapshot != null
              ? Column(
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15))),
                            width: Sizes.width(context) * .1,
                            child: Column(
                              children: [
                                Text(
                                  'No.',
                                  style: TextStyle(color: Colors.black),
                                ),
                                if (onSnapshot != null)
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: onSnapshot!.docs.length > 5 ? 5 : onSnapshot!.docs.length,
                                      itemBuilder: (context, i) => Column(
                                            children: [
                                              Text(
                                                "${i + 1}",
                                                style: TextStyle(color: Colors.black, fontSize: 16),
                                              ),
                                              Text(
                                                "",
                                                style: TextStyle(color: Colors.black, fontSize: 16),
                                              ),
                                            ],
                                          ))
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              height: double.infinity,
                              width: Sizes.width(context) * .3,
                              child: Column(
                                children: [
                                  Text(
                                    "Systole/Diastole",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  if (onSnapshot != null)
                                    ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: onSnapshot!.docs.length > 5 ? 5 : onSnapshot!.docs.length,
                                        itemBuilder: (context, i) {
                                          var e = onSnapshot!.docs[i];
                                          return Column(
                                            children: [
                                              Text(
                                                "${e['sistol']}/${e['diastol']}",
                                                style: TextStyle(color: Colors.black, fontSize: 16),
                                              ),
                                              Text(
                                                "",
                                                style: TextStyle(color: Colors.black, fontSize: 16),
                                              )
                                            ],
                                          );
                                        })
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
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
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      if (onSnapshot != null)
                                        ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: onSnapshot!.docs.length > 5 ? 5 : onSnapshot!.docs.length,
                                            itemBuilder: (context, i) {
                                              var e = onSnapshot!.docs[i];
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    DateFormat('EEEE/dd/MM/yy').format(DateTime.parse(e['recorded_time'].toDate().toString())),
                                                    style: TextStyle(color: Colors.black, fontSize: 16),
                                                  ),
                                                  Text(
                                                    DateFormat('hh:mm').format(DateTime.parse(e['recorded_time'].toDate().toString())),
                                                    style: TextStyle(color: Colors.black, fontSize: 16),
                                                  )
                                                ],
                                              );
                                            })
                                    ],
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      height: Sizes.height(context) * .075,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              var status = await Permission.storage.request();
                              if (!status.isGranted) {
                                await Permission.storage.request();
                              } else {
                                // download csv function
                                var data = onSnapshot!.docs.map((e) => ReadableDetail(
                                        name: FirebaseAuth.instance.currentUser!.displayName != null && FirebaseAuth.instance.currentUser!.displayName!.isNotEmpty
                                            ? FirebaseAuth.instance.currentUser!.displayName!
                                            : FirebaseAuth.instance.currentUser!.email!,
                                        diastole: e['diastol'],
                                        systole: e['sistol'],
                                        recordedTime: DateFormat('EEEE/dd/MM/yy hh:mm').format(DateTime.parse(e['recorded_time'].toDate().toString())))
                                    .toJson());
                                var associatedList = data.toList();
                                // log(associatedList.toString());
                                List<List<dynamic>> rows = [];

                                List<dynamic> row = [];
                                row.add("nama");
                                row.add("sistol");
                                row.add("diastol");
                                row.add("recorded_time");
                                rows.add(row);
                                for (int i = 0; i < associatedList.length; i++) {
                                  List<dynamic> row = [];
                                  row.add(associatedList[i]["nama"]);
                                  row.add(associatedList[i]["sistol"]);
                                  row.add(associatedList[i]["diastol"]);
                                  row.add(associatedList[i]["recorded_time"]);
                                  rows.add(row);
                                }
                                String csv = const ListToCsvConverter().convert(rows);
                                String dir = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOCUMENTS);

                                String file = "$dir";
                                String fileName = "nadiku_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour.toString()}${DateTime.now().second}";
                                File f = File(file + "/$fileName.csv");

                                f.writeAsString(csv);
                                showDialog(context: context, builder: (_) => CustomDialog(title: "Successfully Download Data", description: "Data has been downloaded under file name $fileName"));
                              }
                            },
                            child: Container(
                              width: Sizes.width(context) * .1,
                              height: Sizes.width(context) * .1,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: Colors.deepOrangeAccent,
                              ),
                              child: RotatedBox(
                                  quarterTurns: 2,
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  )),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(
                  color: Colors.deepOrangeAccent,
                )),
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

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedHourMinute = _formatHourMinute(now);
    final String formattedDate = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _timeHMString = formattedHourMinute;
        _timeDateString = formattedDate;
      });
    }
  }

  String _formatHourMinute(DateTime dateTime) {
    return DateFormat('hh:mm').format(dateTime);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE/dd/MM/yy').format(dateTime);
  }

  Future getDocs(String userID) async {
    CollectionReference records = FirebaseFirestore.instance.collection('health_nadiku');
    var fetchedRecords = await records.where("user_id", isEqualTo: userID).orderBy("recorded_time", descending: true).get();
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
