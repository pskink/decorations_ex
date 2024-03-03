part of 'main.dart';

class _StackAndClipExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const bgDecoration = ShapeDecoration(
      color: Color(0xffff0000),
      shape: CircleBorder(
        side: BorderSide(width: 16, color: Color(0xff006600)),
      ),
    );
    const fgDecoration = ShapeDecoration(
      color: Color(0xff006600),
      shape: CircleBorder(
        side: BorderSide(width: 16, color: Colors.orange),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: DecorationStack(
          decorations: [
            bgDecoration,
            ClipDecoration.path(
              decoration: fgDecoration,
              clipBuilder: _clipBuilder,
            ),
          ],
        ),
      ),
    );
  }

  Path _clipBuilder(Rect r) {
    r = Rect.fromCircle(center: r.center, radius: r.shortestSide / 2);
    final control = const Alignment(0.5, 0).withinRect(r);
    return Path()
      ..moveTo(r.topLeft.dx, r.topLeft.dy)
      ..quadraticBezierTo(control.dx, control.dy, r.bottomLeft.dx, r.bottomLeft.dy);
  }
}
