import 'package:flutter/material.dart';

/// Bảng nhật ký sự kiện: minh họa "sự kiện được tiếp nhận" (mỗi dòng là một sự kiện).
class const EventLogPanel({
  super.key,
  required final List<String> logs,
  required final VoidCallback onClear,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, size: 20),
                const SizedBox(width: 6),
                Text('Nhật ký sự kiện',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                TextButton(
                  onPressed: logs.isEmpty ? null : onClear,
                  child: const Text('Xóa'),
                ),
              ],
            ),
            if (logs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Chưa có sự kiện nào. Hãy thao tác với thiết bị!'),
              )
            else
              for (final line in logs.take(8))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(line, style: const TextStyle(fontSize: 13)),
                ),
          ],
        ),
      ),
    );
  }
}
