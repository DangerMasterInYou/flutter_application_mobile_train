import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import '/tools/readJsonFile.dart';
import '/tools/diagrammForWeek.dart';
import 'day_train.dart';
import 'plan_page.dart';
import 'sign/autorization_page.dart';

class WeekTrainPage extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    try {
      // Получение пути к локальному файлу data_user.json
      final Directory directory = await getApplicationDocumentsDirectory();
      final String userDataPath = '${directory.path}/data_user.json';
      final File userDataFile = File(userDataPath);

      // Проверка наличия data_user.json
      if (await userDataFile.exists()) {
        final String userDataJson = await userDataFile.readAsString();
        final dynamic userData = jsonDecode(userDataJson);

        // Чтение данных из users.json из ассетов
        final List<dynamic> users = await getFromJsonFile("users.json") ?? [];

        // Поиск и обновление данных в users.json при совпадении логина
        bool userUpdated = false;
        for (var user in users) {
          if (user['login'] == userData['login']) {
            user['permission'] = userData['permission'];
            userUpdated = true;
            break;
          }
        }

        // Если пользователь не найден, добавляем его
        if (!userUpdated) {
          users.add(userData);
        }

        // Сохранение обновленных данных в users.json
        final String updatedUsersJson = jsonEncode(users);
        await saveUsersToLocal(updatedUsersJson, 'users.json');

        // Удаление data_user.json
        await userDataFile.delete();
      }

      // Перенаправление на страницу авторизации
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthorizationPage()),
      );
    } catch (e) {
      print("Error during logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ошибка при выходе из системы'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Главная'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  WeeklyBarChart(currentDayIndex: (DateTime.now().weekday - 1)),
            ),
            SizedBox(height: 100), // Отступ между диаграммой и кнопками
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (DateTime.now().weekday != 7) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DayTrainPage()),
                        );
                      } else {
                        print("Отдых - тоже тренировка");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity,
                          60), // Устанавливаем минимальный размер кнопки (ширина, высота)
                      textStyle: TextStyle(
                          fontSize: 18), // Устанавливаем размер текста
                    ),
                    child: Text('Тренировка'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PlanPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity,
                          60), // Устанавливаем минимальный размер кнопки (ширина, высота)
                      textStyle: TextStyle(
                          fontSize: 18), // Устанавливаем размер текста
                    ),
                    child: Text('План'),
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
