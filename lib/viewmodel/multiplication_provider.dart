import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MultiplicationProvider with ChangeNotifier {
  List<Multiplication> _multiplications = [];
  Multiplication? _currentMultiplication;

  List<Multiplication> get multiplications => _multiplications;
  Multiplication? get currentMultiplication => _currentMultiplication;

  final SettingsProvider settingsProvider;

  MultiplicationProvider({required this.settingsProvider}) {
    //  lắng nghe thay đổi của setting
    var resultRangeStart = settingsProvider.settings.resultRange.start;
    var resultRangeEnd = settingsProvider.settings.resultRange.end;
    var numberRangeStart = settingsProvider.settings.numberRange.start;
    var numberRangeEnd = settingsProvider.settings.numberRange.end;

    _loadMultiplications();

    settingsProvider.addListener(() async {
      var newResultRangeStart = settingsProvider.settings.resultRange.start;
      var newResultRangeEnd = settingsProvider.settings.resultRange.end;
      var newNumberRangeStart = settingsProvider.settings.numberRange.start;
      var newNumberRangeEnd = settingsProvider.settings.numberRange.end;

      // Nếu phạm vi thay đổi, cần xóa danh sách và tạo lại phép toán
      if (resultRangeStart != newResultRangeStart ||
          resultRangeEnd != newResultRangeEnd ||
          numberRangeStart != newNumberRangeStart ||
          numberRangeEnd != newNumberRangeEnd) {
        await cleanListMultipcation();
        await Future.delayed(Duration(seconds: 3));

        generateMultipleQuestions(300);
      }
    });
  }
  void updateCurrentMultiplication(Multiplication newMultiplication) {
    _currentMultiplication = newMultiplication;
    notifyListeners(); // Thông báo UI cập nhật khi phép toán thay đổi
  }

  void generateNewMultiplication() {
    final random = Random();
    double resultRangeStart = settingsProvider.settings.resultRange.start;
    double resultRangeEnd = settingsProvider.settings.resultRange.end;
    double numberRangeEnd = settingsProvider.settings.numberRange.end;

    int number1 = random.nextInt(numberRangeEnd.toInt()) + 1;
    int number2 = random.nextInt(numberRangeEnd.toInt()) + 1;
    int result = number1 * number2;
    while (result < resultRangeStart || result > resultRangeEnd) {
      number1 = random.nextInt(numberRangeEnd.toInt()) + 1;
      number2 = random.nextInt(numberRangeEnd.toInt()) + 1;
      result = number1 * number2;
    }

    // Cập nhật phép toán mới với kết quả đúng
    _currentMultiplication = Multiplication(
      number1: number1,
      number2: number2,
      result: result,
      star: 0,
    );
    notifyListeners();
  }

  // Tải danh sách phép toán từ SharedPreferences
  Future<void> _loadMultiplications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedMultiplications = prefs.getStringList(
      'multiplications',
    );

    if (encodedMultiplications != null && encodedMultiplications.isNotEmpty) {
      _multiplications =
          encodedMultiplications
              .map((e) => Multiplication.fromJson(json.decode(e)))
              .toList();
    } else {
      generateMultipleQuestions(
        300,
      ); // Nếu không có phép toán trong prefs, tạo mới
    }

    notifyListeners();
  }

  // Lưu phép toán vào SharedPreferences
  Future<void> saveMultiplications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedMultiplications =
        _multiplications
            .map((multiplication) => json.encode(multiplication.toJson()))
            .toList();
    await prefs.setStringList('multiplications', encodedMultiplications);
    notifyListeners();
  }

  // Tạo danh sách phép toán
  void generateMultipleQuestions(int count) {
    final random = Random();
    double resultRangeStart = settingsProvider.settings.resultRange.start;
    double resultRangeEnd = settingsProvider.settings.resultRange.end;
    double numberRangeEnd = settingsProvider.settings.numberRange.end;

    _multiplications.clear();

    while (_multiplications.length < count) {
      int number1 = random.nextInt(numberRangeEnd.toInt()) + 1;
      int number2 = random.nextInt(numberRangeEnd.toInt()) + 1;
      int result = number1 * number2;

      if (result >= resultRangeStart && result <= resultRangeEnd) {
        _multiplications.add(
          Multiplication(
            number1: number1,
            number2: number2,
            result: result,
            star: 0,
          ),
        );
      }
    }

    saveMultiplications();
    notifyListeners();
  }

  // Xóa danh sách phép toán và dữ liệu trong SharedPreferences
  Future<void> cleanListMultipcation() async {
    _multiplications.clear();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('multiplications');
    notifyListeners();
  }
}
