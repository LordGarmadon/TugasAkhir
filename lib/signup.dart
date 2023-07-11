import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nadiku/main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final etEmail = TextEditingController();
  final etPassword = TextEditingController();
  @override
  void dispose() {
    etEmail.dispose();
    etPassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          physics: MediaQuery.of(context).viewInsets.bottom == 0 ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * .1,
            ),
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _header(context),
              _inputFields(context),
              _loginInfo(context),
            ]),
          ],
        ),
      ),
    ));
  }

  _header(context) {
    return Column(
      children: [
        Text(
          "Buat Akun Baru",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Masukan detail untuk memulai"),
      ],
    );
  }

  _inputFields(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TextField(
        //   controller: etNama,
        //   decoration: InputDecoration(
        //     hintText: "Nama",
        //     fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
        //     filled: true,
        //     prefixIcon: Icon(Icons.person),
        //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        //   ),
        // ),
        // SizedBox(
        //   height: 10,
        // ),
        TextField(
          controller: etEmail,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: "Email",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: etPassword,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: "Password",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.password_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
          obscureText: true,
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          decoration: InputDecoration(
            hintText: "Ketik ulang Password",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.password_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
          obscureText: true,
        ),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () {
            log(etEmail.text);
            log(etPassword.text);
            register(context);
          },
          child: Text(
            "Daftarkan",
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            primary: Color.fromRGBO(238, 138, 96, 1),
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        )
      ],
    );
  }

  Future register(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: etEmail.text.trim(),
        password: etPassword.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      print(e);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  _loginInfo(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Sudah punya akun?"),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(primary: Color.fromRGBO(238, 138, 96, 1)),
            child: Text("Login"))
      ],
    );
  }
}
