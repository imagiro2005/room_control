import 'package:flutter/material.dart';

import 'animated_light_bulb.dart';

/// DUMB WIDGET (slide 7, 17, 18): không giữ state, chỉ vẽ theo tham số
/// và "bắn" sự kiện lên cha bằng callback.
///  - VoidCallback        : onToggle, onDimmerEnd, onReset
///  - ValueChanged<double>: onDimmerChanged (mang giá trị độ sáng mới)
/// Thanh độ sáng dùng GestureDetector (không có ripple, nhiều cử chỉ):
///  - behavior: HitTestBehavior.opaque -> bấm vào cả vùng thanh (kể cả chỗ trống)
///  - onHorizontalDragUpdate: kéo ngang. Màn hình cha là ListView cuộn dọc nên
///    Gesture Arena phải phân xử giữa "cuộn dọc" và "kéo ngang".
class const LightSwitchCard({
  super.key,
  required final bool isTurnedOn,
  required final double brightness,
  required final VoidCallback onToggle,
  required final ValueChanged<double> onDimmerChanged,
  required final VoidCallback onDimmerEnd,
  required final VoidCallback onReset,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedLightBulb(isLit: isTurnedOn),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Đèn', style: textTheme.titleMedium),
                      Text(
                        isTurnedOn
                            ? 'Độ sáng ${(brightness * 100).round()}%'
                            : 'Đang tắt',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(value: isTurnedOn, onChanged: (_) => onToggle()),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: onReset,
                  onHorizontalDragUpdate: isTurnedOn
                      ? (details) {
                          final next = (brightness + details.delta.dx / width)
                              .clamp(0.05, 1.0)
                              .toDouble();
                          onDimmerChanged(next);
                        }
                      : null,
                  onHorizontalDragEnd: isTurnedOn ? (_) => onDimmerEnd() : null,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: isTurnedOn ? brightness : 0,
                              heightFactor: 1,
                              child: ColoredBox(color: Colors.amber.shade400),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            isTurnedOn
                                ? '← Kéo để chỉnh độ sáng →'
                                : 'Gạt công tắc để bật đèn',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Text('Kéo ngang: chỉnh sáng • Chạm đúp: đặt lại 70%',
                style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
