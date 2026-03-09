import 'package:flutter/material.dart';
import '../../viewmodels/shopping_viewmodel.dart';

class ShoppingAddInput extends StatelessWidget {
  final ShoppingViewModel vm;
  final TextEditingController controller;

  const ShoppingAddInput({
    super.key,
    required this.vm,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Añadir nuevo item...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.green),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                vm.addManualItem(controller.text);
                controller.clear();
              }
            },
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            vm.addManualItem(value);
            controller.clear();
          }
        },
      ),
    );
  }
}
