import 'package:flutter/material.dart';

import '../models/room.dart';
import '../widgets/room_card.dart';
import 'room_control_screen.dart';

/// Màn hình danh sách phòng - nơi GIỮ TRẠNG THÁI của toàn bộ phòng.
class const RoomListScreen({super.key}) extends StatefulWidget {
  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final List<Room> _rooms = Room.sampleRooms();

  void _snack(String message, {SnackBarAction? action}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        action: action,
      ));
  }

  // ---- Các hàm xử lý sự kiện ----

  /// Sự kiện Switch.onChanged từ RoomCard -> cập nhật trạng thái bằng setState.
  void _onLightChanged(Room room, bool value) {
    final old = room.lightOn;
    setState(() => room.lightOn = value);
    _snack(
      '${room.name}: đèn ${value ? 'BẬT' : 'TẮT'}',
      action: SnackBarAction(
        label: 'Hoàn tác',
        onPressed: () => setState(() => room.lightOn = old),
      ),
    );
  }

  /// Sự kiện onTap: mở màn hình điều khiển chi tiết.
  /// Truyền callback onChanged để màn hình con báo ngược lại khi dữ liệu đổi.
  Future<void> _openRoom(Room room) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomControlScreen(
          room: room,
          onChanged: () {
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  /// Sự kiện onLongPress: mở menu thao tác nhanh.
  void _showQuickActions(Room room) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(room.name,
                  style: Theme.of(context).textTheme.titleMedium),
              subtitle: const Text('Thao tác nhanh'),
            ),
            ListTile(
              leading: const Icon(Icons.power_settings_new),
              title: const Text('Tắt tất cả thiết bị'),
              onTap: () {
                Navigator.pop(sheetContext);
                setState(room.turnOffAll);
                _snack('Đã tắt tất cả thiết bị ở ${room.name}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Bật đèn'),
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => room.lightOn = true);
                _snack('Đã bật đèn ${room.name}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAllOff() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tắt tất cả?'),
        content: const Text('Tắt đèn và điều hòa của mọi phòng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        for (final r in _rooms) {
          r.turnOffAll();
        }
      });
      _snack('Đã tắt tất cả thiết bị');
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _rooms.fold<int>(0, (sum, r) => sum + r.activeDevices);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Control'),
        actions: [
          IconButton(
            tooltip: 'Tắt tất cả',
            onPressed: _confirmAllOff,
            icon: const Icon(Icons.power_settings_new),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Đang bật $total thiết bị  •  Chạm: mở phòng  •  Nhấn giữ: thao tác nhanh',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: _rooms.length,
                // Ô tự co giãn theo bề rộng màn hình (web không bị ô quá to)
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  childAspectRatio: 1.15,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  return RoomCard(
                    room: room,
                    onTap: () => _openRoom(room),
                    onLongPress: () => _showQuickActions(room),
                    onLightChanged: (v) => _onLightChanged(room, v),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
