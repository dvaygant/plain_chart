import 'package:flutter/widgets.dart';
import 'chart_controller.dart';
import 'dart:math' as math;

class ChartPainter extends CustomPainter {

  ChartPainter(this._controller)
      : super(repaint: _controller.notifier);

  final ChartController _controller;

  /// Repaint
  @override
  void paint(Canvas canvas, Size size) {

    if (!_controller.ready()) {
      _drawBlankScreen(canvas, size);
      return;
    }
    _initCalc(size);
    _controller.beforeDraw(canvas);
    _drawAxis(canvas, size);
    _drawDataSets(canvas);
    _drawExtras(canvas);
    _controller.afterDraw(canvas);
  }

  /// calculation size
  void _initCalc(Size size) {
    _controller.setScreenRect(size);
  }

  /// draw axis
  _drawAxis(Canvas canvas, Size size) {
    if (_controller.showAxis) {
      _drawXAxis(canvas, size);
      _drawYAxis(canvas, size);
    }
  }

  /// draw X-axis
  _drawXAxis(Canvas canvas, Size size) {

    final double fontSize = _controller.axisTextStyle.fontSize!;
    final tickSize = (fontSize/3).roundToDouble();

    canvas.drawLine(
        _controller.screenRect.bottomLeft.translate(-0.5, 1.0),
        _controller.screenRect.bottomRight.translate(0.0, 1.0),
        _controller.axisPaint);

    // draw axis title
    final textPainter = TextPainter(
      text: TextSpan(
          text: _controller.axisXTitle,
          style: _controller.axisTextStyle),
      textDirection: TextDirection.ltr);
    textPainter.layout();

    final w = textPainter.width + 2.0;
    final h = (size.height - _controller.screenRect.bottom - textPainter.height)/2;

    final offset = _controller.screenRect.bottomRight.translate(-w, h);
    textPainter.paint(canvas, offset);

    double xx = 0.0;
    double bestInterval = _controller.calculateXBestInterval(fontSize);
    double aStart = bestInterval * (_controller.viewRect.left / bestInterval).round();

    for (double x2 = aStart; x2 < _controller.viewRect.right; x2 += bestInterval) {

      xx = _controller.dataToScrX(x2);

      // Draw x-axis label
      if (xx < (_controller.screenRect.right - 20.0 - w) && xx > (_controller.screenRect.left + 12.0 )) {
        TextPainter(
            textAlign: TextAlign.center,
            ellipsis: '.',
            text: TextSpan(
                text: _controller.getXTickCaption(x2),
                style: _controller.axisTextStyle,
            ),
            textDirection: TextDirection.ltr)
          ..layout(minWidth: 100, maxWidth: 100)
          ..paint(canvas, Offset(xx - 50.0, _controller.screenRect.bottom + tickSize + 1.5));

        // draw X-axis tick
        canvas.drawLine(
            Offset(xx, _controller.screenRect.bottom + 1.5),
            Offset(xx, _controller.screenRect.bottom + tickSize + 1.5),
            _controller.axisPaint);
      }

      // draw X-axis grid line
      if ((xx - _controller.screenRect.left) > 4 && (_controller.screenRect.right - xx) > 4 ) {
        canvas.drawLine(
            Offset(xx, _controller.screenRect.bottom),
            Offset(xx, _controller.screenRect.top),
            _controller.gridPaint);
      }
    }
  }

  /// draw Y-axis
  _drawYAxis(Canvas canvas, Size size) {

    final double fontSize = _controller.axisTextStyle.fontSize!;
    final tickSize = (fontSize/3).roundToDouble();

    canvas.drawLine(
        _controller.screenRect.topLeft.translate(-0.5, 0.0),
        _controller.screenRect.bottomLeft.translate(-0.5, 1.0),
        _controller.axisPaint);

    // draw axis title
    TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: _controller.axisYTitle,
            style: _controller.axisTextStyle),
        textDirection: TextDirection.ltr);
    textPainter.layout();

    var w = textPainter.width + 2.0;
    var h = textPainter.height + 2.0;

    if (w < _controller.screenRect.left) {
      textPainter.paint(canvas, Offset((_controller.screenRect.left - w)/2 + 1.0, 2.0));
    }
    else {
      canvas.save();
      canvas.rotate(-math.pi/2);
      textPainter.paint(canvas, Offset(-w, (_controller.screenRect.left - h)/2 + 1.0));
      canvas.restore();
      h = w;
    }

    var bestInterval = _controller.calculateYBestInterval(fontSize);

    var aStart = bestInterval * (_controller.viewRect.bottom / bestInterval).round();

    for (double y2= aStart; y2 < _controller.viewRect.top; y2+= bestInterval) {

      double yy = _controller.dataToScrY(y2);
      if (yy < _controller.screenRect.bottom - 4 && yy > _controller.screenRect.top + 2) {
        if ( yy< _controller.screenRect.bottom - fontSize   &&   yy > _controller.screenRect.top + h + 6) {

          // Draw Y-axis label
          textPainter = TextPainter(
              text: TextSpan(
                  text: _controller.getYTickCaption(y2),
                  style: _controller.axisTextStyle,
              ),
              textDirection: TextDirection.ltr);
          textPainter.layout();

          w = textPainter.width + 2.0;

          textPainter.paint(canvas, Offset(_controller.screenRect.left - tickSize - w, yy - 0.5 - fontSize / 2.0));

          // draw Y-axis tick
          canvas.drawLine(
              Offset(_controller.screenRect.left - 1.0, yy),
              Offset(_controller.screenRect.left - 1.0 - tickSize, yy),
              _controller.axisPaint);
        }

        // draw Y-axis grid line
        canvas.drawLine(
            Offset(_controller.screenRect.left, yy),
            Offset(_controller.screenRect.right, yy),
            _controller.gridPaint);
      }
    }
  }

  /// draw path for each dataset
  void _drawDataSets(Canvas canvas) {
    canvas.save();
    canvas.clipRect(_controller.screenRect);
    for (var data in _controller.dataSetList) {
      data.drawPath(canvas);
    }
    canvas.restore();
  }

  ///
  void _drawExtras(Canvas canvas) {

    if (_controller.showDataSetLegend) {
      double y = 2.0;
      for (var data in _controller.dataSetList) {
        final TextStyle ts = TextStyle(
            color: data.paint.color, fontSize: _controller.legendTextSize);
        final textPainter = TextPainter(
            text: TextSpan(text: data.label, style: ts),
            textDirection: TextDirection.ltr);
        textPainter.layout();

        final offset = Offset(_controller.screenRect.left + 8.0, y);
        textPainter.paint(canvas, offset);
        y += _controller.titleTextStyle.fontSize!;
      }
    }
  }

  ///
  void _drawBlankScreen(Canvas canvas, Size size) {
      final textPainter = TextPainter(
          text: TextSpan(
              text: _controller.chartTitle,
              style: _controller.titleTextStyle),
          textDirection: TextDirection.ltr);
      textPainter.layout();

      final xCenter = (size.width - textPainter.width) / 2;
      final yCenter = (size.height - textPainter.height) / 2;

      textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

}