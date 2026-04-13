import 'package:flutter/material.dart';

class LiquidQuantitySlider extends StatelessWidget {
  final double value;
  final Function(double) onChanged;
  final bool allowZero;

  const LiquidQuantitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.allowZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cantidad',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)} L',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: value == 0 ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Slider(
            value: value,
            min: allowZero ? 0.0 : 0.1,
            max: 3.0,
            divisions: allowZero ? 30 : 29,
            onChanged: onChanged,
            activeColor: Colors.green,
            inactiveColor: Colors.grey.shade300,
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                allowZero ? '0.0 L' : '0.1 L',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text('1.0 L', style: TextStyle(color: Colors.grey[600])),
              Text('2.0 L', style: TextStyle(color: Colors.grey[600])),
              Text('3.0 L', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}
