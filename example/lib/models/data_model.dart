import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart';

class CountryTimeLines {
  final bool isEmpty;
  final String country;
  final List<String> province;
  final Map<String, int> cases;
  final Map<String, int> deaths;
  final Map<String, int> recovered;


  CountryTimeLines({
    required this.isEmpty,
    required this.country,
    required this.province,
    required this.cases,
    required this.deaths,
    required this.recovered});

  factory CountryTimeLines.empty() {
    return CountryTimeLines(
        isEmpty: true,
        country : '',
        province : [],
        cases : {},
        deaths : {},
        recovered : {}
        );
  }

  factory CountryTimeLines.fromJson(Map<String, dynamic> json) {
    return CountryTimeLines(
        isEmpty: false,
        country : json['country'] as String,
        province : List<String>.from(json['province']),
        cases : Map<String, int>.from(json['timeline']['cases']),
        deaths : Map<String, int>.from(json['timeline']['deaths']),
        recovered : Map<String, int>.from(json['timeline']['recovered']));
  }

}

Future<CountryTimeLines> getCountryTimeLine(String country) async {
  try {
    Response response = await get(Uri.parse('https://corona.lmao.ninja/v3/covid-19/historical/$country?lastdays=all'));
    return
      response.statusCode == 200
          ? CountryTimeLines.fromJson(jsonDecode(response.body))
          : CountryTimeLines.empty();
  } catch (e) {
    print("$e");
  }
  return CountryTimeLines.empty();
}
