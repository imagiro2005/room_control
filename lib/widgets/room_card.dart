import 'package:flutter/material.dart';

import '../models/room.dart';

/// Thẻ phòng ở màn hình danh sách.
/// - InkWell: bắt onTap / onLongPress và có hiệu ứng ripple.
/// - Callback: widget con KHÔNG tự giữ trạng thái, chỉ "báo" sự kiện ra ngoài
///   qua onTap, onLongPress, onLightChanged.
/// - Hình minh họa mờ: icon lớn làm "watermark" + ánh sáng/biểu tượng thiết bị
///   thay đổi theo trạng thái (đèn bật -> có quầng sáng, điều hòa bật -> có icon tuyết).
class const RoomCard({
  super.key,
  required final Room room,
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
            // 1) Quầng sáng ấm khi đèn bật (mờ, phản ánh trạng thái)
            if (room.lightOn)
              Positioned.fill(
                child: DecoratedBox(
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

            // 2) Hình minh họa phòng - icon lớn, mờ, nằm góc dưới phải
            Positioned(
              right: -18,
              bottom: -18,
              child: Icon(
                room.icon,
                size: 120,
                color: scheme.primary.withValues(alpha: 0.13),
              ),
            ),

            // 3) Icon tuyết mờ khi điều hòa đang bật
            if (room.acOn)
              Positioned(
                right: 14,
                top: 52,
                child: Icon(
                  Icons.ac_unit,
                  size: 40,
                  color: Colors.lightBlue.withValues(alpha: 0.35),
                ),
              ),

            // 4) Nội dung chính
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
                        value: room.lightOn,
                        onChanged: onLightChanged, // callback trả giá trị mới lên cha
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    room.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
