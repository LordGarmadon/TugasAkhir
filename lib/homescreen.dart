// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_field

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nadiku/size.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _timeHMString = "";
  String _timeDateString = "";

  @override
  void initState() {
    _timeHMString = _formatHourMinute(DateTime.now());
    _timeDateString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
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
                      "Azaria",
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
                    "120/60",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
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
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.white)),
                ),
                height: double.infinity,
                width: Sizes.width(context) * .3,
                child: Column(
                  children: [
                    Text(
                      "Nama",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                height: double.infinity,
                width: Sizes.width(context) * .3,
                child: Column(
                  children: [
                    Text(
                      "Systole/Diastole",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                      ],
                    )),
              ),
            ],
          ),
        )
      ],
    );
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
    return DateFormat('EEEE/MM/dd/yy').format(dateTime);
  }
}
