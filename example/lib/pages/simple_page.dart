import 'package:flutter/material.dart';
import 'package:plain_chart/plain_chart.dart';
import 'dart:math';

class SimplePage extends StatelessWidget {

  SimplePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Chart(ChartController()
            ..addDataSet(XYDataSet(
                    List.generate(10, (i) => Offset(i.toDouble(), Random().nextDouble()*10)),
                    Paint()
                      ..color = const Color(0xFF42B642)
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3.0,
                    title
                )
            )),
        ),
      ),
    );
  }
}



