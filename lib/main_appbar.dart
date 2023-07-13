// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nadiku/model/health_detail.dart';

class MainAppBar extends StatefulWidget {
  const MainAppBar({super.key, required this.body, required this.onSelectIndex, this.index = 0});
  final Widget Function(QuerySnapshot? records) body;
  final void Function(int) onSelectIndex;
  final int index;
  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  QuerySnapshot? onRecords;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // GestureDetector(
            //   onTap: () => widget.onSelectIndex(0),
            //   child: Container(
            //     dec  oration: BoxDecoration(
            //       color: widget.index == 0 ? Colors.green : Colors.deepOrange,
            //       borderRadius: BorderRadius.circular(5),
            //     ),
            //     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            //     child: Text(
            //       "Halaman\nUtama",
            //       textAlign: TextAlign.center,
            //       style: TextStyle(fontSize: 12),
            //     ),
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () => widget.onSelectIndex(1),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: widget.index == 1 ? Colors.green : Colors.deepOrange,
            //       borderRadius: BorderRadius.circular(5),
            //     ),
            //     padding: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
            //     child: Text(
            //       "Daftar\nKoneksi",
            //       textAlign: TextAlign.center,
            //       style: TextStyle(fontSize: 12),
            //     ),
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () => widget.onSelectIndex(2),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       color: widget.index == 2 ? Colors.green : Colors.deepOrange,
            //       borderRadius: BorderRadius.circular(5),
            //     ),
            //     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            //     child: Text(
            //       "How to Use",
            //       textAlign: TextAlign.center,
            //       style: TextStyle(fontSize: 12),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      body: widget.body(onRecords),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          getDocs();
        },
      ),
    );
  }

  Future getDocs() async {
    CollectionReference records = FirebaseFirestore.instance.collection('record');
    var fetched_records = await records.get();
    setState(() {
      onRecords = fetched_records;
    });
  }

  Future addDocs() async {
    FirebaseFirestore.instance.collection('record').withConverter<HealthDetail>(
          fromFirestore: (snapshot, _) => HealthDetail.fromJson(snapshot.data()!),
          toFirestore: (movie, _) => movie.toJson(),
        );
  }
}
