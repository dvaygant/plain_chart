import 'package:flutter/material.dart';
import 'base_dataset.dart';
import 'dart:math' as math;

class XYDataSet extends BaseDataSet{

  final List <Offset> points;
  final bool isFigure;

  Rect? minBounds;

  XYDataSet(this.points, paint, label,
      {this.minBounds, this.isFigure = false}):
        super(paint, label);

  ///
  @override bool isEmpty() => points.isEmpty;

  ///
  @override Rect getBounds() {
    if (isEmpty()) return Rect.zero;

    double minX = points.map((pt) => pt.dx).reduce(math.min);
    double maxX = points.map((pt) => pt.dx).reduce(math.max);
    double minY = points.map((pt) => pt.dy).reduce(math.min);
    double maxY = points.map((pt) => pt.dy).reduce(math.max);

    if (minBounds != null) {
      minX = math.min(minX, minBounds!.left);
      maxX = math.max(maxX, minBounds!.right);
      minY = math.min(minY, minBounds!.bottom);
      maxY = math.max(maxY, minBounds!.top);
    }
    return
      Rect.fromLTRB(minX, maxY, maxX, minY);
  }


  /// Calculation start index for current viewRect
  int _calcStartIndex(double xLeft) {

    if (isFigure) return 0;

    int left = 1;
    int right = points.length - 1;
    while (points[left].dx < xLeft && (right - left) > 3) {
      int mid = (left + right) ~/ 2;
      if (points[mid].dx > xLeft) {
        right = mid;
        left ++;
      }
      else {
        left = mid;
        right --;
      }
    }
    return left - 1;
  }

  /// Calculation end index for current viewRect
  int _calcEndIndex(double xRight, int left) {

    if (isFigure) return points.length - 1;

    int right = points.length - 2;
    while (points[right].dx > xRight && (right - left) > 3) {
      int mid = (left + right) ~/ 2;
      if (points[mid].dx < xRight) {
        left = mid;
        right --;
      }
      else {
        right = mid;
        left ++;
      }
    }
    return right + 1;
  }

  /// Calculation a new path for drawing
  @override calculatePath(Rect viewRect,
      double Function(double) valueXToScreen, valueYToScreen,
      {bool filtered = false}) {

    valuePath.reset();

    if (points.isEmpty) return;

    final int startIndex = _calcStartIndex(viewRect.left);
    final int endIndex =  _calcEndIndex(viewRect.right, startIndex);
    if ( (endIndex - startIndex) < 1) return;

    double x0 = valueXToScreen(points[startIndex].dx);
    double y0 = valueYToScreen(points[startIndex].dy);
    valuePath.moveTo(x0, y0);

    if (filtered) {
      for (int i = startIndex + 1; i < endIndex; i++) {
        double x = valueXToScreen(points[i].dx);
        double y = valueYToScreen(points[i].dy);
        if ( (x - x0) > filterDistance || (y - y0).abs() > filterDistance ) {
          valuePath.lineTo(x, y);
          x0 = x;
          y0 = y;
        }
      }
    } // if filtered
    else {
      for (int i = startIndex + 1; i < endIndex; i++) {
        valuePath.lineTo(valueXToScreen(points[i].dx), valueYToScreen(points[i].dy));
      }
    }
    valuePath.lineTo(valueXToScreen(points[endIndex].dx), valueYToScreen(points[endIndex].dy));
  }

  ///
  void addValue(Offset pt, {int maxLength = 0, bool repaint = true}) {
    points.add(pt);
    final len = points.length;
    if (maxLength > 0 && len > maxLength) {
      points.removeRange(0, len - maxLength);
    }
    if (repaint) change();
  }

}