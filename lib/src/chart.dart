import 'package:flutter/material.dart';
import 'chart_controller.dart';
import 'chart_painter.dart';


class Chart extends StatefulWidget {
  final ChartController controller;
  const Chart(this.controller, {Key? key}) : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    widget.controller.setupAnimation(this);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.closeAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
      RepaintBoundary(
          key: widget.controller.previewContainer, //for screenshot
          child: GestureDetector (
              behavior: HitTestBehavior.translucent,
              onScaleStart:     widget.controller.onScaleStart,
              onScaleEnd:       widget.controller.onScaleEnd,
              onScaleUpdate:    widget.controller.onScaleUpdate,
              onTapDown:        widget.controller.onTestTapDown,
              child: CustomPaint(
                foregroundPainter: ChartPainter(widget.controller),
                child: Container(color: widget.controller.backColor),
              )
          )
      );
  }
}