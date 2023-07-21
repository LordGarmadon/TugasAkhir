// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nadiku/dialog_box/custom_dialog_box.dart';
import 'package:nadiku/main.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final etNama = TextEditingController();
  final etEmail = TextEditingController();
  final etPassword = TextEditingController();
  final etRePassword = TextEditingController();
  bool isVerified = true;
  @override
  void dispose() {
    etNama.dispose();
    etEmail.dispose();
    etPassword.dispose();
    etRePassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color.fromRGBO(82, 223, 254, 100),
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
      children: const [
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
        TextField(
          controller: etNama,
          decoration: InputDecoration(
            hintText: "Nama",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        Visibility(
          visible: etNama.text.isEmpty && !isVerified,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              "Mohon Isi Nama!",
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
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
        Visibility(
          visible: etEmail.text.isEmpty && !isVerified,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              "Mohon Isi Email!",
              style: TextStyle(color: Colors.amber),
            ),
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
        Visibility(
          visible: etPassword.text.isEmpty && !isVerified,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              "Mohon Isi Password!",
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: etRePassword,
          decoration: InputDecoration(
            hintText: "Ketik ulang Password",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.password_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
          obscureText: true,
        ),
        Visibility(
          visible: etRePassword.text.isEmpty && !isVerified,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              "Mohon Ketik Ulang Password!",
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () async {
            var status = await dataVerification();
            if (status != VerificationStatus.granted) {
              setState(() {
                isVerified = false;
              });
              showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                        title: getVerifStatusTitle(status),
                        description: getVerifStatusDescription(status),
                      ));
            } else {
              setState(() {
                isVerified = true;
              });
              register(context);
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Color.fromRGBO(237, 121, 71, 1),
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            "Daftarkan",
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }

  String getVerifStatusTitle(VerificationStatus status) {
    if (status == VerificationStatus.emptyPassword) {
      return "Cek Password";
    } else if (status == VerificationStatus.namaOrEmail) {
      return "Cek Email atau Nama";
    } else if (status == VerificationStatus.unmatchingPassword) {
      return "Ketik Ulang Password Salah";
    }
    return "Granted";
  }

  String getVerifStatusDescription(VerificationStatus status) {
    if (status == VerificationStatus.emptyPassword) {
      return "Mohon untuk memastikan bahwa password atau ketik ulang password tidak kosong";
    } else if (status == VerificationStatus.namaOrEmail) {
      return "Mohon untuk memastikan bahwa nama atau email tidak kosong";
    } else if (status == VerificationStatus.unmatchingPassword) {
      return "Mohon untuk memastikan bahwa ketik ulang password sama dengan password anda";
    }
    return "Granted";
  }

  Future<VerificationStatus> dataVerification() async {
    if (etNama.text.isEmpty || etEmail.text.isEmpty) {
      return VerificationStatus.namaOrEmail;
    } else if (etPassword.text.isEmpty || etRePassword.text.isEmpty) {
      return VerificationStatus.emptyPassword;
    } else if (etPassword.text != etRePassword.text) {
      return VerificationStatus.unmatchingPassword;
    }
    return VerificationStatus.granted;
  }

  Future register(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: etEmail.text.trim(),
        password: etPassword.text.trim(),
      )
          .then((value) {
        return value.user!.updateProfile(displayName: etNama.text);
      });
    } on FirebaseAuthException catch (e) {
      log(e.toString());
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
            style: TextButton.styleFrom(primary: Color.fromRGBO(237, 121, 71, 1)),
            child: Text("Login"))
      ],
    );
  }
}

enum VerificationStatus {
  granted,
  namaOrEmail,
  emptyPassword,
  unmatchingPassword,
}
