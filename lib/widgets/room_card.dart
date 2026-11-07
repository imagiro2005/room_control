import 'package:flutter/material.dart';

import '../models/room_state.dart';

/// Thẻ phòng ở màn hình danh sách (Dumb Widget).
/// - InkWell: onTap / onLongPress + hiệu ứng ripple (cần Material tổ tiên: Card).
/// - Lớp quầng sáng dùng Ink (không dùng Container có màu) để KHÔNG che mất ripple
///   -> tránh "cạm bẫy kinh điển" ở slide 11.
class const RoomCard({
  super.key,
  required final RoomState room,
  required final VoidCallback onTap,
  required final VoidCallback onLongPress,
  required final ValueChanged<bool> onLightChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = room.activeDevices > 0;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: active ? scheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          children: [
            // Quầng sáng ấm khi đèn bật (phản ánh State lên UI)
            if (room.isLightOn)
              Positioned.fill(
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.1,
                      colors: [
                        Colors.amber.withValues(alpha: 0.45),
                        Colors.amber.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

            // Hình minh họa phòng - icon lớn, mờ
            Positioned(
              right: -18,
              bottom: -18,
              child: Icon(
                room.icon,
                size: 120,
                color: scheme.primary.withValues(alpha: 0.13),
              ),
            ),

            // Icon tuyết mờ khi điều hòa bật
            if (room.isAcOn)
              Positioned(
                right: 14,
                top: 52,
                child: Icon(
                  Icons.ac_unit,
                  size: 40,
                  color: Colors.lightBlue.withValues(alpha: 0.35),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(room.icon, size: 30),
                      const Spacer(),
                      Switch(
                        value: room.isLightOn,
                        onChanged: onLightChanged, // ValueChanged<bool>
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(room.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    active ? '${room.activeDevices} thiết bị đang bật' : 'Đang tắt',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
