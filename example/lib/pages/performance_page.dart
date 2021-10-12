import 'package:flutter/material.dart';
import 'package:plain_chart/plain_chart.dart';
import 'dart:math' as math;

class PerformancePage extends StatefulWidget {
  final String title;
  const PerformancePage({Key? key, required this.title}) : super(key: key);

  @override
  _PerformancePageState createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {

  List<double> values = [];

  final Paint dPaint = Paint()
    ..color = Colors.blueAccent
    ..strokeWidth = 0.8
    ..style = PaintingStyle.stroke;

  ChartController _controller = ChartController()
    ..backColor = Colors.white
    ..filtered = true
    ..axisYTitle = 'value';

  @override
  void initState() {
    super.initState();
    refresh();
  }

  final random = math.Random();

  void refresh() {

    double d = random.nextDouble() * 10.0;
    values.clear();
    values = List.generate(50000, (index) {
      d += random.nextDouble() - 0.5;
      return d;
    });
    _controller.addDataSet(TimeDataSet(0.1, values, 0.0, dPaint, '50 000 points'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chart(_controller),
          )),
          Expanded(child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  color: Colors.white,
                  child: Center(
                    child: ElevatedButton(
                      child: Text('Refresh data'),
                      onPressed: (){

                        setState(() {
                          _controller.clearAllDataSet();
                          refresh();
                        });
                      },

                    ),
                  )
              )
          ))
        ],
      ),
    );
  }
}



