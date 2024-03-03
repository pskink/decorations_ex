# decorations_ex

This package provides a collection of custom classes that extend Flutter's built-in `Decoration` class. These decorations can be used to enhance the visual appearance of various widgets in your Flutter application, including `Container`, `AnimatedContainer`, `DecoratedBox` and any other widget that accepts a `Decoration` property.

## Available Decorations

* `DecorationStack` - paints a stack of multiple child `Decoration`s

* `TransformDecoration` - used for transforming a child `Decoration` with `RSTransform`, it also contains some helper constructors for common cases like padded, fixed, aligned decorations
  * `TransformDecoration`
  * `TransformDecoration.padding`
  * `TransformDecoration.fromRect`
  * `TransformDecoration.sizeAligned`
  * `TransformDecoration.anchored`

* `ClipDecoration` - clips a child `Decoration`
  * `ClipDecoration.path`
  * `ClipDecoration.rect`
  * `ClipDecoration.rrect`

* `CustomDecoration` - used for static / dynamic painting a custom stuff with `Canvas` API
  * `CustomDecoration.still`
  * `CustomDecoration.animated`

* `PaintDecoration` - applies a `Paint` on child `Decoration`

* `BuilderDecoration` - a `Decoration` that builds a real `Decoration`, very helpful when used with `AnimatedContainer` where you can easily create a live, morphing decoration

## Example

Check [example](example) folder for some code samples
