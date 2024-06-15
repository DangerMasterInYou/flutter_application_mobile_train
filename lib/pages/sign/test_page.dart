import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'autorization_page.dart';
import '/tools/readJsonFile.dart';
import '/tools/timer_page.dart';

class TestPage extends StatefulWidget {
  final String login;
  final String password;
  final int hour;
  final int minute;

  TestPage(
      {required this.login,
      required this.password,
      required this.hour,
      required this.minute});

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _berpiController = TextEditingController();
  final _podtController = TextEditingController();

  Future<void> _saveUsersJson(dynamic jsonString) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/users.json');
    await file.writeAsString(jsonString);
  }

  void _saveData() async {
    final berpi = int.tryParse(_berpiController.text) ?? 0;
    final podt = int.tryParse(_podtController.text) ?? 0;
    final koef = (berpi / 30 + podt / 30) / 2;
    final normalizedKoef = koef < 0.1 ? 0.1 : koef;

    final newUser = {
      "login": widget.login,
      "password": widget.password,
      "permission": normalizedKoef,
      "hourTrain": widget.hour,
      "minuteTrain": widget.minute,
      "week": 0
    };

    try {
      final List<dynamic> data = await getFromJsonFile("users.json");
      data.add(newUser);
      await _saveUsersJson(json.encode(data));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthorizationPage()),
      );
    } catch (e) {
      print("Error saving data: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ошибка сохранения данных'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      shape: CircleBorder(),
      padding: EdgeInsets.all(20), // Increase padding for a larger button
    );

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Тест')),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimerPage()),
                    );
                  },
                  style: buttonStyle,
                  child: Icon(Icons.timer, size: 100), // Increase icon size
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _berpiController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  labelText: 'Введите количество за минуту: Бёрпи',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _podtController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  labelText: 'Введите количество за минуту: Подтягивания',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Сохранить', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
