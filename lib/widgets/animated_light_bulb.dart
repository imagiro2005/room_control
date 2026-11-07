import 'package:flutter/material.dart';

/// Micro-animation (slide 22): đổi màu bóng đèn mượt trong 300ms
/// bằng AnimatedContainer -> phản hồi thị giác trong ngưỡng 100ms.
class const AnimatedLightBulb({
  super.key,
  required final bool isLit,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLit
            ? Colors.amber.withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lightbulb,
        color: isLit ? Colors.amber : Colors.grey,
        size: 36,
      ),
    );
  }
}
