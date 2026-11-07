/// Giả lập dịch vụ IoT qua Cloud/Wi-Fi: có độ trễ ~600ms và có thể lỗi.
/// Dùng để demo Optimistic UI + Rollback (slide 24, 27).
class IotService {
  /// Bật công tắc "Giả lập lỗi mạng" trên giao diện để thấy rollback.
  bool simulateFailure = false;

  Future<void> sendCommand(String roomId, String command) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (simulateFailure) {
      throw Exception('Mất kết nối tới thiết bị');
    }
  }

  Future<void> sendToggle(String roomId, bool isOn) =>
      sendCommand(roomId, isOn ? 'ON' : 'OFF');
}

final IotService iotService = IotService();
