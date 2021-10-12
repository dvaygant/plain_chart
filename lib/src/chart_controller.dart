import 'package:flutter/material.dart';
import 'base_dataset.dart';
import 'dart:math' as math;

class RectNotifier extends ValueNotifier<Rect> {
  RectNotifier(Rect value) : super(value);
  change() => notifyListeners();

}

class ChartController {

  late AnimationController _animationController;
  late Animation<Rect?> _animation;

  GlobalKey previewContainer = GlobalKey();

  final notifier = RectNotifier(Rect.zero);

  final List <BaseDataSet> dataSetList = [];

  Color? backColor;

  void Function(Canvas)? onAfterDraw;
  void Function(Canvas)? onBeforeDraw;

  int axisXLabelFixedDigits = 1;
  int axisYLabelFixedDigits = 1;

  String chartTitle = '';
  String axisXTitle = '';
  String axisYTitle = '';

  bool allowZoom = true;

  double axisXMinTickInterval = 0.0;
  double axisYMinTickInterval = 0.0;

  double axisXTranslateFactor = 1.0;
  double axisYTranslateFactor = 1.0;

  double legendTextSize = 14.0;

  bool showAxis = true;
  bool showDataSetLegend = true;
  bool filtered = false;

  Paint axisPaint = Paint()
    ..color = Colors.grey.withOpacity(0.6)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;
  
  Paint gridPaint = Paint()
    ..color = Colors.grey.withOpacity(0.2)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;
  
  TextStyle titleTextStyle = const TextStyle(
    color: Colors.deepOrangeAccent,
    fontSize: 14.0,
  );

  TextStyle axisTextStyle = const TextStyle(
    color: Colors.blueGrey,
    fontSize: 12.0,
  );

  double _axisWidthY = 0.0;
  double _axisHeightY = 0.0;
  Offset _scales = const Offset(1.0, 1.0);
  Offset _oldPoint = Offset.zero;
  double _oldScale = 1.0;
  bool _needCalculate = true;
  bool _checkBounds = true;

  Rect _fullRect = Rect.zero;

  Rect _viewRect = Rect.zero;

  Rect _screenRect = Rect.zero;

  Rect get screenRect => _screenRect;

  Rect get fullRect => _fullRect;

  Rect get viewRect => _viewRect;

  bool get isZoomed => _fullRect != _viewRect;

  ///
  double dataToScrX(double x) => _screenRect.left + (x - _viewRect.left) * _scales.dx;

  ///
  double dataToScrY(double y) => _screenRect.bottom  + (y - _viewRect.bottom)  * _scales.dy;

  ///
  Offset dataToScr(Offset pt) => Offset(dataToScrX(pt.dx), dataToScrY(pt.dy));

  ///
  double scrToDataX(double x) => _viewRect.left + (x - _screenRect.left)/_scales.dx;

  ///
  double scrToDataY(double y) =>  _viewRect.bottom - (_screenRect.bottom - y)/_scales.dy;

  ///
  Offset scrToData(Offset pt) => Offset(scrToDataX(pt.dx), scrToDataY(pt.dy));

  ///
  void _calculate() {
    Offset oldScale = _scales;

    double scaleX = _screenRect.width/_viewRect.width;
    double scaleY = _screenRect.height/_viewRect.height;

    _scales = Offset(scaleX, scaleY);
    _needCalculate = _needCalculate || oldScale != _scales ;
    if (!_needCalculate) return;

    for (var data in dataSetList) {
      data.calculatePath(_viewRect, dataToScrX, dataToScrY, filtered: filtered);
    }
    _needCalculate = false;
  }

  ///
  void beforeDraw(Canvas canvas) {
    onBeforeDraw?.call(canvas);
  }

  ///
  void afterDraw(Canvas canvas) {
    onAfterDraw?.call(canvas);
  }

  ///
  bool ready() {
    return
      _viewRect.width.abs() > 0.0 &&
      _viewRect.height.abs() > 0.0 &&
      dataSetList.any((data) => !data.isEmpty());
  }

  ///
  void setScreenRect(Size size) {
    _screenRect = showAxis
        ? Rect.fromLTRB(_axisWidthY, 0.0, size.width, size.height - _axisHeightY)
        : Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    _calculate();
  }

  ///
  Rect getComfortViewRect() => Rect.fromCenter(
      center: _viewRect.center,
      width: _viewRect.width/2.0,
      height: _viewRect.height/2.0);

