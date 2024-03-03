import 'dart:ui';

import 'package:flutter/painting.dart';

import 'custom.dart';
import 'internal.dart';

/// [Decoration] whose [builder] callback creates a real [Decoration].
///
/// When used by widgets that animate their decoration (like [AnimatedContainer]),
/// an interpolated [phase] (between the old and new value) is passed to
/// [builder] callback (also you can do a custom painting with [painter] and
/// [foregroundPainter] callbacks):
///
/// ```dart
/// int idx = 0;
///
/// @override
/// Widget build(BuildContext context) {
///   return AnimatedContainer(
///     duration: const Duration(milliseconds: 500),
///     clipBehavior: Clip.antiAlias,
///     decoration: BuilderDecoration(
///       builder: _phasedDecorationBuilder,
///       foregroundPainter: _someForegroundPainter,
///       phase: idx.toDouble(), // 'phase' is either 0 or 1
///     ),
///     child: Material(
///       type: MaterialType.transparency,
///       child: InkWell(
///         highlightColor: Colors.transparent,
///         splashColor: Colors.deepOrange,
///         onTap: () => setState(() => idx = idx ^ 1),
///         child: const Center(child: Text('press me', textScaleFactor: 2)),
///       ),
///     ),
///   );
/// }
///
/// Decoration _phasedDecorationBuilder(double phase) {
///   return BoxDecoration(
///     ... use 'phase' to build decoration
///   );
/// }
///
/// _someForegroundPainter(Canvas canvas, Rect bounds, double phase) {
///   ... use 'bounds' and 'phase' to draw something
/// }
///```
class BuilderDecoration extends Decoration {

  BuilderDecoration({
    this.painter,
    this.builder,
    this.foregroundPainter,
    this.phase = 0,
  }) : _holder = _DecorationHolder();

  final OnPaintFrame<double>? painter;
  final Decoration Function(double)? builder;
  final OnPaintFrame<double>? foregroundPainter;
  final double phase;
  final _DecorationHolder _holder;

  @override
  Decoration? lerpFrom(Decoration? a, double t) {
    // debugPrint('lerpFrom $a $t');
    if (a is BuilderDecoration) {
      return BuilderDecoration(
        painter: painter,
        builder: builder,
        foregroundPainter: foregroundPainter,
        phase: lerpDouble(a.phase, phase, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    assert(onChanged != null);
    _holder.decoration = builder?.call(phase);
    final boxPainter = _holder.decoration?.createBoxPainter(onChanged!);

    return BoxPainterHelper(
      painter: (canvas, offset, configuration, bounds) {
        painter?.call(canvas, bounds, phase);
        boxPainter?.paint(canvas, offset, configuration);
        foregroundPainter?.call(canvas, bounds, phase);
      }
    );
  }

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) {
    return _holder.decoration?.getClipPath(rect, textDirection) ?? (Path()..addRect(rect));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BuilderDecoration &&
      other.phase == phase;
  }

  @override
  int get hashCode => phase.hashCode;
}

class _DecorationHolder {
  Decoration? decoration;
}
