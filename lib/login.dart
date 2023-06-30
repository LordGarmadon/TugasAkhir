import 'package:flutter/material.dart';
import 'package:nadiku/signup.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //backgroundColor: Color.fromRGBO(82, 223, 254, 100),
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
      children: [
        Text(
          "Welcome Back",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your credential to login"),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: InputDecoration(
              hintText: "Email", border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), fillColor: Theme.of(context).primaryColor.withOpacity(0.1), filled: true, prefixIcon: Icon(Icons.person)),
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.person),
          ),
          obscureText: true,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {},
          child: Text(
            "Login",
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

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(primary: Color.fromRGBO(238, 138, 96, 1)),
      child: Text("Forgot password?"),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Dont have an account? "),
        TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            },
            style: TextButton.styleFrom(primary: Color.fromRGBO(238, 138, 96, 1)),
            child: Text("Sign Up"))
      ],
    );
  }
}