  ///
  String getXTickCaption(double x) =>
      (x / axisXTranslateFactor).toStringAsFixed(axisXLabelFixedDigits);

  ///
  String getYTickCaption(double y) => y.toStringAsFixed(axisYLabelFixedDigits);

  ///
  _setFullRect(Rect rect) {
    _fullRect = rect;
    _viewRect = _fullRect;

    double y1 = axisYMinTickInterval > 0.0
    ? (_fullRect.bottom ~/ axisYMinTickInterval)*axisYMinTickInterval : _fullRect.bottom;

    var textPainter = TextPainter(
      text: TextSpan(
        text: getYTickCaption(y1),
        style: axisTextStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    var xMax = textPainter.width;
    var yMax = textPainter.height;

    double y2 = axisYMinTickInterval > 0.0
        ? (_fullRect.top ~/ axisYMinTickInterval) * axisYMinTickInterval : _fullRect.top;

    textPainter = TextPainter(
      text: TextSpan(
        text: getYTickCaption(y2),
        style: axisTextStyle,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    _axisWidthY = math.max(textPainter.width, xMax) + 8.0;
    _axisHeightY = math.max(textPainter.height, yMax) + 8.0;

    _scales = const Offset(1.0, 1.0);
    for (var ds in dataSetList) {
      ds.valuePath.reset();
    }

    _needCalculate = true;
  }

  ///
  void _onChangeData() {
    Rect r = dataSetList.first.getBounds();
    dataSetList.skip(1).forEach((it) => r = it.getExpandBounds(r));
    _setFullRect(r);
    notifier.change();
  }

  ///
  void addDataSet(BaseDataSet dataSet) {
    dataSet.onChange = _onChangeData;
    dataSetList.add(dataSet);
    _onChangeData();
  }

  ///
  void clearAllDataSet() {
    dataSetList.clear();
    _fullRect = Rect.zero;
    _viewRect = Rect.zero;
  }

  ///
  void cancelZoom({required bool animate}) {
    if (animate) {
      _setViewRectAnimate(_fullRect);
    } else {
      _setViewRect(_fullRect);
    }
  }

  ///
  void onScaleStart(ScaleStartDetails details) {
    _animationController.stop();
    _oldPoint = details.localFocalPoint;
  }

  ///
  void scaleViewRect(double scale, Offset dp, Offset oldPoint, {required bool animate}) {

    Offset pt = scrToData(oldPoint);
    double dx =   dp.dx / _scales.dx;
    double dy =   dp.dy / _scales.dy;

    double x = pt.dx - dx - ((pt.dx - _viewRect.left) / scale);
    double y = pt.dy - dy - ((pt.dy - _viewRect.top) / scale);

    double w = _viewRect.width / scale;
    double h = _viewRect.height / scale;

    if (animate) {
      _setViewRectAnimate(Rect.fromLTWH(x, y, w, h));
    } else {
      _setViewRect(Rect.fromLTWH(x, y, w, h));
    }
  }

  ///
  _setViewRect(Rect r, {bool checkBounds = true}) {
     Rect old = _viewRect;
    _viewRect = checkBounds ? _checkBoundsViewRect(r) : r;
    _needCalculate = _needCalculate || _viewRect != old;
    _calculate();
     notifier.value = _viewRect;
  }

  ///
  // void _repaintChart() {
  //   notifier.change();
  //  // notifier.value = _viewRect;
  // }

  ///
  Rect _checkBoundsViewRect(Rect newRect) {

    bool inverseY = _scales.dy.isNegative;

    Rect f = inverseY
        ? Rect.fromLTRB(_fullRect.left, _fullRect.bottom, _fullRect.right, _fullRect.top)
        : _fullRect;

    Rect r = inverseY
        ? Rect.fromLTRB(newRect.left, newRect.bottom, newRect.right, newRect.top)
        : newRect;

    if( r.left >= f.left &&
        r.right <= f.right &&
        r.top >= f.top &&
        r.bottom <= f.bottom) {
      return newRect;
    }

    var w = r.width;
    var h = r.height;

    if ( w >= f.width || h >= f.height) return _fullRect;

    double left = r.left;
    double right = r.right;
    double top = r.top;
    double bottom = r.bottom;

    if (left < f.left) {
      left = f.left;
      right = left + w;
    }
    else if (right > f.right) {
      right = f.right;
      left = right - w;
    }

    if (top < f.top) {
      top = f.top;
      bottom = top + h;
    }
    else if (bottom > f.bottom) {
      bottom = f.bottom;
      top = bottom - h;
    }

    return inverseY
      ? Rect.fromLTRB(left, bottom, right, top)
      : Rect.fromLTRB(left, top, right, bottom);
  }

  /// Calculate best interval for axis X
  double calculateXBestInterval(double delta) => _calculateBestInterval(
        _viewRect.width / axisXTranslateFactor, _screenRect.width, delta,
        axisXMinTickInterval) * axisXTranslateFactor;


  /// Calculate best interval for axis Y
  double calculateYBestInterval(double delta) =>
      _calculateBestInterval(-_viewRect.height/axisYTranslateFactor, _screenRect.height, delta, axisYMinTickInterval) * axisYTranslateFactor;

  /// Calculate the interval based min and max values in axis
  double _calculateBestInterval(double valueRange, double sizeBox, double delta, double minTick) {

    const prefTickCount = 5;
    List<double> kValues = [10.0, 5.0,  2.0, 1.0];

    double fSize = sizeBox - prefTickCount * delta;

    if (fSize < 0) return sizeBox;
    int cntTicks = (math.sqrt(fSize)/prefTickCount).floor();
    if (cntTicks == 0) return sizeBox;

    var bestInterval = 1.01 * valueRange / cntTicks;

    if (bestInterval < minTick) return minTick;
    var baseInterval = math.pow(10, (math.log(bestInterval) / math.ln10).floor()).toDouble();

    double currentInterval = baseInterval;

    for (double v in kValues) {
      currentInterval = baseInterval * v;
      if (currentInterval <= bestInterval) break;
    }
    return currentInterval;
  }

  ///
  void onScaleUpdate(ScaleUpdateDetails details) {
    if (!allowZoom) return;
    if (details.scale < 0.05) return;
    var dp = details.localFocalPoint - _oldPoint;
    var ds = details.scale / _oldScale;
    _oldPoint = details.localFocalPoint;
    _oldScale = details.scale;
    scaleViewRect(ds, dp, _oldPoint, animate: false);
  }

  ///
  void onScaleEnd(ScaleEndDetails details) {
    _oldScale = 1.0;
    if (!allowZoom) return;
    if (isZoomed) _physicsScroll(details.velocity.pixelsPerSecond);
  }

  ///
  int _tapCount = 0;
  ///
  onTestTapDown (TapDownDetails details) async {
    _animationController.stop();
    _tapCount += 1;
    if (_tapCount > 1) {
      _tapCount = 0;
      _onDoubleTap(details);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 220));

    bool tap = _tapCount == 1;
    _tapCount = 0;
    if (tap) _onTap(details);
  }

  ///
  void _onTap(TapDownDetails details) {
    // todo: show tooltip
    // print('onTap');
  }

  ///
  void _onDoubleTap(TapDownDetails details) {
    if (isZoomed) {
      cancelZoom(animate: true);
      return;
    }
    scaleViewRect(4.0, Offset.zero, details.localPosition, animate: true);
  }

  ///
  _onAnimation() =>
    _setViewRect(_animation.value!, checkBounds: _checkBounds);

  ///
  _setViewRectAnimate(Rect rect) {
    if (rect == _viewRect) return;
    _startAnimation(_checkBoundsViewRect(rect), 300, false);
  }

  ///
  _startAnimation(Rect r, int ms, bool checkBounds) {
    _checkBounds = checkBounds;
    _animation  = RectTween(begin: _viewRect, end: r).animate(_animationController);
    _animationController.reset();
    _animationController.animateTo(1.0, curve: Curves.decelerate,
        duration: Duration(milliseconds: ms));
  }

  ///
  /// vel = details.velocity.pixelsPerSecond
  _physicsScroll(Offset vel) {
    const deceleration = 2000.0; //in pixels per second squared
    var time = vel.distance/deceleration; // in second
    if (time < 0.05) return;
    var dx = - 0.5 * time * vel.dx/ _scales.dx; // pixels
    var dy = - 0.5 * time * vel.dy/ _scales.dy; // pixels

    _startAnimation(_viewRect.shift(Offset(dx, dy)), (1000 * time).round(), true);
  }

  ///
  void setupAnimation(TickerProvider chart) {
    _animationController = AnimationController(vsync: chart)
      ..addListener(_onAnimation);
  }

  ///
  void closeAnimation() {
    _animationController.dispose();
  }
}