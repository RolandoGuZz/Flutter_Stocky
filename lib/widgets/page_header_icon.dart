import 'package:flutter/material.dart';

class PageHeaderIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const PageHeaderIcon({
    super.key,
    required this.icon,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 40, color: color),
      ),
    );
  }
}
