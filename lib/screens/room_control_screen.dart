import 'package:flutter/material.dart';

import '../models/room.dart';
import '../widgets/event_log_panel.dart';
import '../widgets/light_dimmer.dart';
import '../widgets/temperature_control.dart';

/// Màn hình điều khiển chi tiết một phòng.
/// Tổng hợp: callback, onPressed, onTap, GestureDetector, InkWell.
///
/// [onChanged] là callback báo cho màn hình cha biết dữ liệu phòng đã thay đổi.
class const RoomControlScreen({
  super.key,
  required final Room room,
  required final VoidCallback onChanged,
}) extends StatefulWidget {
  @override
  State<RoomControlScreen> createState() => _RoomControlScreenState();
}

class _RoomControlScreenState extends State<RoomControlScreen> {
  final List<String> _logs = [];

  Room get room => widget.room;

  String _two(int n) => n.toString().padLeft(2, '0');

  /// Ghi nhận sự kiện -> hiển thị lên bảng nhật ký.
  void _log(String message) {
    final t = DateTime.now();
    _logs.insert(0, '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}  $message');
  }

  /// Mọi sự kiện đều đi qua hàm này:
  /// 1) thay đổi trạng thái  2) ghi log  3) setState để vẽ lại UI  4) báo cha.
  void _handle(String eventName, VoidCallback change) {
    setState(() {
      change();
      _log(eventName);
    });
    widget.onChanged();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ));
  }

  // ---- Đèn ----
  void _toggleLight([bool? value]) {
    final next = value ?? !room.lightOn;
    _handle('Đèn ${next ? 'BẬT' : 'TẮT'}', () => room.lightOn = next);
  }

  void _resetBrightness() {
    _handle('Double tap: reset độ sáng 70%', () {
      room.lightOn = true;
      room.brightness = 0.7;
    });
    _snack('Đã đặt lại độ sáng 70%');
  }

  // ---- Điều hòa ----
  void _changeTemp(int delta) {
    _handle('Nhiệt độ ${delta > 0 ? 'tăng' : 'giảm'} -> ${room.temperature + delta}°C',
        () => room.temperature += delta);
  }

  // ---- Rèm ----
  void _setCurtain(bool open) {
    _handle('Rèm ${open ? 'MỞ' : 'ĐÓNG'}', () => room.curtainOpen = open);
  }

  // ---- Cửa ----
  Future<void> _toggleDoor() async {
    if (room.doorLocked) {
      // Mở khóa là thao tác nhạy cảm -> hỏi xác nhận.
      final ok = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Mở khóa cửa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Mở khóa'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    _handle('Cửa ${room.doorLocked ? 'MỞ KHÓA' : 'KHÓA'}',
        () => room.doorLocked = !room.doorLocked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(room.name),
        actions: [
          IconButton(
            tooltip: 'Tắt tất cả',
            onPressed: () {
              _handle('Tắt tất cả thiết bị', room.turnOffAll);
              _snack('Đã tắt đèn và điều hòa');
            },
            icon: const Icon(Icons.power_settings_new),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ===== ĐÈN =====
          _SectionCard(
            title: 'Đèn',
            trailing: Switch(value: room.lightOn, onChanged: _toggleLight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LightDimmer(
                  isOn: room.lightOn,
                  brightness: room.brightness,
                  onToggle: _toggleLight,
                  onReset: _resetBrightness,
                  onChanged: (v) => setState(() {
                    room.brightness = v; // phản hồi tức thì khi đang kéo
                  }),
                  onChangeEnd: () {
                    widget.onChanged();
                    setState(() => _log(
                        'Kéo độ sáng -> ${(room.brightness * 100).round()}%'));
                  },
                ),
                const SizedBox(height: 6),
                Text('Chạm: bật/tắt • Kéo ngang: chỉnh sáng • Chạm đúp: reset',
                    style: textTheme.bodySmall),
              ],
            ),
          ),

          // ===== ĐIỀU HÒA =====
          _SectionCard(
            title: 'Điều hòa',
            trailing: Switch(
              value: room.acOn,
              onChanged: (v) =>
                  _handle('Điều hòa ${v ? 'BẬT' : 'TẮT'}', () => room.acOn = v),
            ),
            child: TemperatureControl(
              enabled: room.acOn,
              temperature: room.temperature,
              onIncrease: () => _changeTemp(1),
              onDecrease: () => _changeTemp(-1),
            ),
          ),

          // ===== RÈM =====
          _SectionCard(
            title: 'Rèm cửa',
            trailing: Icon(
              room.curtainOpen ? Icons.wb_sunny : Icons.nights_stay,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: room.curtainOpen ? null : () => _setCurtain(true),
                    icon: const Icon(Icons.open_in_full),
                    label: const Text('Mở rèm'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: room.curtainOpen ? () => _setCurtain(false) : null,
                    icon: const Icon(Icons.close_fullscreen),
                    label: const Text('Đóng rèm'),
                  ),
                ),
              ],
            ),
          ),

          // ===== CỬA (InkWell) =====
          Card(
            clipBehavior: Clip.antiAlias,
            color: room.doorLocked ? Colors.green.shade50 : Colors.red.shade50,
            child: InkWell(
              onTap: _toggleDoor,
              child: ListTile(
                leading: Icon(
                  room.doorLocked ? Icons.lock : Icons.lock_open,
                  color: room.doorLocked ? Colors.green : Colors.red,
                ),
                title: Text(room.doorLocked ? 'Cửa đã khóa' : 'Cửa đang mở khóa'),
                subtitle: const Text('Chạm để đổi trạng thái (InkWell)'),
              ),
            ),
          ),

          // ===== NHẬT KÝ SỰ KIỆN =====
          EventLogPanel(
            logs: _logs,
            onClear: () => setState(_logs.clear),
          ),
        ],
      ),
    );
  }
}

class const _SectionCard({
  required final String title,
  required final Widget child,
  final Widget? trailing,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
