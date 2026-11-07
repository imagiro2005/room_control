import 'package:flutter/material.dart';

/// Model trạng thái của một phòng (Dart 3.13: primary constructor,
/// "var"/"final" trong tham số sẽ tự sinh ra field tương ứng).
/// TRẠNG THÁI được lưu ở đây (và được các StatefulWidget giữ lại),
/// còn SỰ KIỆN (tap, kéo, nhấn giữ...) chỉ là tác nhân làm thay đổi trạng thái này.
class Room({
  required final String id,
  required final String name,
  required final IconData icon,
  var bool lightOn = false,
  var double brightness = 0.7, // 0.05 -> 1.0
  var bool acOn = false,
  var int temperature = 26, // 16 -> 30
  var bool curtainOpen = true,
  var bool doorLocked = true,
}) {
  static const int minTemp = 16;
  static const int maxTemp = 30;

  /// Số thiết bị đang hoạt động (đèn, điều hòa).
  int get activeDevices => (lightOn ? 1 : 0) + (acOn ? 1 : 0);

  void turnOffAll() {
    lightOn = false;
    acOn = false;
  }

  static List<Room> sampleRooms() => [
        Room(id: 'living', name: 'Phòng khách', icon: Icons.weekend, lightOn: true),
        Room(id: 'bed', name: 'Phòng ngủ', icon: Icons.bed, acOn: true, temperature: 25),
        Room(id: 'kitchen', name: 'Nhà bếp', icon: Icons.kitchen),
        Room(id: 'study', name: 'Phòng học', icon: Icons.menu_book, lightOn: true, brightness: 0.9),
      ];
}
