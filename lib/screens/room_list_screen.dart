import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/room_state.dart';
import '../services/iot_service.dart';
import '../widgets/failure_switch.dart';
import '../widgets/room_card.dart';
import 'room_control_screen.dart';

/// SMART WIDGET (State Holder) - Lifting State Up:
/// danh sách trạng thái các phòng được giữ ở đây (tổ tiên chung gần nhất),
/// các widget con (RoomCard...) chỉ nhận dữ liệu và bắn callback lên.
class const RoomListScreen({super.key}) extends StatefulWidget {
  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  List<RoomState> _rooms = List.of(RoomState.samples);

  RoomState _byId(String id) => _rooms.firstWhere((r) => r.id == id);

  /// Thay State cũ bằng State mới (bất biến) rồi setState để rebuild.
  void _replace(RoomState updated) {
    setState(() {
      _rooms = [for (final r in _rooms) r.id == updated.id ? updated : r];
    });
  }

  void _snack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: action,
      ));
  }

  /// OPTIMISTIC UI (slide 24, 27):
  /// 1) Haptic  2) đổi UI ngay  3) gọi API ngầm  4) lỗi -> kiểm tra mounted -> rollback.
  Future<void> _apply(
    String roomId,
    String command, {
    required RoomState Function(RoomState current) change,
    required RoomState Function(RoomState current) rollback,
    String? message,
    SnackBarAction? action,
  }) async {
    HapticFeedback.lightImpact();
    _replace(change(_byId(roomId)));
    if (message != null) _snack(message, action: action);
    try {
      await iotService.sendCommand(roomId, command);
    } catch (_) {
      if (!mounted) return; // Async gap
      _replace(rollback(_byId(roomId)));
      _snack('Lỗi kết nối, đã hoàn tác!');
    }
  }

  // ---- Các hàm xử lý sự kiện (nhận Callback từ widget con) ----

  void _toggleLight(RoomState room, bool value) {
    final previous = room.isLightOn;
    _apply(
      room.id,
      value ? 'LIGHT_ON' : 'LIGHT_OFF',
      change: (r) => r.copyWith(isLightOn: value),
      rollback: (r) => r.copyWith(isLightOn: previous),
      message: '${room.name}: đèn ${value ? 'BẬT' : 'TẮT'}',
      action: SnackBarAction(
        label: 'HOÀN TÁC',
        onPressed: () => _toggleLight(_byId(room.id), previous),
      ),
    );
  }

  void _turnOffRoom(RoomState room) {
    final prevLight = room.isLightOn;
    final prevAc = room.isAcOn;
    _apply(
      room.id,
      'ALL_OFF',
      change: (r) => r.turnedOffAll(),
      rollback: (r) => r.copyWith(isLightOn: prevLight, isAcOn: prevAc),
    );
  }

  /// onTap: mở màn hình điều khiển chi tiết, truyền callback để nhận State mới.
  Future<void> _openRoom(RoomState room) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomControlScreen(
          room: room,
          onChanged: (updated) {
            if (mounted) _replace(updated);
          },
        ),
      ),
    );
  }

  /// onLongPress: menu thao tác nhanh.
  void _showQuickActions(RoomState room) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(room.name, style: Theme.of(context).textTheme.titleMedium),
              subtitle: const Text('Thao tác nhanh'),
            ),
            ListTile(
              leading: const Icon(Icons.power_settings_new),
              title: const Text('Tắt tất cả thiết bị'),
              onTap: () {
                Navigator.pop(sheetContext);
                _turnOffRoom(room);
                _snack('Đã tắt tất cả thiết bị ở ${room.name}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb),
              title: const Text('Bật đèn'),
              onTap: () {
                Navigator.pop(sheetContext);
                _toggleLight(room, true);
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
    if (ok == true && mounted) {
      for (final room in _rooms) {
        _turnOffRoom(room);
      }
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
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'Đang bật $total thiết bị  •  Chạm: mở phòng  •  Nhấn giữ: thao tác nhanh',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            FailureSwitch(
              value: iotService.simulateFailure,
              onChanged: (v) => setState(() => iotService.simulateFailure = v),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: _rooms.length,
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
                    onLightChanged: (v) => _toggleLight(room, v),
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
