# Plain Chart

A simple flutter package to create a custom chart
Support for dragging, scaling, fling.

![funcdataset](https://user-images.githubusercontent.com/91197968/137114639-14c2c23f-6ba9-4d98-94a0-0885503dabb9.png)

## Features

- Multiple data sets and plot types
- Pinch-to-zoom
- DoubleTap-to-zoom

## Getting started


## Usage

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

## Additional information

