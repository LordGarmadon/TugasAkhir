// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nadiku/dialog_box/custom_dialog_box.dart';
import 'package:nadiku/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final etEmail = TextEditingController();
  final etPassword = TextEditingController();
  bool isVerified = true;
  bool isLoading = false;
  bool isError = false;
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
        backgroundColor: Color.fromRGBO(82, 223, 254, 100),
        body: Container(
          margin: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(context),
              _inputField(context),
              _forgotPassword(context),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return Column(
      children: const [
        Text(
          "Selamat datang",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Masukan informasi Login anda"),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: etEmail,
          decoration: InputDecoration(
              hintText: "Email", border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), fillColor: Theme.of(context).primaryColor.withOpacity(0.1), filled: true, prefixIcon: Icon(Icons.person)),
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
        SizedBox(height: 10),
        TextField(
          controller: etPassword,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.person),
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
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: loginP,
          style: ElevatedButton.styleFrom(
            primary: Color.fromRGBO(237, 121, 71, 1),
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: isLoading
              ? CircularProgressIndicator()
              : Text(
                  "Login",
                  style: TextStyle(fontSize: 20),
                ),
        )
      ],
    );
  }

  Future loginP() async {
    setState(() {
      isLoading = true;
    });
    if (etEmail.text.isEmpty || etPassword.text.isEmpty) {
      setState(() {
        isVerified = false;
        isError = true;
      });
      showDialog(context: context, builder: (context) => CustomDialog(title: "Login Failed", description: "Please fill both email and password"));
    } else {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: etEmail.text.trim(),
          password: etPassword.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        showDialog(context: context, builder: (context) => CustomDialog(title: "Login Failed", description: e.message!));
        log(e.toString());
        setState(() {
          isError = true;
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}

_forgotPassword(context) {
  return TextButton(
    onPressed: () {},
    style: TextButton.styleFrom(primary: Color.fromRGBO(237, 121, 71, 1)),
    child: Text("Lupa Password?"),
  );
}

_signup(context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text("Belum punya akun? "),
      TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          style: TextButton.styleFrom(primary: Color.fromRGBO(237, 121, 71, 1)),
          child: Text("Daftar disini"))
    ],
  );
}
