import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/room_event.dart';
import '../models/room_state.dart';
import '../services/iot_service.dart';
import '../widgets/curtain_control.dart';
import '../widgets/event_log_panel.dart';
import '../widgets/failure_switch.dart';
import '../widgets/light_switch_card.dart';
import '../widgets/temperature_control.dart';

/// Màn hình điều khiển chi tiết một phòng (SMART WIDGET).
/// Luồng một chiều (UDF):  UI --Event(callback)--> _dispatch --reducer--> State mới
///                         --setState--> build lại UI.
class const RoomControlScreen({
  super.key,
  required final RoomState room,
  required final ValueChanged<RoomState> onChanged,
}) extends StatefulWidget {
  @override
  State<RoomControlScreen> createState() => _RoomControlScreenState();
}

class _RoomControlScreenState extends State<RoomControlScreen> {
  late RoomState _room = widget.room;
  final List<String> _logs = [];
  int _pending = 0; // số lệnh đang chờ server
  int _lastHapticStep = -1;
  double? _dragStartBrightness;
  double? _dragStartCurtain;

  String _two(int n) => n.toString().padLeft(2, '0');

  void _log(String message) {
    final t = DateTime.now();
    _logs.insert(0, '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}  $message');
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
  }

  /// Trung tâm xử lý sự kiện:
  /// 1) Haptic  2) reducer tạo State mới -> setState (Optimistic UI, <100ms)
  /// 3) gọi API ngầm  4) thành công: ghi log  5) lỗi: kiểm tra mounted + rollback.
  Future<void> _dispatch(
    RoomEvent event,
    RoomState Function(RoomState current) reducer, {
    RoomState Function(RoomState current)? rollback,
    bool needsServer = true,
    bool haptic = true,
  }) async {
    final onChanged = widget.onChanged; // giữ lại để báo cha kể cả khi đã thoát màn hình
    if (haptic) HapticFeedback.lightImpact();

    setState(() {
      _log('Event: ${event.label}');
      _room = reducer(_room);
      if (needsServer) _pending++;
    });
    onChanged(_room);
    if (!needsServer) return;

    try {
      await iotService.sendCommand(_room.id, event.label);
      if (!mounted) return; // Async gap
      setState(() => _log('Server xác nhận'));
    } catch (_) {
      if (rollback != null) {
        _room = rollback(_room);
        onChanged(_room);
      }
      if (!mounted) return; // Async gap
      setState(() => _log('Lỗi mạng -> Rollback'));
      _snack('Lỗi kết nối, đã hoàn tác!');
    } finally {
      if (mounted) setState(() => _pending--);
    }
  }

  // ---- Đèn ----
  void _toggleLight() {
    final next = !_room.isLightOn;
    final prev = _room.isLightOn;
    _dispatch(
      ToggleLightTapped(next),
      (s) => s.copyWith(isLightOn: next),
      rollback: (s) => s.copyWith(isLightOn: prev),
    );
  }

  void _onDimmerChanged(double value) {
    _dragStartBrightness ??= _room.brightness;
    final step = (value * 20).round();
    if (step != _lastHapticStep) {
      _lastHapticStep = step;
      HapticFeedback.selectionClick(); // click nấc nhẹ khi trượt
    }
    setState(() => _room = _room.copyWith(brightness: value));
  }

  void _onDimmerEnd() {
    final start = _dragStartBrightness ?? _room.brightness;
    final end = _room.brightness;
    _dragStartBrightness = null;
    _lastHapticStep = -1;
    _dispatch(
      SliderMoved(end),
      (s) => s.copyWith(brightness: end),
      rollback: (s) => s.copyWith(brightness: start),
      haptic: false,
    );
  }

  void _resetBrightness() {
    final prevOn = _room.isLightOn;
    final prevBrightness = _room.brightness;
    _dispatch(
      const SliderResetDoubleTapped(),
      (s) => s.copyWith(isLightOn: true, brightness: 0.7),
      rollback: (s) => s.copyWith(isLightOn: prevOn, brightness: prevBrightness),
    );
    _snack('Đã đặt lại độ sáng 70%');
  }

  // ---- Điều hòa ----
  void _toggleAc(bool value) {
    final prev = _room.isAcOn;
    _dispatch(
      ToggleAcTapped(value),
      (s) => s.copyWith(isAcOn: value),
      rollback: (s) => s.copyWith(isAcOn: prev),
    );
  }

  void _changeTemp(int delta) {
    final prev = _room.temperature;
    final next = (prev + delta).clamp(RoomState.minTemp, RoomState.maxTemp).toInt();
    _dispatch(
      TemperatureChanged(next),
      (s) => s.copyWith(temperature: next),
      rollback: (s) => s.copyWith(temperature: prev),
    );
  }

