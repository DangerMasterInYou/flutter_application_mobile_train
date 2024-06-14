import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

// Функция для чтения JSON файла из ассетов
Future<dynamic> getBundleJsonFile(String pathFile) async {
  try {
    final jsonString = await rootBundle.loadString(pathFile);
    final dynamic data = jsonDecode(jsonString);
    return data;
  } catch (e) {
    print("Error loading JSON file from bundle: $e");
    return null;
  }
}

// Функция для сохранения JSON файла в локальное хранилище
Future<void> saveUsersToLocal(String jsonString, String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${fileName}';
    final file = File(path);
    await file.writeAsString(jsonString);
  } catch (e) {
    print("Error saving JSON file to local storage: $e");
  }
}

// Инициализация файла из ассетов и сохранение его в локальное хранилище
Future<void> initializeUsersFile(String pathBundleAssetFile) async {
  final data = await getBundleJsonFile('assets/$pathBundleAssetFile');
  if (data != null) {
    final jsonString = jsonEncode(data);
    await saveUsersToLocal(jsonString, pathBundleAssetFile);
  }
}

// Пример использования функции для загрузки данных из локального хранилища
Future<dynamic> getFromJsonFile(String pathFile) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$pathFile';
    final file = File(path);

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final dynamic data = jsonDecode(jsonString);
      return data;
    } else {
      return null;
    }
  } catch (e) {
    print("Error loading user data: $e");
    return null;
  }
}

// Пример использования функции для проверки существования данных в локальном хранилище
Future<bool> userDataExists() async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/user_data.json';
    final file = File(path);
    return await file.exists();
  } catch (e) {
    print("Error checking user data file: $e");
    return false;
  }
}
