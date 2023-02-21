import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_jigsaw_puzzle/src/block_class.dart';
import 'package:flutter_jigsaw_puzzle/src/jigsaw_block_widget.dart';
import 'package:flutter_jigsaw_puzzle/src/jigsaw_painter_background.dart';
import 'package:flutter_jigsaw_puzzle/src/models/class_jigsaw_pos.dart';
import 'package:flutter_jigsaw_puzzle/src/models/image_box.dart';
import 'package:image/image.dart' as ui;

import 'package:flutter_jigsaw_puzzle/src/error.dart';

class JigsawWidget extends StatefulWidget {
  const JigsawWidget({
    Key? key,
    required this.gridSize,
    required this.snapSensitivity,
    required this.child,
    this.callbackFinish,
    this.callbackSuccess,
    this.outlineCanvas = true,
  }) : super(key: key);

  final Widget child;
  final Function()? callbackSuccess;
  final Function()? callbackFinish;
  final int gridSize;
  final bool outlineCanvas;
  final double snapSensitivity;

  @override
  JigsawWidgetState createState() => JigsawWidgetState();
}

class JigsawWidgetState extends State<JigsawWidget> {
  final GlobalKey _globalKey = GlobalKey();
  ui.Image? fullImage;
  Size? size;

  List<List<BlockClass>> images = <List<BlockClass>>[];
  ValueNotifier<List<BlockClass>> blocksNotifier =
      ValueNotifier<List<BlockClass>>(<BlockClass>[]);
  CarouselController? _carouselController;

  Offset _pos = Offset.zero;
  int? _index;

  Future<ui.Image?> _getImageFromWidget() async {
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    size = boundary.size;
    final img = await boundary.toImage();
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();

    if (pngBytes == null) {
      throw InvalidImageException();
    }
    return ui.decodeImage(List<int>.from(pngBytes));
  }

