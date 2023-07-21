// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:nadiku/dialog_box/custom_dialog_box.dart';
import 'package:nadiku/homescreen.dart';
import 'package:nadiku/size.dart';

class MainAppBar extends StatefulWidget {
  const MainAppBar({super.key, required this.body, required this.onSelectIndex, this.index = 0});
  final Widget body;
  final void Function(int) onSelectIndex;
  final int index;
  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.tealAccent,
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => DoubleButtonDialog(
                          title: "Logout",
                          description: "Are you sure you want to log out from current user?",
                          firstButton: "Yes",
                          secondButton: "No",
                          onFirstButtonTap: () {
                            logout(context);
                          },
                        ));
              },
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                width: Sizes.width(context) * .1,
                height: Sizes.width(context) * .1,
                child: Icon(
                  Icons.logout,
                  color: Colors.black,
                ),
              ),
            )
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
      body: widget.body,
    );
  }
}
