import 'dart:ui';
import 'dart:math' as math;

abstract class BaseDataSet {

  final double filterDistance = 3.0;
  final Paint paint;
  final String label;
  final Path valuePath = Path();
  VoidCallback? onChange;

  ///
  BaseDataSet(this.paint, this.label);

  ///
  bool isEmpty();

  ///
  Rect getBounds();

  /// Calculation a new path for drawing
  void calculatePath(Rect viewRect,
      double Function(double) valueXToScreen, valueYToScreen,
      {bool filtered = false});

  ///
  Rect getExpandBounds(Rect r) {
    if (isEmpty()) return r;
    var q = getBounds();

    return Rect.fromLTRB(
        math.min(r.left, q.left), math.max(r.top, q.top),
        math.max(r.right, q.right), math.min(r.bottom, q.bottom));
  }

  /// repaint chart
  void change() => onChange?.call();

  /// draw path to canvas
  void drawPath(Canvas canvas) => canvas.drawPath(valuePath, paint);
}