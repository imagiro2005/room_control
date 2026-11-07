import 'package:flutter/material.dart';

/// TRẠNG THÁI (State) của một phòng - bất biến (immutable).
/// Muốn đổi trạng thái phải tạo bản mới bằng copyWith(), khớp với slide
/// "Immutable State" trong luồng dữ liệu một chiều (UDF).
class const RoomState({
  required final String id,
  required final String name,
  required final IconData icon,
  final bool isLightOn = false,
  final double brightness = 0.7, // 0.05 -> 1.0
  final bool isAcOn = false,
  final int temperature = 26, // 16 -> 30
  final double curtainPosition = 1.0, // 0 = đóng kín, 1 = mở hết
  final bool isLocked = true,
}) {
  static const int minTemp = 16;
  static const int maxTemp = 30;

  /// Số thiết bị đang hoạt động (đèn, điều hòa).
  int get activeDevices => (isLightOn ? 1 : 0) + (isAcOn ? 1 : 0);

  RoomState copyWith({
    bool? isLightOn,
    double? brightness,
    bool? isAcOn,
    int? temperature,
    double? curtainPosition,
    bool? isLocked,
  }) {
    return RoomState(
      id: id,
      name: name,
      icon: icon,
      isLightOn: isLightOn ?? this.isLightOn,
      brightness: brightness ?? this.brightness,
      isAcOn: isAcOn ?? this.isAcOn,
      temperature: temperature ?? this.temperature,
      curtainPosition: curtainPosition ?? this.curtainPosition,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  RoomState turnedOffAll() => copyWith(isLightOn: false, isAcOn: false);

  static const List<RoomState> samples = [
    RoomState(id: 'living', name: 'Phòng khách', icon: Icons.weekend, isLightOn: true),
    RoomState(id: 'bed', name: 'Phòng ngủ', icon: Icons.bed, isAcOn: true, temperature: 25),
    RoomState(id: 'kitchen', name: 'Nhà bếp', icon: Icons.kitchen),
    RoomState(
      id: 'study',
      name: 'Phòng học',
      icon: Icons.menu_book,
      isLightOn: true,
      brightness: 0.9,
    ),
  ];
}
