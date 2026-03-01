import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final Function(String) onChanged;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool isOptional;
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
    this.isOptional = false,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        textCapitalization: TextCapitalization.words,
        onChanged: onChanged,
        validator: isOptional ? null : validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.green, size: 20)
              : null,
        ),
      ),
    );
  }
}
