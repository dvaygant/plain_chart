import 'base_dataset.dart';
import 'dart:math' as math;
import 'dart:ui';

class TimeDataSet extends BaseDataSet{

  final List <double> values;
  double start;
  final double dx;
  double? maxValue;
  double? minValue;
  double minRange;

  ///
  TimeDataSet(this.dx, this.values, this.start, Paint paint, String label,
      {this.maxValue, this.minValue, this.minRange = 0.0}): super(paint, label);

  ///
  @override bool isEmpty() => values.isEmpty;

  ///
  @override Rect getBounds() {
    if (isEmpty()) return Rect.zero;

    var yMin = values.map((e) => e).reduce(math.min);
    var yMax = values.map((e) => e).reduce(math.max);

    if (maxValue != null) yMax= math.max(maxValue!, yMax);
    if (minValue != null) yMin= math.min(minValue!, yMin);

    final double r = math.max(minRange, (values.length - 1) * dx);

    return
      Rect.fromLTRB(start, yMax, start + r, yMin);
  }

  /// Calculation start index for current viewRect
  int _calcStartIndex(double x) =>
    math.max(0, ((x - start)/dx).truncate());

  /// Calculation end index for current viewRect
  int _calcEndIndex(double x) =>
     math.min(values.length - 1, ((x - start)/dx).ceil());

  /// Calculation a new path for drawing
  @override calculatePath(
      Rect viewRect,
      double Function(double) valueXToScreen, valueYToScreen,
      {bool filtered = false}) {

    valuePath.reset();

    if (isEmpty()) return;

    int startIndex = _calcStartIndex(viewRect.left);
    int endIndex = _calcEndIndex(viewRect.right);
    if ( (endIndex - startIndex) < 1) return;

    final startX = start + startIndex * dx;

    var x0 = valueXToScreen(startX);
    final dpx = valueXToScreen(startX + dx) - x0;
    var y0 = valueYToScreen(values[startIndex]);

    valuePath.moveTo(x0, y0);
    var x = x0 + dpx;

    if (filtered) {
      for (int i = startIndex + 1; i < endIndex; i++) {
        var y = valueYToScreen(values[i]);
        if ( (x - x0) > filterDistance || (y0 - y).abs() > filterDistance ) {
          valuePath.lineTo(x, y);
          x0 = x;
          y0 = y;
        }
        x += dpx;
      }
    }
    else {
      for (int i = startIndex + 1; i < endIndex; i++) {
        valuePath.lineTo(x, valueYToScreen(values[i]));
        x += dpx;
      }
    }
    valuePath.lineTo(x, valueYToScreen(values[endIndex]));
  }

  /// add new value to dataset
  void addValue(double val, {int maxLength = 0, bool repaint = true}) {
    values.add(val);
    var len = values.length;
    if (maxLength > 0 && len > maxLength) {
      values.removeRange(0, len - maxLength);
    }
    if (repaint) change();
  }

}