import 'package:flutter/material.dart';
import 'package:plain_chart/plain_chart.dart';
import 'dart:math' as math;

class StarPage extends StatefulWidget {
  final String title;
  const StarPage({Key? key, required this.title}) : super(key: key);

  @override
  _StarPageState createState() => _StarPageState();
}

class _StarPageState extends State<StarPage> {

  final List<Offset> rValues = [];
  final List<Offset> bValues = [];

  final Paint rPaint = Paint()
    ..color = Colors.redAccent
    ..strokeWidth = 3.0
    ..style = PaintingStyle.stroke;

  final Paint bPaint = Paint()
    ..color = Colors.blueAccent
    ..strokeWidth = 3.0;

  ChartController _controller = ChartController()
    ..showAxis = false
    ..showDataSetLegend = false;

  calculationXY(List<Offset> values, int angle, double r) {
    values.clear();
    int delta = 0;
    for (int i = 0; i < 5; i++) {
      values.add(Offset(r*math.sin((angle + delta)*math.pi/180),       r*math.cos((angle + delta)*math.pi/180)));
      values.add(Offset(0.5*r*math.sin((angle + delta + 36)*math.pi/180), 0.5*r*math.cos((angle + delta + 36)*math.pi/180)));
      delta += 72;
    }
    values.add(values.first);
  }

  @override
  void initState() {
    super.initState();
    calculationXY(rValues, 0, 10.0);
    calculationXY(bValues, 0, 7.5);
    _controller.addDataSet(XYDataSet(rValues, rPaint, 'red star', isFigure: true));
    _controller.addDataSet(XYDataSet(bValues, bPaint, 'blue star', isFigure: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chart(_controller),
      ),
    );
  }
}



