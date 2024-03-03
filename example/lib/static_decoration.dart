part of 'main.dart';

class _StaticDecorationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: DecorationStack(
          decorations: [
            PaintDecoration(
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              paint: Paint()..imageFilter = ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            ),
            CustomDecoration.still(
              painter: _paintZigZag,
              decoration: ShapeDecoration(
                color: Colors.teal.shade900.withOpacity(0.75),
                shape: StarBorder(
                  side: BorderSide(color: Colors.teal.shade900, width: 24),
                  innerRadiusRatio: 0.5,
                  pointRounding: 0.2,
                  valleyRounding: 0.1,
                ),
              ),
              foregroundPainter: _paintForegroundZigZag,
            ),
          ],
        ),
      ),
    );
  }

  _paintZigZag(canvas, rect) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final distance = rect.shortestSide / 2;
    final start = rect.center + Offset.fromDirection(pi * 1.75, distance);
    final end = rect.center + Offset.fromDirection(pi * 0.85, distance);
    paintZigZag(canvas, paint..color = Colors.blue.shade900, start, end, 32, 16);
  }

  _paintForegroundZigZag(canvas, rect) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final distance = rect.shortestSide / 2;
    final start = rect.center + Offset.fromDirection(pi * 1.25, distance);
    final end = rect.center + Offset.fromDirection(pi * 0.15, distance);
    paintZigZag(canvas, paint..color = Colors.red.shade900, start, end, 16, 32);
  }
}
