import 'package:flutter/material.dart';

/// Công tắc giả lập lỗi mạng để demo Rollback của Optimistic UI.
class const FailureSwitch({
  super.key,
  required final bool value,
  required final ValueChanged<bool> onChanged,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      secondary: const Icon(Icons.wifi_off),
      title: const Text('Giả lập lỗi mạng (demo Rollback)'),
      value: value,
      onChanged: onChanged,
    );
  }
}