  // ---- Rèm (DragUpdateCallback) ----
  void _onCurtainDrag(DragUpdateDetails details) {
    _dragStartCurtain ??= _room.curtainPosition;
    // details.delta.dx: kéo phải = mở, kéo trái = đóng
    final next = (_room.curtainPosition + details.delta.dx / 250)
        .clamp(0.0, 1.0)
        .toDouble();
    final step = (next * 10).round();
    if (step != _lastHapticStep) {
      _lastHapticStep = step;
      HapticFeedback.selectionClick();
    }
    setState(() => _room = _room.copyWith(curtainPosition: next));
  }

  void _onCurtainDragEnd() {
    final start = _dragStartCurtain ?? _room.curtainPosition;
    final end = _room.curtainPosition;
    _dragStartCurtain = null;
    _lastHapticStep = -1;
    _dispatch(
      CurtainMoved(end),
      (s) => s.copyWith(curtainPosition: end),
      rollback: (s) => s.copyWith(curtainPosition: start),
      haptic: false,
    );
  }

  void _setCurtain(double position) {
    final prev = _room.curtainPosition;
    _dispatch(
      CurtainMoved(position),
      (s) => s.copyWith(curtainPosition: position),
      rollback: (s) => s.copyWith(curtainPosition: prev),
    );
  }

  // ---- Cửa ----
  Future<void> _toggleDoor() async {
    final willLock = !_room.isLocked;
    if (!willLock) {
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
    final prev = _room.isLocked;
    final RoomEvent event =
        willLock ? const DoorLockRequested() : const DoorUnlockRequested();
    _dispatch(
      event,
      (s) => s.copyWith(isLocked: willLock),
      rollback: (s) => s.copyWith(isLocked: prev),
    );
  }

  // ---- Tắt tất cả ----
  void _turnOffAll() {
    final prevLight = _room.isLightOn;
    final prevAc = _room.isAcOn;
    _dispatch(
      const AllOffPressed(),
      (s) => s.turnedOffAll(),
      rollback: (s) => s.copyWith(isLightOn: prevLight, isAcOn: prevAc),
    );
    _snack('Đã tắt đèn và điều hòa');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final curtainPercent = (_room.curtainPosition * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(_room.name),
        actions: [
          IconButton(
            tooltip: 'Tắt tất cả',
            onPressed: _turnOffAll,
            icon: const Icon(Icons.power_settings_new),
          ),
        ],
        // Thanh tiến trình khi đang chờ server phản hồi
        bottom: _pending > 0
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      // ListView cuộn dọc + thanh kéo ngang bên trong -> Gesture Arena phân xử
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          FailureSwitch(
            value: iotService.simulateFailure,
            onChanged: (v) => setState(() => iotService.simulateFailure = v),
          ),

          // ===== ĐÈN (Dumb Widget + callbacks) =====
          LightSwitchCard(
            isTurnedOn: _room.isLightOn,
            brightness: _room.brightness,
            onToggle: _toggleLight,
            onDimmerChanged: _onDimmerChanged,
            onDimmerEnd: _onDimmerEnd,
            onReset: _resetBrightness,
          ),

          // ===== ĐIỀU HÒA (onPressed) =====
          _SectionCard(
            title: 'Điều hòa',
            trailing: Switch(value: _room.isAcOn, onChanged: _toggleAc),
            child: TemperatureControl(
              enabled: _room.isAcOn,
              temperature: _room.temperature,
              onIncrease: () => _changeTemp(1),
              onDecrease: () => _changeTemp(-1),
            ),
          ),

          // ===== RÈM (DragUpdateCallback + onPressed) =====
          _SectionCard(
            title: 'Rèm cửa - mở $curtainPercent%',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurtainControl(
                  position: _room.curtainPosition,
                  onDragUpdate: _onCurtainDrag,
                  onDragEnd: _onCurtainDragEnd,
                ),
                const SizedBox(height: 4),
                Text('Kéo ngang trên rèm để đóng/mở', style: textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                            _room.curtainPosition >= 1 ? null : () => _setCurtain(1),
                        icon: const Icon(Icons.open_in_full),
                        label: const Text('Mở rèm'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _room.curtainPosition <= 0 ? null : () => _setCurtain(0),
                        icon: const Icon(Icons.close_fullscreen),
                        label: const Text('Đóng rèm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ===== CỬA (InkWell + onTap) =====
          Card(
            clipBehavior: Clip.antiAlias,
            color: _room.isLocked ? Colors.green.shade50 : Colors.red.shade50,
            child: InkWell(
              onTap: _toggleDoor,
              child: ListTile(
                leading: Icon(
                  _room.isLocked ? Icons.lock : Icons.lock_open,
                  color: _room.isLocked ? Colors.green : Colors.red,
                ),
                title: Text(_room.isLocked ? 'Cửa đã khóa' : 'Cửa đang mở khóa'),
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
  super.key,
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
