import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart'; // Для доступа к rootBundle
import 'package:flutter_try_with_api/pages/sucess_page.dart';
import 'package:path_provider/path_provider.dart';
import '/pages/week_train.dart';
import '/tools/timer_page.dart';
import '/tools/readJsonFile.dart';
import 'sucess_page.dart';

class DayTrainPage extends StatefulWidget {
  final String dayKey = (DateTime.now().weekday)
      .toString(); // (DateTime.now().weekday).toString()

  @override
  _DayTrainPageState createState() => _DayTrainPageState();
}

class _DayTrainPageState extends State<DayTrainPage> {
  Map<String, dynamic>? exercisesData;
  List<dynamic>? exercises;
  int currentIndex = 0;
  bool isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadJsonData();
    loadUserData();
  }

  Future<void> loadJsonData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/exercises.json');
      final data = json.decode(jsonString);
      setState(() {
        exercisesData = data[widget.dayKey];
        exercises = exercisesData?['exercises'];
        isLoading = false;
      });
      print('Exercises data loaded successfully.');
    } catch (e) {
      print('Error loading JSON data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadUserData() async {
    try {
      final data = await getFromJsonFile('data_user.json');
      setState(() {
        userData = data;
      });
      print('User data loaded successfully.');
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || exercises == null || userData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('День тренировки')),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final exercise = exercises![currentIndex];
    double permissionFactor = userData!['permission'] ?? 1.0;
    int adjustedCount = (exercise['count'] * permissionFactor).round();

    String count_or_time = "";
    if (widget.dayKey == "1" || widget.dayKey == "4") {
      count_or_time = "Повторений: $adjustedCount";
    } else {
      count_or_time = adjustedCount ~/ 3600 > 0
          ? 'Время: ${adjustedCount ~/ 3600}:${(adjustedCount % 3600 ~/ 60).toString().padLeft(2, '0')}:${(adjustedCount % 60).toString().padLeft(2, '0')}'
          : 'Время: ${adjustedCount ~/ 60}:${(adjustedCount % 60).toString().padLeft(2, '0')}';
    }

    final buttonStyle = ElevatedButton.styleFrom(
      shape: CircleBorder(),
      padding: EdgeInsets.all(16),
    );

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(exercisesData!['view'])),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    exercises!.length,
                    (index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            index <= currentIndex ? Colors.green : Colors.grey,
                        child: Text((index + 1).toString()),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.asset(exercise['pathPhoto']),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          '${exercise['name']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        count_or_time,
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Описание: ${exercise['description']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (widget.dayKey != "1" && widget.dayKey != "4")
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TimerPage(initialTime: adjustedCount)),
                    );
                  },
                  style: buttonStyle,
                  child: Icon(Icons.timer, size: 32),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (currentIndex < exercises!.length - 1) {
                    setState(() {
                      currentIndex++;
                    });
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SuccessPage()),
                    );
                  }
                },
                style: buttonStyle,
                child: Icon(Icons.arrow_forward, size: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
