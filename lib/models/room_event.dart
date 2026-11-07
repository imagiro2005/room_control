/// SỰ KIỆN (Event / Intent) - "Điều gì vừa xảy ra?".
/// Tức thời (transient): phát ra rồi tiêu biến, KHÔNG được lưu như state.
/// Dùng sealed class để switch bên dưới luôn đầy đủ các trường hợp.
sealed class RoomEvent {
  const RoomEvent();

  String get label => switch (this) {
        ToggleLightTapped(:final turnOn) =>
          'ToggleLightTapped(${turnOn ? 'ON' : 'OFF'})',
        SliderMoved(:final value) => 'SliderMoved(${value.toStringAsFixed(2)})',
        SliderResetDoubleTapped() => 'SliderResetDoubleTapped',
        ToggleAcTapped(:final turnOn) =>
          'ToggleAcTapped(${turnOn ? 'ON' : 'OFF'})',
        TemperatureChanged(:final value) => 'TemperatureChanged(${value}°C)',
        CurtainMoved(:final position) =>
          'CurtainMoved(${(position * 100).round()}%)',
        DoorLockRequested() => 'DoorLockRequested',
        DoorUnlockRequested() => 'DoorUnlockRequested',
        AllOffPressed() => 'AllOffPressed',
      };
}

class const ToggleLightTapped(final bool turnOn) extends RoomEvent;

class const SliderMoved(final double value) extends RoomEvent;

class const SliderResetDoubleTapped() extends RoomEvent;

class const ToggleAcTapped(final bool turnOn) extends RoomEvent;

class const TemperatureChanged(final int value) extends RoomEvent;

class const CurtainMoved(final double position) extends RoomEvent;

class const DoorLockRequested() extends RoomEvent;

class const DoorUnlockRequested() extends RoomEvent;

class const AllOffPressed() extends RoomEvent;
