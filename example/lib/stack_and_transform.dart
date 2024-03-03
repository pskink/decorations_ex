part of 'main.dart';

class _StackAndTransformExample extends StatefulWidget {
  @override
  State<_StackAndTransformExample> createState() => _StackAndTransformExampleState();
}

class _StackAndTransformExampleState extends State<_StackAndTransformExample> with TickerProviderStateMixin {
  late final controller = AnimationController(vsync: this, duration: Durations.long1);
  late final alignmentAnimation = AlignmentTween(
    begin: Alignment.centerLeft,
    end: Alignment.bottomRight,
  ).animate(controller);
  late final dashColorAnimation = ColorTween(
    begin: Colors.black.withOpacity(0.1),
    end: Colors.cyan.withOpacity(0.4),
  ).animate(controller);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) {
        return Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => controller.animateBack(0, curve: Curves.ease),
                  icon: const Icon(Icons.arrow_circle_left_outlined),
                ),
                Expanded(
                  child: Slider(
                    onChanged: (v) => controller.value = v,
                    value: controller.value,
                  ),
                ),
                IconButton(
                  onPressed: () => controller.animateTo(1, curve: Curves.ease),
                  icon: const Icon(Icons.arrow_circle_right_outlined),
                ),
                RotationTransition(
                  turns: Animation.fromValueListenable(controller, transformer: (t) => t / 2),
                  child: IconButton(
                    onPressed: () => controller.animateTo(1 - controller.value.roundToDouble(), curve: Curves.ease),
                    icon: const Icon(Icons.arrow_circle_right, color: Colors.pink),
                  ),
                ),
              ],
            ),
            Container(
              color: Colors.greenAccent.shade400,
              child: const Padding(padding: EdgeInsets.all(4), child: Text('these items are drawn in one [DecoratedBox] - this is done by using [DecorationStack] with multiple child [Decoration]s')),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: DecorationStack(
                  decorations: [
                    BoxDecoration(
                      color: Colors.teal.shade800,
                    ),

                    TransformDecoration.sizeAligned(
                      decoration: const BoxDecoration(color: Colors.teal),
                      size: Size.lerp(const Size(50, 50), const Size(100, 200), controller.value)!,
                      alignment: Alignment.centerRight,
                    ),

                    TransformDecoration(
                      decorationTransformEntryBuilder: (r) {
                        final rect = const Alignment(0, 0.5).inscribe(const Size(100, 100), r);
                        return DecorationTransformEntry(
                          bounds: rect,
                          transform: ui.RSTransform.fromComponents(
                            scale: 2,
                            translateX: rect.width / 2,
                            translateY: rect.height / 2,
                            anchorX: rect.width / 2,
                            anchorY: rect.height / 2,
                            rotation: pi / 10 + controller.value * pi * 0.5,
                          ),
                        );
                      },
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        border: Border.all(color: Colors.teal, width: 1),
                        shape: BoxShape.rectangle,
                      ),
                    ),

                    TransformDecoration.padding(
                      padding: EdgeInsets.only(left: 32, top: ui.lerpDouble(50, 150, controller.value)!),
                      fractionalPadding: const EdgeInsets.only(right: 0.25, bottom: 0.5),
                      decoration: DecorationStack(
                        decorations: [
                          BoxDecoration(
                            color: Colors.green.withOpacity(0.75),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          const FlutterLogoDecoration(),
                          TransformDecoration.sizeAligned(
                            decoration: ShapeDecoration(
                              shape: StarBorder(
                                points: 5,
                                innerRadiusRatio: 0.6,
                                rotation: 2 / 5 * 360 * -controller.value,
                              ),
                              shadows: const [BoxShadow(blurRadius: 3, offset: Offset(2, 2))],
                              color: Colors.amber,
                            ),
                            size: const Size.square(32),
                            alignment: Alignment.centerRight,
                          ),
                        ],
                      ),
                    ),

                    TransformDecoration.anchored(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/dash-dev.webp'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.symmetric(horizontal: BorderSide(color: Colors.black26)),
                      ),
                      anchor: Alignment.bottomRight,
                      rectBuilder: (r) => Alignment.topRight.inscribe(const Size(100, 100), r),
                      rotation: pi * 0.4 * -controller.value,
                    ),

                    TransformDecoration.fromRect(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/dash.webp'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(dashColorAnimation.value!, BlendMode.srcATop),
                        ),
                        // color: Colors.deepPurple,
                      ),
                      rectBuilder: (r) => alignmentAnimation.value.inscribe(const Size(150, 150), r)
                    ),
                  ],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        );
      }
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
