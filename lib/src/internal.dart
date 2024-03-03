

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

mixin NoPathClipping on Decoration {
  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    debugPrint('getClipPath $runtimeType');
    return Path()..addRect(rect);
  }
}

class BoxPainterHelper extends BoxPainter {
  BoxPainterHelper({
    required this.painter,
  });

  void Function(Canvas, Offset, ImageConfiguration, Rect) painter;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    painter(canvas, offset, configuration, offset & configuration.size!);
  }
}

