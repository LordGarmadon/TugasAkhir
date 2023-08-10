import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nadiku/main.dart';

class SplashscreenU extends StatefulWidget {
  const SplashscreenU({super.key});

  @override
  State<SplashscreenU> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<SplashscreenU> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(82, 223, 254, 100),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/telu.png',
              height: 250,
              width: 250,
            ),
            Text(
              "Telkom University",
              style: TextStyle(fontStyle: FontStyle.normal, color: Colors.black, fontSize: 32),
            )
          ],
        ),
      ),
    );
  }
}
