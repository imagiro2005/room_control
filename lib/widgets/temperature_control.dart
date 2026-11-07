import 'package:flutter/material.dart';

import '../models/room_state.dart';

/// Điều khiển điều hòa: IconButton.onPressed tăng/giảm nhiệt độ.
/// onPressed == null -> nút tự mờ đi (ngữ nghĩa Disabled của Material, slide 10).
class const TemperatureControl({
  super.key,
  required final bool enabled,
  required final int temperature,
  required final VoidCallback onIncrease,
  required final VoidCallback onDecrease,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final canDown = enabled && temperature > RoomState.minTemp;
    final canUp = enabled && temperature < RoomState.maxTemp;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: canDown ? onDecrease : null,
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: 20),
        Text(
          enabled ? '$temperature°C' : '--',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(width: 20),
        IconButton.filledTonal(
          onPressed: canUp ? onIncrease : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
