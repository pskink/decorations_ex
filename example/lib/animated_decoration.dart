part of 'main.dart';

class _AnimatedDecorationExample extends StatefulWidget {
  @override
  State<_AnimatedDecorationExample> createState() => _AnimatedDecorationExampleState();
}

typedef _DemoRecord = (Color?, Color?, double?, Alignment?);

class _AnimatedDecorationExampleState extends State<_AnimatedDecorationExample> with TickerProviderStateMixin {
  late List<AnimationController> controllers;
  late Animation<_DemoRecord> demoAnimation;
  final _oldTvSetEffect = _OldTvSetEffect(
    uri: Uri.parse('https://picsum.photos/300/200'),
    color: Colors.teal,
    radius: 32,
  );
  final fadePaintMode = Random().nextBool();

  @override
  void initState() {
    super.initState();

    final ms = [600, 300, 300];
    controllers = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms[i]),
    ));
    demoAnimation = controllers[2].drive(_DemoTween(
      begin: (Colors.teal, Colors.black54, 150, Alignment.center),
      end: (Colors.teal.shade900, Colors.white60, 50, Alignment.bottomRight),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // timeDilation = 10;
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  // passing Animation<_DemoRecord> gives _DemoRecord in paintCallback and decorationBuilder
                  decoration: CustomDecoration.animated(
                    valueListenable: demoAnimation,
                    painter: (Canvas canvas, Rect bounds, _DemoRecord record) {
                      canvas.drawRect(bounds, Paint()..color = record.$1!);
                    },
                    decorationBuilder: (Rect bounds, _DemoRecord record) => TransformDecoration.sizeAligned(
                      decoration: FlutterLogoDecoration(
                        textColor: record.$2!,
                        style: FlutterLogoStyle.stacked,
                      ),
                      size: Size.square(record.$3!),
                      alignment: record.$4!,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  // passing Animation<double> gives double in paintCallback
                  decoration: CustomDecoration.animated(
                    valueListenable: controllers[1],
                    painter: _paintBackground,
                    decorationBuilder: (Rect bounds, double t) => TransformDecoration.padding(
                      padding: const EdgeInsets.all(16),
                      decoration: PaintDecoration(
                        paint: _paint(fadePaintMode, t),
                        decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage('images/dash.webp')),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  // passing Animation<double> gives double in paintCallback
                  decoration: CustomDecoration.animated(
                    valueListenable: controllers[0],
                    painter: _oldTvSetEffect,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Future.forEach<AnimationController>(controllers, (c) => c.value < 0.5? c.forward() : c.reverse());
        },
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.animation),
        label: const Text('animate'),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (var c in controllers) {
      c.dispose();
    }
  }

  void _paintBackground(Canvas canvas, Rect bounds, double t) {
    const startColor = Colors.blueGrey;
    const endColor = Colors.deepPurple;
    final paint = Paint();
    final innerRect = bounds.deflate(48 * sin(pi * t));
    canvas
      ..drawRect(bounds, paint..color = Color.lerp(startColor, endColor, t)!)
      ..drawRect(innerRect, paint..color = Color.lerp(startColor, endColor, 1 - t)!);
  }

  _paint(bool fade, double t) {
    return switch (fade) {
      true => Paint()..color = Colors.black.withOpacity(Curves.ease.transform(t)),
      false => Paint()..imageFilter = ui.ImageFilter.dilate(radiusX: 2 * t, radiusY: 2 * t),
    };
  }
}

class _DemoTween extends Tween<_DemoRecord> {
  _DemoTween({super.begin, super.end});

  @override
  _DemoRecord lerp(double t) {
    return (
      Color.lerp(begin?.$1, end?.$1, t),
      Color.lerp(begin?.$2, end?.$2, t),
      ui.lerpDouble(begin?.$3, end?.$3, t),
      Alignment.lerp(begin?.$4, end?.$4, t),
    );
  }
}

class _OldTvSetEffect {
  _OldTvSetEffect({
    required Uri uri,
    required this.color,
    required this.radius,
  }) {
    _getImage(uri).then(_setImage);
  }

  final Color color;
  final double radius;
  Animatable<Rect?>? _rects;
  ui.Image? image;

  void call(Canvas canvas, Rect bounds, double t) {
    canvas.drawRect(bounds, Paint()..color = Colors.black87);

    _rects ??= _makeRectsTween(bounds);
    final rect = _rects!.transform(t)!;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius * (1 - t)));
    canvas
      ..save()
      ..clipRRect(rrect);
    if (image != null) {
      paintImage(canvas: canvas, rect: rect, image: image!, fit: BoxFit.cover);
    } else {
      canvas.drawPaint(Paint()..color = Color.lerp(Colors.white, color, t)!);
    }
    canvas.restore();
  }

  Animatable<Rect?> _makeRectsTween(Rect bounds) {
    final rects = [
      Rect.fromCircle(center: bounds.center, radius: 0),
      Rect.fromCircle(center: bounds.center, radius: radius),
      Rect.fromLTRB(bounds.left, bounds.center.dy - 2, bounds.right, bounds.center.dy + 2),
      bounds,
    ];
    return TweenSequence<Rect?>([
      TweenSequenceItem(tween: RectTween(begin: rects[0], end: rects[1]), weight: 8.0),
      TweenSequenceItem(tween: RectTween(begin: rects[1], end: rects[2]), weight: 4.0),
      TweenSequenceItem(tween: RectTween(begin: rects[2], end: rects[3]), weight: 1.0),
    ]).chain(CurveTween(curve: Curves.ease));
  }

  FutureOr _setImage(ui.Image image) {
    debugPrint('decoded image: $image');
    this.image = image;
  }

  Future<ui.Image> _getImage(Uri uri) async {
    late final ByteData data;
    try {
      data = await NetworkAssetBundle(uri).load(uri.path);
    } catch (error) {
      debugPrint('error ocurred: [$error], switching to fallback...');
      data = await rootBundle.load('images/pm5544.webp');
    }
    return decodeImageFromList(data.buffer.asUint8List());
  }
}
