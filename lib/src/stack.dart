import 'package:flutter/painting.dart';

import 'internal.dart';

class DecorationStack extends Decoration with NoPathClipping {

  const DecorationStack({
    required this.decorations,
  });

  final Iterable<Decoration> decorations;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    assert(onChanged != null);
    return BoxPainterHelper(
      painter: (canvas, offset, configuration, bounds) {
        decorations
          .map((d) => d.createBoxPainter(onChanged!))
          .forEach((p) => p.paint(canvas, offset, configuration));
    });
  }
}
