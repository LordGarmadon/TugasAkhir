// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nadiku/size.dart';

import 'main.dart';
import 'model/health_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.snapshot});
  final QuerySnapshot? snapshot;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _timeHMString = "";
  String _timeDateString = "";
  QuerySnapshot? onSnapshot;
  @override
  void initState() {
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
              Column(
                children: [
                  Text(
                    "Sistol/Diastol",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Text(
                    widget.snapshot != null
                        ? "${widget.snapshot!.docs.first['systole']}/${widget.snapshot!.docs.first['diastole']}"
                        : "0/0",
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
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
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
        GestureDetector(
          onTap: () {
            /// test add document
            String userId = FirebaseAuth.instance.currentUser!.uid;
            addDocs(userId);
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
                    if (widget.snapshot != null)
                      ...widget.snapshot!.docs.map(
                        (e) => Text(
                          "${e['systole']}/${e['diastole']}",
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
                        if (widget.snapshot != null)
                          ...widget.snapshot!.docs.map(
                            (e) => Text(
                              DateFormat('dd/MM/yy/hh:mm').format(
                                  DateTime.parse(
                                      e['recorded_time'].toDate().toString())),
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

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
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

  Future getDocs() async {
    CollectionReference records =
        FirebaseFirestore.instance.collection('health_nadiku');
    var fetchedRecords = await records.get();
    setState(() {
      onSnapshot = fetchedRecords;
    });
  }

  Future addDocs(String userID) async {
    var detail = HealthDetail(
        userId: userID,
        systole: 160,
        diastole: 50,
        recordedTime: Timestamp.fromDate(DateTime.now()));
    FirebaseFirestore.instance
        .collection('health_nadiku')
        .add(detail.toJson())
        .then((value) => log(value.id));
  }
}
