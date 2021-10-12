```dart
import 'package:flutter/material.dart';
import 'package:plain_chart/plain_chart.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Chart(ChartController()
            ..addDataSet(XYDataSet(
                List.generate(10, (i) => Offset(i.toDouble(), Random().nextDouble()*10)),
                Paint()
                  ..color = Colors.blue
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.0,
                'My data'))
          ),
        ),
      ),
    );
  }
}
```