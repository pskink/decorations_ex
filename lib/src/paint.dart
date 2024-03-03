import 'package:flutter/painting.dart';

import 'internal.dart';

/// [Decoration] that applies a given [paint] on child [decoration].
/// Because it uses [Canvas.saveLayer] which is relatively expensive, you should
/// use [RepaintBoundary] or similar widgets to avoid unnecessary painting.
class PaintDecoration extends Decoration with NoPathClipping {

  const PaintDecoration({
    required this.decoration,
    required this.paint,
  });

  final Decoration decoration;
  final Paint paint;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    assert(onChanged != null);
    final painter = decoration.createBoxPainter(onChanged!);
    return BoxPainterHelper(
      painter: (canvas, offset, configuration, bounds) {
        canvas.saveLayer(null, paint);
        painter.paint(canvas, offset, configuration);
        canvas.restore();
      }
    );
  }
}
