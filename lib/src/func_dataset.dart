import 'base_dataset.dart';
import 'dart:math' as math;
import 'dart:ui';

class FuncDataSet extends BaseDataSet {

  final double Function(double) xyFunction;

  Rect _bounds;

  ///
  FuncDataSet(this.xyFunction, this._bounds, paint, label): super(paint, label);

  ///
  @override bool isEmpty() => false;

  ///
  @override Rect getBounds() => _bounds;

  /// Calculation a new path for drawing
  @override calculatePath(
      Rect viewRect,
      double Function(double) valueXToScreen, valueYToScreen,
      {bool filtered = false}) {

    valuePath.reset();

    double x1 = math.max(_bounds.left, viewRect.left);
    double x2 = math.min(_bounds.right, viewRect.right);
    if (x1 >= x2) return;

    final k = filtered ? filterDistance : 1.0;
    final double dx = k * viewRect.width / (valueXToScreen(viewRect.right) - valueXToScreen(viewRect.left));

    valuePath.moveTo(valueXToScreen(x1), valueYToScreen(xyFunction(x1)));
    double x = x1 + dx;
    while (x<x2) {
      valuePath.lineTo(valueXToScreen(x), valueYToScreen(xyFunction(x)));
      x+=dx;
    }
    valuePath.lineTo(valueXToScreen(x2), valueYToScreen(xyFunction(x2)));
  }

  /// change bounds and repaint chart
  void changeBounds(Rect r, {bool repaint = true}) {
    _bounds = r;
    if (repaint) change();
  }

}