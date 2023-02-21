import 'package:flutter/material.dart';
import 'package:flutter_jigsaw_puzzle/src/jigsaw_block_painter.dart';
import 'package:flutter_jigsaw_puzzle/src/models/image_box.dart';
import 'package:flutter_jigsaw_puzzle/src/puzzle_piece_clipper.dart';

class JigsawBlockWidget extends StatefulWidget {
  const JigsawBlockWidget({Key? key, required this.imageBox}) : super(key: key);

  final ImageBox imageBox;

  @override
  _JigsawBlockWidgetState createState() => _JigsawBlockWidgetState();
}

class _JigsawBlockWidgetState extends State<JigsawBlockWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: PuzzlePieceClipper(imageBox: widget.imageBox),
      child: CustomPaint(
        foregroundPainter: JigsawBlokPainter(imageBox: widget.imageBox),
        child: widget.imageBox.image,
      ),
    );
  }
}
