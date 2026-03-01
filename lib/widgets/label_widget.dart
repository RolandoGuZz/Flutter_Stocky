import 'package:flutter/material.dart';

class LabelWidget extends StatelessWidget {
  final String text;
  final Color? color;

  const LabelWidget({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.grey[700],
        letterSpacing: 0.5,
      ),
    );
  }
}
