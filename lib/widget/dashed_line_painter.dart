

import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final bool drawTopHalf;
  final bool drawBottomHalf;

  DashedLinePainter({
    this.color = Colors.white24,
    this.strokeWidth = 1,
    this.dashWidth = 3,
    this.dashSpace = 3,
    this.drawTopHalf = true,
    this.drawBottomHalf = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final totalHeight = size.height;
    final double startY = drawTopHalf ? 0 : totalHeight / 2;
    final double endY = drawBottomHalf ? totalHeight : totalHeight / 2;

    if (startY >= endY) return; // 不需要绘制

    // 绘制虚线
    double currentY = startY;
    while (currentY < endY) {
      final nextY = currentY + dashWidth;
      canvas.drawLine(
        Offset(size.width / 2, currentY),
        Offset(size.width / 2, nextY.clamp(currentY, endY)),
        paint,
      );
      currentY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}