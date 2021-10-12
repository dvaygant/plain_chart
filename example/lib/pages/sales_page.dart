import 'package:flutter/material.dart';
import 'package:plain_chart/plain_chart.dart';
import 'dart:math';

const Color backColor = const Color(0xFF212121);
const Color primaryColor = const Color(0xFF42B642);

class SalesPage extends StatelessWidget {

  SalesPage({Key? key, required this.title}) : super(key: key);

  final String title;

  final _controller = ChartController()
    ..axisXLabelFixedDigits = 0
    ..axisXMinTickInterval = 1.0
    ..addDataSet(
        TimeDataSet(
            1,
            [20, 30, 70, 80, 60, 95],
            2015,
            Paint()
              ..color = primaryColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.0,
            'sales',
            minValue: 0,
            maxValue: 100
        )
    );

  void _addPoint() {
    TimeDataSet ds = _controller.dataSetList.first as TimeDataSet;
    ds.addValue(Random().nextInt(100).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backColor,
      appBar: AppBar(
          title: Text(title),
          backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chart(_controller),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: _addPoint,
        child: const Icon(Icons.add),
      ),
    );
  }
}



