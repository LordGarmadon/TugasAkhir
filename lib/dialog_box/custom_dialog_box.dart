import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({super.key, required this.title, required this.description});
  final String title, description;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Close'),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class DoubleButtonDialog extends StatelessWidget {
  const DoubleButtonDialog({super.key, required this.title, required this.description, this.onFirstButtonTap, this.onSecondButtonTap, this.firstButton, this.secondButton});
  final String title, description;
  final Function()? onFirstButtonTap, onSecondButtonTap;
  final String? firstButton, secondButton;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        TextButton(
          onPressed: () => onFirstButtonTap != null ? onFirstButtonTap!() : Navigator.pop(context, firstButton ?? 'Ok'),
          child: Text(firstButton ?? 'Ok'),
        ),
        TextButton(
          onPressed: () => onSecondButtonTap != null ? onSecondButtonTap!() : Navigator.pop(context, secondButton ?? 'Close'),
          child: Text(secondButton ?? 'Close'),
        ),
      ],
    );
  }
}
