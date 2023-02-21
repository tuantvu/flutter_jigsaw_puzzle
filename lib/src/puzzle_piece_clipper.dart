import 'package:flutter/material.dart';
import 'package:flutter_jigsaw_puzzle/src/models/image_box.dart';
import 'package:flutter_jigsaw_puzzle/src/utils/utils.dart';

class PuzzlePieceClipper extends CustomClipper<Path> {
  PuzzlePieceClipper({
    required this.imageBox,
  });

  ImageBox imageBox;

  @override
  Path getClip(Size size) {
    return getPiecePath(
        size, imageBox.radiusPoint, imageBox.offsetCenter, imageBox.posSide);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
