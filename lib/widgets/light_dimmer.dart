import 'package:flutter/material.dart';

/// Thanh chỉnh độ sáng bằng GestureDetector:
/// - onTap                    : bật/tắt đèn
/// - onDoubleTap              : đặt lại độ sáng mặc định (70%)
/// - onHorizontalDragUpdate   : kéo ngang để đổi độ sáng (phản hồi tức thì)
/// - onHorizontalDragEnd      : kết thúc kéo -> ghi log 1 lần
class const LightDimmer({
  super.key,
  required final bool isOn,
  required final double brightness,
  required final VoidCallback onToggle,
  required final VoidCallback onReset,
  required final ValueChanged<double> onChanged,
  required final VoidCallback onChangeEnd,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onTap: onToggle,
          onDoubleTap: onReset,
          onHorizontalDragUpdate: isOn
              ? (details) {
                  final next =
                      (brightness + details.delta.dx / width).clamp(0.05, 1.0);
                  onChanged(next.toDouble());
                }
              : null,
          onHorizontalDragEnd: isOn ? (_) => onChangeEnd() : null,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 80),
                  widthFactor: isOn ? brightness : 0,
                  heightFactor: 1,
                  child: Container(color: Colors.amber.shade400),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOn
                            ? 'Độ sáng ${(brightness * 100).round()}%'
                            : 'Đèn đang tắt - chạm để bật',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
