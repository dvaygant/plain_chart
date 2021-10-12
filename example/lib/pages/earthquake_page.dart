import 'package:flutter/material.dart';
import 'package:plain_chart/plain_chart.dart';
import 'dart:math' as math;
import 'dart:async';


class EarthquakePage extends StatefulWidget {
  final String title;
  const EarthquakePage({Key? key, required this.title}) : super(key: key);

  @override
  _EarthquakePageState createState() => _EarthquakePageState();
}

class _EarthquakePageState extends State<EarthquakePage> {

  final List<double> values = [];
  final int maxCount = 250;
  final int interval = 25;
  late double delta;
  late TimeDataSet data;
  double magnitude = 1.0;

  final Paint aPaint = Paint()
    ..color = Colors.deepPurpleAccent
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  ChartController _controller = ChartController()
    ..backColor = Colors.white
    ..allowZoom = false;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    delta = 1.0/interval; // second
    data = TimeDataSet(delta, values, 0.0, aPaint, 'earthquake', maxValue: 10.0, minValue: -10.0, minRange: maxCount*delta);
    _controller.addDataSet(data);
    timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      addPoint();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  final random = math.Random();

  void addPoint() {
    double v = (random.nextDouble() - 0.5) * magnitude;
    if (magnitude > 1.0) magnitude *= 0.8;
    data.addValue(v, maxLength: maxCount);
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
                      child: Text('Boom!'),
                      onPressed: (){
                        magnitude = random.nextDouble()*5 + 18.0;
                    //    print(magnitude);
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