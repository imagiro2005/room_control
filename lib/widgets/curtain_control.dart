import 'package:flutter/material.dart';

/// Kéo rèm cửa thông minh (slide 7: DragUpdateCallback).
/// onDragUpdate có kiểu GestureDragUpdateCallback = void Function(DragUpdateDetails)
/// -> mang theo toạ độ (localPosition) và delta di chuyển (delta) lên widget cha.
class const CurtainControl({
  super.key,
  required final double position,
  required final GestureDragUpdateCallback onDragUpdate,
  required final VoidCallback onDragEnd,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: (_) => onDragEnd(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final panelWidth = constraints.maxWidth / 2 * (1 - position);
          return Container(
            height: 90,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.wb_sunny, color: Colors.amber, size: 40),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: panelWidth,
                  child: ColoredBox(color: Colors.brown.shade300),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: panelWidth,
                  child: ColoredBox(color: Colors.brown.shade300),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
