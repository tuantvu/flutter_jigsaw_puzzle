import 'package:flutter/material.dart';
import 'package:flutter_jigsaw_puzzle/src/block_class.dart';
import 'package:flutter_jigsaw_puzzle/src/utils/utils.dart';

class JigsawPainterBackground extends CustomPainter {
  JigsawPainterBackground(this.blocks, {required this.outlineCanvas});

  List<BlockClass> blocks;
  bool outlineCanvas;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = outlineCanvas ? PaintingStyle.stroke : PaintingStyle.fill
      ..color = Colors.black12
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final Path path = Path();

    blocks.forEach((element) {
      final Path pathTemp = getPiecePath(
        element.jigsawBlockWidget.imageBox.size,
        element.jigsawBlockWidget.imageBox.radiusPoint,
        element.jigsawBlockWidget.imageBox.offsetCenter,
        element.jigsawBlockWidget.imageBox.posSide,
      );

      path.addPath(pathTemp, element.offsetDefault);
    });

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
