import 'package:flutter/material.dart';
import 'package:plain_chart/plain_chart.dart';
import 'dart:math' as math;

class FuncPage extends StatefulWidget {
  final String title;
  const FuncPage({Key? key, required this.title}) : super(key: key);

  @override
  _FuncPageState createState() => _FuncPageState();
}

class _FuncPageState extends State<FuncPage> {

  late FuncDataSet sinFunctionData;
  late FuncDataSet cosFunctionData;

  Rect funcRect = Rect.fromLTRB(0.0, 1.41, 2.5*math.pi, -1.41);

  final Paint sinPaint = Paint()
    ..color = Colors.deepPurpleAccent
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  final Paint cosPaint = Paint()
    ..color = Colors.deepOrangeAccent
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;


  ChartController _controller = ChartController()
    ..axisXTitle = '\u03C0'
    ..axisYTitle = 'f(x)'
    ..axisXTranslateFactor = math.pi
    ..axisXMinTickInterval = 0.5
    ..axisXLabelFixedDigits = 1
    ..axisYLabelFixedDigits = 2;

  @override
  void initState() {
    super.initState();
    sinFunctionData = FuncDataSet((x) => math.sin(x), funcRect, sinPaint, 'sin(x)');
    cosFunctionData = FuncDataSet((x) => math.cos(x), funcRect, cosPaint, 'cos(x)');
    _controller.addDataSet(sinFunctionData);
    _controller.addDataSet(cosFunctionData);
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
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Range ${(10 * funcRect.right/math.pi).roundToDouble()/10.0} \u03C0'),
                      ),
                      Slider(
                        value: funcRect.right,
                        min: 0.5 * math.pi,
                        max: 10.0 * math.pi,
                        divisions: 19,
                        onChanged: (double value) {
                          setState(() {
                            funcRect = Rect.fromLTRB(0.0, 1.41, value, -1.41);
                            sinFunctionData.changeBounds(funcRect, repaint: false);
                            cosFunctionData.changeBounds(funcRect);
                          });
                          },
                      )
                    ],
                  )
              )
          ))
        ],
      ),
    );
  }
}



