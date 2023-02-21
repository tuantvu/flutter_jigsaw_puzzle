import 'dart:ui';

import 'package:flutter_jigsaw_puzzle/src/jigsaw_block_widget.dart';

class BlockClass {
  BlockClass({
    required this.offset,
    required this.jigsawBlockWidget,
    required this.offsetDefault,
  });

  Offset offset;
  Offset offsetDefault;
  JigsawBlockWidget jigsawBlockWidget;
}
