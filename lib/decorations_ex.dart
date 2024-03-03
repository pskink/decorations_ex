export 'src/stack.dart' show
  DecorationStack;
export 'src/transform.dart' show
  TransformDecoration,
  DecorationTransformEntry,
  DecorationTransformEntryBuilder,
  RectBuilder;
export 'src/clip.dart' show
  ClipDecoration,
  ClipBuilder;
export 'src/custom.dart' show
  CustomDecoration,
  DecorationBuilderMode,
  DecorationBuilder,
  OnPaint,
  OnPaintFrame;
export 'src/paint.dart' show
  PaintDecoration;
export 'src/builder.dart' show
  BuilderDecoration;

/*
  provides:
    1. DecorationStack
    2. TransformDecoration
    3. TransformDecoration.padding
    4. TransformDecoration.fromRect
    5. TransformDecoration.sizeAligned
    6. TransformDecoration.anchored
    7. ClipDecoration.path
    8. ClipDecoration.rect
    9. ClipDecoration.rrect
    10. CustomDecoration.still
    11. CustomDecoration.animated
    12. PaintDecoration
    13. BuilderDecoration

  TODO: every above decoration should check if
    * Path getClipPath(Rect rect, TextDirection textDirection)
    * EdgeInsetsGeometry? get padding;
    * bool hitTest(Size size, Offset position, {TextDirection? textDirection})
  should be implemented
*/
