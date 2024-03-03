
import 'package:flutter/painting.dart';

import 'internal.dart';

typedef ClipBuilder = Path Function(Rect bounds);

class ClipDecoration extends Decoration with NoPathClipping {

  const ClipDecoration.path({
    required this.decoration,
    required this.clipBuilder,
  });

  ClipDecoration.rect({
    required Decoration decoration,
    required Rect Function(Rect) clipBuilder,
  }) : this.path(
    decoration: decoration,
    clipBuilder: (r) => Path()..addRect(clipBuilder(r)),
  );

  ClipDecoration.rrect({
    required Decoration decoration,
    required RRect Function(Rect) clipBuilder,
  }) : this.path(
    decoration: decoration,
    clipBuilder: (r) => Path()..addRRect(clipBuilder(r)),
  );

  final Decoration decoration;
  final ClipBuilder clipBuilder;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    assert(onChanged != null);
    final painter = decoration.createBoxPainter(onChanged!);
    return BoxPainterHelper(
      painter: (canvas, offset, configuration, bounds) {
        canvas.save();
        final clipPath = clipBuilder(bounds);
        canvas.clipPath(clipPath);
        painter.paint(canvas, offset, configuration);
        canvas.restore();
      }
    );
  }
}
