import 'package:flutter/material.dart';
import 'package:flutter_jigsaw_puzzle/src/models/class_jigsaw_pos.dart';

class ImageBox {
  ImageBox({
    required this.image,
    required this.posSide,
    required this.isDone,
    required this.offsetCenter,
    required this.radiusPoint,
    required this.size,
  });

  Widget image;
  ClassJigsawPos posSide;
  Offset offsetCenter;
  Size size;
  double radiusPoint;
  bool isDone;
}
