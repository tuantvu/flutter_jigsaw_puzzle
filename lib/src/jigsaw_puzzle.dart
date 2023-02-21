import 'package:flutter/material.dart';
import 'package:flutter_jigsaw_puzzle/src/jigsaw_widget.dart';

class JigsawPuzzle extends StatelessWidget {
  const JigsawPuzzle({
    Key? key,
    required this.gridSize,
    required this.image,
    required this.puzzleKey,
    this.onFinished,
    this.onBlockSuccess,
    this.outlineCanvas = true,
    this.autoStart = false,
    this.snapSensitivity = .5,
  }) : super(key: key);

  final int gridSize;
  final Function()? onFinished;
  final Function()? onBlockSuccess;
  final ImageProvider image;
  final bool autoStart;
  final bool outlineCanvas;
  final double snapSensitivity;
  final GlobalKey<JigsawWidgetState> puzzleKey;

  @override
  Widget build(BuildContext context) {
    return JigsawWidget(
      callbackFinish: () {
        if (onFinished != null) {
          onFinished!();
        }
      },
      callbackSuccess: () {
        if (onBlockSuccess != null) {
          onBlockSuccess!();
        }
      },
      key: puzzleKey,
      gridSize: gridSize,
      snapSensitivity: snapSensitivity,
      outlineCanvas: outlineCanvas,
      child: Image(
        fit: BoxFit.contain,
        image: image,
      ),
    );
  }
}
