// diagrammForWeek.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<int> values = [30, 50, 70, 60, 80, 100, 0];
  final List<String> days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  final int currentDayIndex;

  WeeklyBarChart({required this.currentDayIndex});

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double chartWidth =
        deviceWidth - (deviceWidth * 0.1); // 90% от ширины экрана

    return Container(
      width: chartWidth, // Установите ширину
      height: 200, // Установите высоту
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true, interval: 25),
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (double value) {
                return days[value.toInt()];
              },
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: values.asMap().entries.map((entry) {
            int index = entry.key;
            int value = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  y: value.toDouble(),
                  colors: [
                    index <= currentDayIndex ? Colors.green : Colors.blue
                  ],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
