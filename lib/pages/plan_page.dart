import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:io';
import '/tools/readJsonFile.dart';
import 'package:path_provider/path_provider.dart';

class PlanPage extends StatefulWidget {
  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late List<charts.Series<WeekPermission, int>> _seriesData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await getFromJsonFile("data_user.json");
    if (data != null) {
      Map<String, dynamic> userData = data as Map<String, dynamic>;
      double permission = userData['permission'];
      int userWeek = userData['week'] ?? 0;
      List<WeekPermission> weekData = [];
      int n = 0;

      while (permission < 1) {
        switch (n % 7) {
          case 0:
            permission *= 0.8;
            break;
          case 1:
          case 2:
          case 4:
          case 5:
            permission *= 1.1;
            break;
          case 3:
            permission *= 0.9;
            break;
          case 6:
            break;
        }
        n % 7 == 6
            ? weekData.add(WeekPermission(n, 0))
            : weekData.add(WeekPermission(n, permission));
        n++;
      }

      // Ensure the graph reaches 1
      weekData.add(WeekPermission(n, 1.0));

      setState(() {
        _seriesData = [
          charts.Series<WeekPermission, int>(
            id: 'Permissions',
            colorFn: (WeekPermission weekPermission, _) {
              if (weekPermission.week <= userWeek) {
                return charts.MaterialPalette.green.shadeDefault;
              } else {
                return charts.MaterialPalette.blue.shadeDefault;
              }
            },
            domainFn: (WeekPermission weekPermission, _) => weekPermission.week,
            measureFn: (WeekPermission weekPermission, _) =>
                weekPermission.permission,
            data: weekData,
            strokeWidthPxFn: (_, __) => 2,
            insideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(
              color: charts.MaterialPalette.blue.shadeDefault,
            ),
            outsideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(
              color: charts.MaterialPalette.blue.shadeDefault,
            ),
          )
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Plan'),
      ),
      body: _seriesData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: charts.LineChart(
                      _seriesData,
                      animate: true,
                      defaultRenderer: charts.LineRendererConfig(
                        includePoints: true,
                      ),
                      primaryMeasureAxis: charts.NumericAxisSpec(
                        tickProviderSpec: charts.BasicNumericTickProviderSpec(
                          zeroBound: true,
                          dataIsInWholeNumbers: false,
                          desiredTickCount: 10,
                        ),
                        viewport: charts.NumericExtents(0, 1),
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 10,
                            color: charts.MaterialPalette.black,
                          ),
                          lineStyle: charts.LineStyleSpec(
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                        showAxisLine: true,
                      ),
                      domainAxis: charts.NumericAxisSpec(
                        tickProviderSpec: charts.BasicNumericTickProviderSpec(
                          zeroBound: true,
                          dataIsInWholeNumbers: true,
                          desiredTickCount: 10,
                        ),
                        renderSpec: charts.GridlineRendererSpec(
                          labelStyle: charts.TextStyleSpec(
                            fontSize: 10,
                            color: charts.MaterialPalette.black,
                          ),
                          lineStyle: charts.LineStyleSpec(
                            color: charts.MaterialPalette.black,
                          ),
                        ),
                        showAxisLine: true,
                      ),
                      behaviors: [
                        charts.ChartTitle(
                          'Weeks',
                          behaviorPosition: charts.BehaviorPosition.bottom,
                          titleOutsideJustification:
                              charts.OutsideJustification.middleDrawArea,
                        ),
                        charts.ChartTitle(
                          'Progress',
                          behaviorPosition: charts.BehaviorPosition.start,
                          titleOutsideJustification:
                              charts.OutsideJustification.middleDrawArea,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class WeekPermission {
  final int week;
  final double permission;

  WeekPermission(this.week, this.permission);
}
