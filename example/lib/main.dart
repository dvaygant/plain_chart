import 'package:flutter/material.dart';
import 'pages/simple_page.dart';
import 'pages/sales_page.dart';
import 'pages/sales2_page.dart';
import 'pages/tracker_page.dart';
import 'pages/func_page.dart';
import 'pages/earthquake_page.dart';
import 'pages/star_page.dart';
import 'pages/performance_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Plain chart example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Plain Chart Demo'),
        routes: <String, WidgetBuilder>{
          'simple': (_) => SimplePage(title: 'Simple'),
          'sales': (_) => SalesPage(title: 'Sales'),
          'sales2': (_) => Sales2Page(title: 'Sales2'),
          'covid': (_) => TrackerPage(title: 'COVID-19 daily cases'),
          'func': (_) => FuncPage(title: 'Trigonometric functions'),
          'earthquake': (_) => EarthquakePage(title: 'Earthquake signal'),
          'star': (_) => StarPage(title: 'Star'),
          'perf': (_) => PerformancePage(title: 'Performance (50 000 points)')
        }
    );
  }
}

class MyHomePage extends StatelessWidget {

  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        children: [

          Card(child: ListTile(
              title: Text('COVID-19 tracker'),
              subtitle: Text('Time dataset'),
              leading: Icon(Icons.coronavirus, color: pColor, size: 42.0),
              onTap: () => Navigator.of(context).pushNamed('covid'))),
          Card(child: ListTile(
              title: Text('Sine and Cosine plot'),
              subtitle: Text('Functions dataset'),
              leading: Icon(Icons.functions, color: pColor, size: 42.0),
              onTap: () => Navigator.of(context).pushNamed('func'))),
          Card(child: ListTile(
              title: Text('Star'),
              subtitle: Text('XY dataset'),
              leading: Icon(Icons.star_border_purple500_outlined, color: pColor, size: 42.0),
              onTap: () => Navigator.of(context).pushNamed('star'))),
          Card(child: ListTile(
              title: Text('Performance (50 000 points)'),
              subtitle: Text('Time dataset. Debug mode can be slow!'),
              leading: Icon(Icons.show_chart, color: pColor, size: 42.0),
              onTap: () => Navigator.of(context).pushNamed('perf'))),
          Card(child: ListTile(
              title: Text('Earthquake signal recorder'),
              subtitle: Text('Time dataset'),
              leading: Icon(Icons.graphic_eq, color: pColor, size: 42.0),
              onTap: () => Navigator.of(context).pushNamed('earthquake'))),
          Card(child: ListTile(
              title: Text('Sales'),
              subtitle: Text('Time dataset'),
              leading: Icon(Icons.waterfall_chart, color: pColor, size: 42.0),
              onTap: () => Navigator.of(context).pushNamed('sales'))),
          Card(child: ListTile(
              title: Text('Sales 2'),
              subtitle: Text('XY dataset'),
              leading: Icon(Icons.waterfall_chart, color: pColor, size: 42.0),
              onTap: () => Navigator.of(context).pushNamed('sales2'))),
          Card(child: ListTile(
              title: Text('Simple'),
              subtitle: Text('Time dataset'),
              leading: Icon(Icons.waterfall_chart, color: pColor, size: 42.0),
              onTap: () => Navigator.of(context).pushNamed('simple'))),
        ],
      ),
    );
  }
}
