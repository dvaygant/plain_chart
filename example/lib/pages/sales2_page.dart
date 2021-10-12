import 'package:flutter/material.dart';
import 'package:plain_chart/plain_chart.dart';

class Sales2Page extends StatelessWidget {

  Sales2Page({Key? key, required this.title}) : super(key: key);

  final String title;

  final _controller = ChartController()
    ..axisXLabelFixedDigits = 0
    ..axisXMinTickInterval = 1.0
    ..addDataSet(XYDataSet([
      Offset(2015, 20),
      Offset(2016, 30),
      Offset(2017, 70),
      Offset(2018, 80),
      Offset(2019, 60),
      Offset(2020, 95)],
        Paint()
          ..color = Colors.deepPurple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0,
        'sales 2',
        minBounds: Rect.fromLTRB(2014, 105.0, 2021, 0.0))
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chart(_controller),
      ),
    );
  }
}



