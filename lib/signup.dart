import 'dart:developer';

import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController etNama = TextEditingController();
  TextEditingController etEmail = TextEditingController();
  TextEditingController etPassword = TextEditingController();

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
          "Create Account",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter details to get started"),
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
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: etEmail,
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
            log(etNama.text);
            log(etEmail.text);
            log(etPassword.text);
          },
          child: Text(
            "Sign Up",
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

  _loginInfo(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?"),
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
