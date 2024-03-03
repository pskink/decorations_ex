import 'package:flutter/rendering.dart';

import 'internal.dart';

class DecorationTransformEntry {
  final Rect? bounds;
  final RSTransform? transform;

  DecorationTransformEntry({
    this.bounds,
    this.transform,
  });
}

typedef DecorationTransformEntryBuilder = DecorationTransformEntry Function(Rect bounds);
typedef RectBuilder = Rect? Function(Rect bounds);

class TransformDecoration extends Decoration with NoPathClipping {

  const TransformDecoration({
    required this.decoration,
    required this.decorationTransformEntryBuilder,
  });

  TransformDecoration.padding({
    required Decoration decoration,
    EdgeInsets padding = EdgeInsets.zero,
    EdgeInsets fractionalPadding = EdgeInsets.zero,
  }) : this(
    decoration: decoration,
    decorationTransformEntryBuilder: _paddingBuilder(
      padding: padding,
      fractionalPadding: fractionalPadding,
    ),
  );

  TransformDecoration.fromRect({
    required Decoration decoration,
    required RectBuilder rectBuilder,
  }) : this(
    decoration: decoration,
    decorationTransformEntryBuilder: (Rect bounds) => DecorationTransformEntry(bounds: rectBuilder(bounds)),
  );

  TransformDecoration.sizeAligned({
    required Decoration decoration,
    required Size size,
    required Alignment alignment,
  }) : this(
    decoration: decoration,
    decorationTransformEntryBuilder: (Rect bounds) => DecorationTransformEntry(bounds: alignment.inscribe(size, bounds)),
  );

  TransformDecoration.anchored({
    required Decoration decoration,
    required Alignment anchor,
    required RectBuilder rectBuilder,
    double rotation = 0,
    double scale = 1,
  }) : this(
    decoration: decoration,
    decorationTransformEntryBuilder: _anchoredBuilder(
      rotation: rotation,
      scale: scale,
      anchor: anchor,
      rectBuilder: rectBuilder,
    ),
  );

  final Decoration decoration;
  final DecorationTransformEntryBuilder decorationTransformEntryBuilder;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    assert(onChanged != null);
    final childPainter = decoration.createBoxPainter(onChanged!);
    return BoxPainterHelper(
      painter: (canvas, offset, configuration, bounds) {
        _paint(canvas, offset, configuration, bounds, childPainter);
      }
    );
  }

  _paint(Canvas canvas, Offset offset, ImageConfiguration configuration, Rect bounds, BoxPainter childPainter) {
    final decorationTransformEntry = decorationTransformEntryBuilder(bounds);
    if (decorationTransformEntry.bounds != null) {
      bounds = decorationTransformEntry.bounds!;
    }
    if (decorationTransformEntry.transform != null) {
      final t = decorationTransformEntry.transform!;
      final c = t.scos;
      final s = t.ssin;
      // TODO should we add bounds.left/bounds.top to dx/dy translations?
      final dx = t.tx + bounds.left;
      final dy = t.ty + bounds.top;
      final matrix = Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
      canvas.save();
      canvas.transform(matrix.storage);
      childPainter.paint(canvas, Offset.zero, configuration.copyWith(size: bounds.size));
      canvas.restore();
    } else {
      childPainter.paint(canvas, bounds.topLeft, configuration.copyWith(size: bounds.size));
    }
  }

  static DecorationTransformEntryBuilder _paddingBuilder({
    required EdgeInsets padding,
    required EdgeInsets fractionalPadding,
  }) {
    assert(() {
      StringBuffer? buffer;
      if (fractionalPadding.left > 1) {
        buffer ??= StringBuffer()
          ..writeln('  - left padding: ${fractionalPadding.left}');
      }
      if (fractionalPadding.top > 1) {
        buffer ??= StringBuffer()
          ..writeln('  - top padding: ${fractionalPadding.top}');
      }
      if (fractionalPadding.right > 1) {
        buffer ??= StringBuffer()
          ..writeln('  - right padding: ${fractionalPadding.right}');
      }
      if (fractionalPadding.bottom > 1) {
        buffer ??= StringBuffer()
          ..writeln('  - bottom padding: ${fractionalPadding.bottom}');
      }
      if (buffer != null) {
        debugPrint('warning: the fractional padding should be defined in range [0..1]\n'
                   'wrong pads:\n'
                   '${buffer.toString()}');
      }
      return true;
    }());
    return (Rect bounds) {
      final effectivePadding = EdgeInsets.fromLTRB(
        padding.left + fractionalPadding.left * bounds.width,
        padding.top + fractionalPadding.top * bounds.height,
        padding.right + fractionalPadding.right * bounds.width,
        padding.bottom + fractionalPadding.bottom * bounds.height
      );
      return DecorationTransformEntry(
        bounds: effectivePadding.deflateRect(bounds),
      );
    };
  }

  static DecorationTransformEntryBuilder _anchoredBuilder({
    required double rotation,
    required double scale,
    required Alignment anchor,
    required RectBuilder rectBuilder,
  }) {
    return (Rect bounds) {
      final effectiveBounds = rectBuilder(bounds) ?? bounds;
      final anchorPoint = anchor.alongSize(effectiveBounds.size);
      return DecorationTransformEntry(
        bounds: effectiveBounds,
        transform: RSTransform.fromComponents(
          rotation: rotation,
          scale: scale,
          anchorX: anchorPoint.dx,
          anchorY: anchorPoint.dy,
          translateX: anchorPoint.dx,
          translateY: anchorPoint.dy,
        )
      );
    };
  }
}
