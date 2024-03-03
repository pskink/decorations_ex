import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'internal.dart';

typedef OnPaintFrame<T> = void Function(Canvas canvas, Rect bounds, T value);
typedef OnPaint = void Function(Canvas canvas, Rect bounds);
typedef DecorationBuilder<T> = Decoration Function(Rect bounds, T value);

enum DecorationBuilderMode {
  /// Builder is called once
  static,

  /// Builder is called on each frame of animation
  dynamic,
}

abstract class CustomDecoration<T> extends Decoration with NoPathClipping {
  const CustomDecoration();

  /// Static [Decoration]. Very boring, but still (pun intended) you can make
  /// some custom drawing with [painter] / [foregroundPainter] callbacks.
  const factory CustomDecoration.still({
    OnPaint? painter,
    Decoration? decoration,
    OnPaint? foregroundPainter,
  }) = _CustomStillDecoration<T>;

  /// [Decoration] that repaints itself when [valueListenable] notifies its listeners.
  /// Typically [Animation] or [ValueNotifier] can be used as [valueListenable] but
  /// [CustomDecoration.animated] accepts any [ValueListenable]
  ///
  /// The sequence of drawing:
  /// 1. [painter] callback
  /// 2. [Decoration] built by [decorationBuilder]
  /// 3. [foregroundPainter] callback
  ///
  const factory CustomDecoration.animated({
    required ValueListenable<T> valueListenable,
    OnPaintFrame<T>? painter,
    DecorationBuilder<T>? decorationBuilder,
    OnPaintFrame<T>? foregroundPainter,
    DecorationBuilderMode decorationBuilderMode,
  }) = _CustomAnimatedDecoration<T>;
}

class _CustomStillDecoration<T> extends CustomDecoration<T> {
  const _CustomStillDecoration({
    this.painter,
    this.decoration,
    this.foregroundPainter,
  });

  /// Draws a custom decoration (background)
  final OnPaint? painter;

  /// [Decoration] to be drawn after [painter]
  final Decoration? decoration;

  /// Draws a custom decoration (foreground)
  final OnPaint? foregroundPainter;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    assert(onChanged != null);
    final decorationPainter = decoration?.createBoxPainter(onChanged!);
    return BoxPainterHelper(
      painter: (canvas, offset, configuration, bounds) {
        painter?.call(canvas, bounds);
        decorationPainter?.paint(canvas, offset, configuration);
        foregroundPainter?.call(canvas, bounds);
      },
    );
  }
}

class _CustomAnimatedDecoration<T> extends CustomDecoration<T> {
  const _CustomAnimatedDecoration({
    required this.valueListenable,
    this.painter,
    this.decorationBuilder,
    this.foregroundPainter,
    this.decorationBuilderMode = DecorationBuilderMode.dynamic,
  });

  /// [ValueListenable] that notifies [painter], [decorationBuilder]  and
  /// [foregroundPainter]
  ///
  /// Typically [Animation] or [ValueNotifier]
  final ValueListenable<T> valueListenable;

  /// Draws a single frame of animation (background)
  final OnPaintFrame<T>? painter;

  /// Returns [Decoration] to be drawn after [painter]
  final DecorationBuilder<T>? decorationBuilder;

  /// Draws a single frame of animation (foreground)
  final OnPaintFrame<T>? foregroundPainter;

  /// Whether [decorationBuilder] is called on each frame or only once
  final DecorationBuilderMode decorationBuilderMode;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    assert(onChanged != null);
    return _CustomAnimatedDecorationPainter<T>(
      valueListenable: valueListenable,
      painter: painter,
      decorationBuilder: decorationBuilder,
      foregroundPainter: foregroundPainter,
      decorationBuilderMode: decorationBuilderMode,
      onChanged: onChanged,
    );
  }
}

class _CustomAnimatedDecorationPainter<T> extends BoxPainter {

  _CustomAnimatedDecorationPainter({
    required this.valueListenable,
    required this.painter,
    required this.decorationBuilder,
    required this.foregroundPainter,
    required this.decorationBuilderMode,
    required VoidCallback? onChanged,
  }) : super(onChanged) {
    valueListenable.addListener(_onChanged);
  }

  final ValueListenable<T> valueListenable;
  final OnPaintFrame<T>? painter;
  final DecorationBuilder<T>? decorationBuilder;
  final OnPaintFrame<T>? foregroundPainter;
  final DecorationBuilderMode decorationBuilderMode;
  BoxPainter? decorationPainter;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final bounds = offset & configuration.size!;
    final value = valueListenable.value;

    painter?.call(canvas, bounds, value);

    if (decorationBuilder != null) {
      if (decorationBuilderMode == DecorationBuilderMode.dynamic) {
        decorationPainter = null;
      }

      decorationPainter ??= decorationBuilder!(bounds, value)
        .createBoxPainter(_onChanged);
      decorationPainter!.paint(canvas, offset, configuration);
    }

    foregroundPainter?.call(canvas, bounds, value);
  }

  void _onChanged() {
    onChanged?.call();
  }

  @override
  void dispose() {
    super.dispose();
    valueListenable.removeListener(_onChanged);
  }
}