  void reset() {
    images.clear();
    blocksNotifier = ValueNotifier<List<BlockClass>>(<BlockClass>[]);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  Future<void> generate() async {
    images = [[]];

    fullImage ??= await _getImageFromWidget();

    final int xSplitCount = widget.gridSize;
    final int ySplitCount = widget.gridSize;

    final double widthPerBlock = fullImage!.width / xSplitCount;
    final double heightPerBlock = fullImage!.height / ySplitCount;

    for (var y = 0; y < ySplitCount; y++) {
      final tempImages = <BlockClass>[];

      images.add(tempImages);
      for (var x = 0; x < xSplitCount; x++) {
        final int randomPosRow = math.Random().nextInt(2).isEven ? 1 : -1;
        final int randomPosCol = math.Random().nextInt(2).isEven ? 1 : -1;

        Offset offsetCenter = Offset(widthPerBlock / 2, heightPerBlock / 2);

        final ClassJigsawPos jigsawPosSide = ClassJigsawPos(
          bottom: y == ySplitCount - 1 ? 0 : randomPosCol,
          left: x == 0
              ? 0
              : -images[y][x - 1].jigsawBlockWidget.imageBox.posSide.right,
          right: x == xSplitCount - 1 ? 0 : randomPosRow,
          top: y == 0
              ? 0
              : -images[y - 1][x].jigsawBlockWidget.imageBox.posSide.bottom,
        );

        double xAxis = widthPerBlock * x;
        double yAxis = heightPerBlock * y;

        final double minSize = math.min(widthPerBlock, heightPerBlock) / 15 * 4;

        offsetCenter = Offset(
          (widthPerBlock / 2) + (jigsawPosSide.left == 1 ? minSize : 0),
          (heightPerBlock / 2) + (jigsawPosSide.top == 1 ? minSize : 0),
        );

        xAxis -= jigsawPosSide.left == 1 ? minSize : 0;
        yAxis -= jigsawPosSide.top == 1 ? minSize : 0;

        final double widthPerBlockTemp = widthPerBlock +
            (jigsawPosSide.left == 1 ? minSize : 0) +
            (jigsawPosSide.right == 1 ? minSize : 0);
        final double heightPerBlockTemp = heightPerBlock +
            (jigsawPosSide.top == 1 ? minSize : 0) +
            (jigsawPosSide.bottom == 1 ? minSize : 0);

        final ui.Image temp = ui.copyCrop(
          fullImage!,
          xAxis.round(),
          yAxis.round(),
          widthPerBlockTemp.round(),
          heightPerBlockTemp.round(),
        );

        final Offset offset = Offset(size!.width / 2 - widthPerBlockTemp / 2,
            size!.height / 2 - heightPerBlockTemp / 2);

        final ImageBox imageBox = ImageBox(
          image: Image.memory(
            Uint8List.fromList(ui.encodePng(temp)),
            fit: BoxFit.contain,
          ),
          isDone: false,
          offsetCenter: offsetCenter,
          posSide: jigsawPosSide,
          radiusPoint: minSize,
          size: Size(widthPerBlockTemp, heightPerBlockTemp),
        );

        images[y].add(
          BlockClass(
              jigsawBlockWidget: JigsawBlockWidget(
                imageBox: imageBox,
              ),
              offset: offset,
              offsetDefault: Offset(xAxis, yAxis)),
        );
      }
    }

    blocksNotifier.value = images.expand((image) => image).toList();
    blocksNotifier.value.shuffle();
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    blocksNotifier.notifyListeners();
    setState(() {});
  }

  @override
  void initState() {
    _carouselController = CarouselController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: blocksNotifier,
        builder: (context, List<BlockClass> blocks, child) {
          final List<BlockClass> blockNotDone = blocks
              .where((block) => !block.jigsawBlockWidget.imageBox.isDone)
              .toList();
          final List<BlockClass> blockDone = blocks
              .where((block) => block.jigsawBlockWidget.imageBox.isDone)
              .toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: SizedBox(
                  width: double.infinity,
                  child: Listener(
                    onPointerUp: (event) {
                      if (blockNotDone.isEmpty) {
                        reset();
                        widget.callbackFinish?.call();
                      }

                      if (_index == null) {
                        _carouselController?.nextPage(
                            duration: const Duration(microseconds: 600));
                        setState(() {});
                      }
                    },
                    onPointerMove: (event) {
                      if (_index == null) {
                        return;
                      }
                      if (blockNotDone.isEmpty) {
                        return;
                      }

                      final Offset offset = event.localPosition - _pos;

                      blockNotDone[_index!].offset = offset;

                      const minSensitivity = 0;
                      const maxSensitivity = 1;
                      const maxDistanceThreshold = 20;
                      const minDistanceThreshold = 1;

                      final sensitivity = widget.snapSensitivity;
                      final distanceThreshold = sensitivity *
                              (maxSensitivity - minSensitivity) *
                              (maxDistanceThreshold - minDistanceThreshold) +
                          minDistanceThreshold;

                      if ((blockNotDone[_index!].offset -
                                  blockNotDone[_index!].offsetDefault)
                              .distance <
                          distanceThreshold) {
                        blockNotDone[_index!]
                            .jigsawBlockWidget
                            .imageBox
                            .isDone = true;

                        blockNotDone[_index!].offset =
                            blockNotDone[_index!].offsetDefault;

                        _index = null;

                        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                        blocksNotifier.notifyListeners();

                        widget.callbackSuccess?.call();
                      }

                      setState(() {});
                    },
                    child: Stack(
                      children: [
                        if (blocks.isEmpty) ...[
                          RepaintBoundary(
                            key: _globalKey,
                            child: SizedBox(
                              height: double.maxFinite,
                              width: double.maxFinite,
                              child: widget.child,
                            ),
                          )
                        ],
                        Offstage(
                          offstage: blocks.isEmpty,
                          child: Container(
                            color: Colors.white,
                            width: size?.width,
                            height: size?.height,
                            child: CustomPaint(
                              painter: JigsawPainterBackground(
                                blocks,
                                outlineCanvas: widget.outlineCanvas,
                              ),
                              child: Stack(
                                children: [
                                  if (blockDone.isNotEmpty)
                                    ...blockDone.map(
                                      (map) {
                                        return Positioned(
                                          left: map.offset.dx,
                                          top: map.offset.dy,
                                          child: Container(
                                            child: map.jigsawBlockWidget,
                                          ),
                                        );
                                      },
                                    ),
                                  if (blockNotDone.isNotEmpty)
                                    ...blockNotDone.asMap().entries.map(
                                      (map) {
                                        return Positioned(
                                          left: map.value.offset.dx,
                                          top: map.value.offset.dy,
                                          child: Offstage(
                                            offstage: !(_index == map.key),
                                            child: GestureDetector(
                                              onTapDown: (details) {
                                                if (map.value.jigsawBlockWidget
                                                    .imageBox.isDone) {
                                                  return;
                                                }

                                                setState(() {
                                                  _pos = details.localPosition;
                                                  _index = map.key;
                                                });
                                              },
                                              child: Container(
                                                child:
                                                    map.value.jigsawBlockWidget,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                  color: Colors.white,
                  height: 120,
                  child: CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      initialPage: _index ?? 0,
                      height: 80,
                      aspectRatio: 1,
                      viewportFraction: 0.3,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        _index = index;
                        setState(() {});
                      },
                    ),
                    items: blockNotDone.map((block) {
                      final Size sizeBlock =
                          block.jigsawBlockWidget.imageBox.size;
                      return FittedBox(
                        child: SizedBox(
                          width: sizeBlock.width,
                          height: sizeBlock.height,
                          child: block.jigsawBlockWidget,
                        ),
                      );
                    }).toList(),
                  ))
            ],
          );
        });
  }
}
