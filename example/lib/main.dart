import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:decorations_ex/decorations_ex.dart';

part 'stack_and_clip.dart';
part 'stack_and_transform.dart';
part 'animated_decoration.dart';
part 'static_decoration.dart';
part 'builder_decoration.dart';

main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (ctx) => Scaffold(body: _StartPage()),
      'stackAndClipExample': (ctx) => Scaffold(
        appBar: AppBar(
          titleTextStyle: Theme.of(ctx).textTheme.labelLarge,
          title: const Text('_StackAndClipExample'),
        ),
        body: _StackAndClipExample(),
      ),
      'stackAndTransformExample': (ctx) => Scaffold(
        appBar: AppBar(
          titleTextStyle: Theme.of(ctx).textTheme.labelLarge,
          title: const Text('_StackAndTransformExample'),
        ),
        body: _StackAndTransformExample(),
      ),
      'animatedDecorationExample': (ctx) => Scaffold(
        appBar: AppBar(
          titleTextStyle: Theme.of(ctx).textTheme.labelLarge,
          title: const Text('_AnimatedDecorationExample'),
        ),
        body: _AnimatedDecorationExample(),
      ),
      'staticDecorationExample': (ctx) => Scaffold(
        appBar: AppBar(
          titleTextStyle: Theme.of(ctx).textTheme.labelLarge,
          title: const Text('_StaticDecorationExample'),
        ),
        body: _StaticDecorationExample(),
      ),
      'builderDecorationExample': (ctx) => Scaffold(
        appBar: AppBar(
          titleTextStyle: Theme.of(ctx).textTheme.labelLarge,
          title: const Text('_BuilderDecorationExample'),
        ),
        body: _BuilderDecorationExample(),
      ),
    },
  ));
}

class _StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('[DecorationStack] with [ClipDecoration.path]'),
          subtitle: const Text('_StackAndClipExample'),
          onTap: () => Navigator.of(context).pushNamed('stackAndClipExample'),
        ),
        ListTile(
          title: const Text('[DecorationStack] with various [TransformDecoration] constructors'),
          subtitle: const Text('_StackAndTransformExample'),
          onTap: () => Navigator.of(context).pushNamed('stackAndTransformExample'),
        ),
        ListTile(
          title: const Text('animated [CustomDecoration] with 3 different callbacks: inline / method / callable class'),
          subtitle: const Text('_AnimatedDecorationExample'),
          onTap: () => Navigator.of(context).pushNamed('animatedDecorationExample'),
        ),
        ListTile(
          title: const Text('static [CustomDecoration] with blurred [PaintDecoration]'),
          subtitle: const Text('_StaticDecorationExample'),
          onTap: () => Navigator.of(context).pushNamed('staticDecorationExample'),
        ),
        ListTile(
          title: const Text('[BuilderDecoration] animating [ShapeDecoration]'),
          subtitle: const Text('_BuilderDecorationExample'),
          onTap: () => Navigator.of(context).pushNamed('builderDecorationExample'),
        ),
      ],
    );
  }
}
