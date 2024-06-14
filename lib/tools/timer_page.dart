// timer_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TimerPage extends StatefulWidget {
  final int initialTime;

  TimerPage({this.initialTime = 60});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late int _remainingTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.initialTime;
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer!.cancel();
        Navigator.pop(
            context); // Возврат на предыдущую страницу по окончанию времени
      }
    });
  }

  void _pauseTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percent = (_remainingTime / widget.initialTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 150.0,
              lineWidth: 15.0,
              percent: percent,
              center: Text(
                _remainingTime ~/ 3600 > 0
                    ? '${_remainingTime ~/ 3600}:${(_remainingTime % 3600 ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}'
                    : '${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 48),
              ),
              progressColor: Colors.blue,
            ),

            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  iconSize: 68,
                  onPressed: _startTimer,
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.pause),
                  iconSize: 68,
                  onPressed: _pauseTimer,
                ),
              ],
            ),
            SizedBox(height: 40), // Adjust the height as needed
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(250,
                    80), // Установите минимальный размер кнопки (ширина, высота)
                textStyle: TextStyle(fontSize: 20), // Установите размер текста
              ),
              child: Text('Break'),
            ),
          ],
        ),
      ),
    );
  }
}
