import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nadiku/main_scaffold.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});
  @override
  State<VerifyEmail> createState() => _VerifyEmail();
}

class _VerifyEmail extends State<VerifyEmail> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    //user needs to be created first!
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async {
    //call after email verification
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: const Text("Verifikasi email terkirim"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? MainScaffold()
      : Scaffold(
          backgroundColor: Color.fromRGBO(82, 223, 254, 100),
          appBar: AppBar(
            title: Text("Verify Email"),
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Link verifikasi email telah terkirim, silahkan cek inbox email anda",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50), backgroundColor: Colors.greenAccent),
                  icon: Icon(Icons.email, size: 32),
                  label: Text(
                    "Kirim Ulang Email",
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                ),
                SizedBox(height: 24),
                TextButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50),
                  ),
                  child: Text(
                    "Batalkan",
                    style: TextStyle(fontSize: 24, color: Color.fromRGBO(237, 121, 71, 1)),
                  ),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
          ),
        );
}
