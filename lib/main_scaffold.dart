import 'package:flutter/material.dart';
import 'package:nadiku/homescreen.dart';
import 'package:nadiku/main_appbar.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int index = 0;
  // unused for now
  // List<Widget> widgets = [
  //   HomeScreen(),
  //   DaftarKoneksi(),
  //   HowToUse(),
  // ];
  @override
  Widget build(BuildContext context) {
    return MainAppBar(
      body: ListView(
        children: [HomeScreen()],
      ),
      onSelectIndex: (i) {
        setState(() {
          index = i;
        });
      },
      index: index,
    );
  }
}
