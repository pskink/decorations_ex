part of 'main.dart';

class _BuilderDecorationExample extends StatefulWidget {
  @override
  State<_BuilderDecorationExample> createState() => _BuilderDecorationExampleState();
}

class _BuilderDecorationExampleState extends State<_BuilderDecorationExample> {
  double idx = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      clipBehavior: Clip.antiAlias,
      decoration: BuilderDecoration(
        builder: _phasedDecorationBuilder,
        phase: idx,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.black26,
          onTap: () => setState(() => idx++),
          child: const Center(child: Text('press me', textScaleFactor: 2)),
        ),
      ),
    );
  }

  final colors = [
    Colors.indigo, Colors.green, Colors.teal,
    Colors.orange, Colors.grey, Colors.red,
  ];
  Decoration _phasedDecorationBuilder(double phase) {
    final phase1 = 0.5 + cos(phase * pi) / 2;
    final idx0 = phase.floor() % colors.length;
    final idx1 = (idx0 + 1) % colors.length;
    final color = Color.lerp(colors[idx0], colors[idx1], phase % 1)!;
    return ShapeDecoration(
      shadows: [BoxShadow(color: Colors.black.withOpacity(phase1), blurRadius: 6, offset: const Offset(6, 6))],
      color: color.withOpacity(0.6),
      shape: StarBorder(
        points: 6,
        rotation: 360 * phase / 6,
        side: BorderSide(color: color, width: 16),
        innerRadiusRatio: 0.6,
        pointRounding: phase1 * 0.4,
        valleyRounding: (1 - phase1) * 0.2,
      ),
    );
  }
}
