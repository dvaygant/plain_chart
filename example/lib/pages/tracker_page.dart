import 'package:flutter/material.dart';
import 'package:example/models/data_model.dart';
import 'package:plain_chart/plain_chart.dart';
import 'dart:math' as math;

class TrackerPage extends StatefulWidget {
  final String title;
  TrackerPage({Key? key, required this.title}) : super(key: key);

  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {

  String formatTotalCases(int n) {
    if (n < 1000) return '$n';
    final s = (n % 1000).toString().padLeft(3, '0');
    return formatTotalCases(n ~/ 1000)+' $s';
  }

  final List<String> countryList = ['USA', 'India', 'England', 'Russia', 'Italy', 'Germany'];
  final List<List<double>> valueList = [[], [], [], [], [], []];
  final List<TimeDataSet?> dataList = [null, null, null, null, null, null];

  final List<Color> colorList = [
    Colors.green,
    Colors.lightBlueAccent,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.black];

  int selIndex = -1;
  int progressIndex = -1;

  int totalCases = 0;

  ChartController _controller = ChartController()
    ..backColor = Colors.white
    ..chartTitle = 'Select country'
    ..axisXTitle = 'day'
    ..axisYTitle = 'cases, x1000'
    ..axisXMinTickInterval = 1.0
    ..axisYMinTickInterval = 0.5
    ..filtered = false
    ..axisXLabelFixedDigits = 0;



  ListTile getListTile(int index) {
    final String s = countryList[index];
    return ListTile(
      title: Text(s),
      trailing: selIndex == index
          ? Text('Total: ${formatTotalCases(totalCases)}  cases')
          : null,
      leading: progressIndex == index
          ? CircularProgressIndicator()
          : Image.asset('assets/$s.png'),
      onTap: () => setCountry(index),
      selected: selIndex == index,
    );
  }


  refreshData(int index) async {
    valueList[index].clear();
    final String country = countryList[index];
    CountryTimeLines timeLines =  await getCountryTimeLine(country);

    if (!mounted) return;

    List<double> fifo = [];
    totalCases = 0;
    if (timeLines.isEmpty) return;
    if (timeLines.cases.length == 0) return;

    totalCases = timeLines.cases.values.last;

    double y = 0.0;
    for (int it in timeLines.cases.values) {
      double d = it.toDouble();
      fifo.add(d - y);
      int n = fifo.length;
      if ( n > 7) {
        fifo.removeAt(0);
        n = 7;
      }

      double sum = fifo.fold(0.0, (prev, v) => prev + v);
      valueList[index].add(math.max(0.0, sum / n / 1000.0));
      y = d;
    }

    selIndex = index;
    progressIndex = -1;
    final Paint paint = Paint()
      ..color = colorList[index]
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    if (dataList[index] == null) {
      dataList[index] = TimeDataSet(1.0, valueList[index], 0.0,paint, country);
      _controller.addDataSet(dataList[index]!);
    }
    else {
      if (dataList[index]!.values.length < valueList[index].length) {
        dataList[index]!.addValue(valueList[index].last);
      }
    }

    setState(() {});
  }

  void setCountry(int index) async {
    setState(() {
      progressIndex = index;
    });
    await refreshData(index);
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
                  child: ListView.builder(
                      itemCount: countryList.length,
                      itemBuilder: (context, i) =>  getListTile(i))
              )
          ))
        ],
      ),
    );
  }
}
