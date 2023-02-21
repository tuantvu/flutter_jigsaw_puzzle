import 'package:flutter/material.dart';
import 'package:flutter_jigsaw_puzzle/src/models/image_box.dart';
import 'package:flutter_jigsaw_puzzle/src/utils/utils.dart';

class JigsawBlokPainter extends CustomPainter {
  JigsawBlokPainter({
    required this.imageBox,
  });

  ImageBox imageBox;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = imageBox.isDone ? Colors.white.withOpacity(0.2) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(
        getPiecePath(size, imageBox.radiusPoint, imageBox.offsetCenter,
            imageBox.posSide),
        paint);

    if (imageBox.isDone) {
      final Paint paintDone = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill
        ..strokeWidth = 2;
      canvas.drawPath(
          getPiecePath(size, imageBox.radiusPoint, imageBox.offsetCenter,
              imageBox.posSide),
          paintDone);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
