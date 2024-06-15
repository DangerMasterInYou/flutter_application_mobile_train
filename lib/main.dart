import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'tools/readJsonFile.dart';
import 'pages/sign/autorization_page.dart';
import 'pages/week_train.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:background_fetch/background_fetch.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize(); // Инициализация AndroidAlarmManager

  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      // Обработка нажатия на уведомление
    },
  );

  // Register background fetch
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);

  runApp(MyApp());
}

// This is the fetch-event callback.
void backgroundFetchHeadlessTask(String taskId) async {
  await updatePermission(); // Call your updatePermission method here
  BackgroundFetch.finish(taskId);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else if (snapshot.hasData) {
            bool userExists = snapshot.data!;
            return userExists ? WeekTrainPage() : AuthorizationPage();
          } else {
            return Scaffold(
              body: Center(child: Text('Unknown error')),
            );
          }
        },
      ),
    );
  }

  Future<bool> _initializeApp() async {
    // Проверка существования файла users.json
    final usersDataExists = await getFromJsonFile('users.json');
    if (usersDataExists == null) {
      await initializeUsersFile('users.json');
    }

    // Проверка существования данных пользователя
    bool userDataExists = await _checkExistFile("data_user.json");

    if (userDataExists) {
      final userData = await getFromJsonFile("data_user.json");
      final hour = userData["hourTrain"];
      final minute = userData["minuteTrain"];
      scheduleDailyNotification(hour, minute);
    }

    return userDataExists;
  }

  Future<bool> _checkExistFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      return await file.exists();
    } catch (e) {
      print('Error checking user data: $e');
      return false;
    }
  }

  // Метод для планирования уведомлений
  void scheduleDailyNotification(int hour, int minute) async {
    final now = DateTime.now();
    final int notificationId = 0;

    // Определение времени следующего уведомления
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledTime.isBefore(now) ||
        scheduledTime.weekday == DateTime.sunday) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    while (scheduledTime.weekday == DateTime.sunday) {
      scheduledTime = scheduledTime.add(Duration(days: 1));
    }

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      notificationId,
      showNotification,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    // Для iOS используем local notifications plugin
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Время тренировки',
        'Пора тренироваться!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          iOS: IOSNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  void showNotification() async {
    final now = DateTime.now();
    if (now.weekday != DateTime.sunday) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'daily_notification_channel_id',
        'Daily Notifications',
        channelDescription: 'This channel is used for daily notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const IOSNotificationDetails iosPlatformChannelSpecifics =
          IOSNotificationDetails();
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        'Время тренировки',
        'Пора тренироваться!',
        platformChannelSpecifics,
        payload: 'Daily Workout Reminder',
      );

      // Планируем следующее уведомление
      final userData = await getFromJsonFile("data_user.json");
      final hour = userData["hourTrain"];
      final minute = userData["minuteTrain"];
      scheduleDailyNotification(hour, minute);
    }
  }
}

// Топ-уровневая функция для обновления разрешений
Future<void> updatePermission() async {
  try {
    final data = await getFromJsonFile("data_user.json");
    final time = DateTime.now();
    if (data != null &&
        time.weekday == DateTime.sunday &&
        time.hour == 4 &&
        time.minute == 20) {
      // Чтение данных из файла
      Map<String, dynamic> userData = data as Map<String, dynamic>;

      // Логика обновления разрешения
      int currentWeek = userData['week'];
      switch ((currentWeek - 1) % 7) {
        case 0:
          // 1 неделя: permission = permission
          userData['permission'] *= 0.8;
          break;
        case 1:
        case 2:
        case 4:
        case 5:
          userData['permission'] *= 1.1;
          break;
        case 3:
          userData['permission'] *= 0.9;
          break;
        case 6:
          break;
      }

      // Запись обновленных данных в файл
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/data_user.json');
      await file.writeAsString(jsonEncode(userData));
    }
  } catch (e) {
    print('Error updating permission: $e');
  }
}

// Обработка уведомлений на iOS
Future<void> onDidReceiveLocalNotification(
  int id,
  String? title,
  String? body,
  String? payload,
) async {
  // Вы можете реализовать свою логику здесь, например, показать диалоговое окно или перейти на определенную страницу
}
