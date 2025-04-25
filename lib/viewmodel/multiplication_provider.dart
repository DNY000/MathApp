import 'package:flutter/material.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_app/models/settings_model.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'dart:convert';
import 'dart:math';

class MultiplicationProvider with ChangeNotifier {
  List<Multiplication> _multiplications = [];
  List<Multiplication> listByNumber = [];
  Multiplication? _currentMultiplication;
  final SettingsProvider settingsProvider;
  SettingsModel _currentSettings;
  final List<AnswerRecord> _answerHistory = [];
  final List<AnswerRecord> _currentSessionAnswers = [];
  List<Multiplication> _practiceSet = [];
  List<Multiplication> listAnswerTesting = [];
  int _currentPracticeIndex = 0;
  // ignore: constant_identifier_names
  static const int PRACTICE_SET_SIZE = 10;
  int _correctAnswersCount = 0;

  // Getters
  List<Multiplication> get practiceSet => _practiceSet;
  int get currentPracticeIndex => _currentPracticeIndex;
  bool get isPracticeComplete => _correctAnswersCount >= PRACTICE_SET_SIZE;
  Multiplication? get currentMultiplication => _currentMultiplication;
  List<AnswerRecord> get answerHistory => _answerHistory;
  List<AnswerRecord> get currentSessionAnswers => _currentSessionAnswers;
  int get correctAnswersCount => _correctAnswersCount;
  int get wrongAnswersCount =>
      _currentSessionAnswers.length - _correctAnswersCount;

  MultiplicationProvider({required this.settingsProvider})
    : _currentSettings = settingsProvider.settings {
    settingsProvider.addListener(onSettingsChanged);
    _loadMultiplications();
  }

  List<Multiplication> get multiplications => _multiplications;

  // void setMultiplications(List<Multiplication> multiplications) {
  //   _multiplications = multiplications;
  //   notifyListeners();
  // }
  List<Multiplication> get10Answer() {
    if (_multiplications.isEmpty) {
      generateMultipleQuestions(100);
    }
    final List<Multiplication> tempList = List.from(_multiplications);
    tempList.shuffle();
    return tempList.take(10).toList();
  }

  // lay danh sách các phép tính cố số thứ nhất bằng number và số thứ 2 từ 0-11
  void dsnumber(int number, List<Multiplication> ds) {
    // Tạo danh sách mới chứa các phép tính từ 0-11 với số được chọn
    ds = List.generate(12, (index) {
      // Tìm phép tính tương ứng trong danh sách gốc
      final existingMultiplication = ds.firstWhere(
        (element) =>
            element.number1 == number &&
            element.number2 == index &&
            element.star > 0,
        orElse:
            () => Multiplication(
              number1: number,
              number2: index,
              result: number * index,
              star: 0,
            ),
      );

      print('Danh sách $existingMultiplication');

      return existingMultiplication;
    });

    notifyListeners();
  }

  // xóa dữ liệu khi trả lời
  void resetPractice() {
    _practiceSet.clear();
    _currentPracticeIndex = 0;
    _currentSessionAnswers.clear();
    _correctAnswersCount = 0;
    notifyListeners();
  }

  void startPracticeSession() {
    resetPractice();

    if (_multiplications.isEmpty) {
      generateMultipleQuestions(100);
    }

    final random = Random();
    final availableIndices = List.generate(_multiplications.length, (i) => i);

    while (_practiceSet.length < PRACTICE_SET_SIZE &&
        availableIndices.isNotEmpty) {
      final randomIndex = random.nextInt(availableIndices.length);
      final questionIndex = availableIndices[randomIndex];
      _practiceSet.add(_multiplications[questionIndex]);
      availableIndices.removeAt(randomIndex);
    }

    if (_practiceSet.isNotEmpty) {
      _currentMultiplication = _practiceSet[0];
    }

    notifyListeners();
  }

  Future<void> _loadMultiplications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Lưu thông tin cài đặt hiện tại
      final currentResultStart = _currentSettings.resultRange.start.toInt();
      final currentResultEnd = _currentSettings.resultRange.end.toInt();
      final currentNumberStart = _currentSettings.numberRange.start.toInt();
      final currentNumberEnd = _currentSettings.numberRange.end.toInt();

      // Lấy thông tin cài đặt đã lưu (nếu có)
      final savedResultStart = prefs.getInt('resultRangeStart') ?? -1;
      final savedResultEnd = prefs.getInt('resultRangeEnd') ?? -1;
      final savedNumberStart = prefs.getInt('numberRangeStart') ?? -1;
      final savedNumberEnd = prefs.getInt('numberRangeEnd') ?? -1;

      // Kiểm tra cài đặt có thay đổi không
      final settingsChanged =
          savedResultStart != currentResultStart ||
          savedResultEnd != currentResultEnd ||
          savedNumberStart != currentNumberStart ||
          savedNumberEnd != currentNumberEnd;

      // Tải danh sách trong Future để không chặn UI
      await Future(() async {
        // Nếu cài đặt đã thay đổi, tạo lại danh sách
        if (settingsChanged) {
          // Lưu cài đặt hiện tại
          await prefs.setInt('resultRangeStart', currentResultStart);
          await prefs.setInt('resultRangeEnd', currentResultEnd);
          await prefs.setInt('numberRangeStart', currentNumberStart);
          await prefs.setInt('numberRangeEnd', currentNumberEnd);

          // Tạo mới danh sách
          generateMultipleQuestions(100);
        } else {
          List<String>? encodedMultiplications = prefs.getStringList(
            'multiplications',
          );

          if (encodedMultiplications != null &&
              encodedMultiplications.isNotEmpty) {
            _multiplications =
                encodedMultiplications
                    .map((e) => Multiplication.fromJson(json.decode(e)))
                    .toList();
          }
        }

        _setRandomCurrentMultiplication();
        startPracticeSession();
        notifyListeners();
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  // tạo  phép tính
  void generateMultipleQuestions(int count) {
    final random = Random();

    final resultStart = _currentSettings.resultRange.start.toInt();
    final resultEnd = _currentSettings.resultRange.end.toInt();
    final numberStart = _currentSettings.numberRange.start.toInt();
    final numberEnd = _currentSettings.numberRange.end.toInt();

    _multiplications.clear();
    int attempts = 0;
    const maxAttempts = 200;

    while (_multiplications.length < count && attempts < maxAttempts) {
      attempts++;

      int number1 = numberStart + random.nextInt(numberEnd - numberStart + 1);
      int number2 = numberStart + random.nextInt(numberEnd - numberStart + 1);

      int result = number1 * number2;

      if (result >= resultStart && result <= resultEnd) {
        Multiplication multiplication = Multiplication(
          number1: number1,
          number2: number2,
          result: result,
          star: 0,
        );

        if (!_multiplications.contains(multiplication)) {
          _multiplications.add(multiplication);
        }
      }
    }

    saveMultiplications();
    notifyListeners();
  }

  // lưu vào bộ nhơ local
  Future<void> saveMultiplications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedMultiplications =
        _multiplications
            .map((multiplication) => json.encode(multiplication.toJson()))
            .toList();
    await prefs.setStringList('multiplications', encodedMultiplications);
    notifyListeners();
  }

  // Kiểm tra seting thay đổi
  void onSettingsChanged() {
    _currentSettings = settingsProvider.settings;
    //xóa dữ liệu  luyện tập

    resetPractice();

    /// xóa dữ liệu local
    Future(() async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Xóa dữ liệu cũ
        await prefs.remove('multiplications');

        // Xóa danh sách cũ
        _multiplications.clear();

        // Cập nhật phép tính hiện tại và bắt đầu phiên luyện tập mới
        _setRandomCurrentMultiplication();
        startPracticeSession();
      } catch (e) {
        throw Exception(e);
      }
    });
  }

  // ghi lại câu trả lời
  Future<void> recordAnswer(int selectedAnswer) async {
    if (_currentMultiplication == null) return;

    final bool isCorrect = selectedAnswer == _currentMultiplication!.result;

    final answerRecord = AnswerRecord(
      number1: _currentMultiplication!.number1,
      number2: _currentMultiplication!.number2,
      result: _currentMultiplication!.result,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      start: _currentMultiplication!.star,
    );

    _answerHistory.add(answerRecord);
    _currentSessionAnswers.add(answerRecord);

    if (isCorrect) {
      _correctAnswersCount++;

      updateStar(true);
      // await Future.delayed(const Duration(seconds: 1));
      if (!isPracticeComplete &&
          _currentPracticeIndex < _practiceSet.length - 1) {
        _currentPracticeIndex++;
        _currentMultiplication = _practiceSet[_currentPracticeIndex];
      }
    } else {
      updateStar(false);
    }
    print('Tổng số sao hiện tại: ${sumStar(_multiplications)}');
    notifyListeners();
  }

  // Update star rating
  void updateStar(bool isCorrect) {
    if (_currentMultiplication == null) return;

    final index = _multiplications.indexWhere(
      (m) =>
          m.number1 == _currentMultiplication!.number1 &&
          m.number2 == _currentMultiplication!.number2,
    );

    if (index != -1) {
      int currentStar = _multiplications[index].star;
      int newStar = currentStar;

      if (isCorrect) {
        // Tăng số sao nếu trả lời đúng, tối đa 5 sao
        if (currentStar < 5) {
          newStar = currentStar + 1;
        }
      } else {
        // Giảm số sao nếu trả lời sai, tối thiểu 0 sao
        if (currentStar > 0) {
          newStar = currentStar - 1;
        }
      }

      // Cập nhật số sao trong danh sách phép tính
      _multiplications[index] = Multiplication(
        number1: _currentMultiplication!.number1,
        number2: _currentMultiplication!.number2,
        result: _currentMultiplication!.result,
        star: newStar,
      );

      _currentMultiplication = _multiplications[index];

      // Lưu thay đổi vào SharedPreferences
      saveMultiplications();

      // In tổng số sao sau khi cập nhật
      print('Tổng số sao hiện tại: ${sumStar(_multiplications)}');
      notifyListeners();
    }
  }

  // tạo phiên bản luyện tập mới
  void retryCurrentSession() {
    if (_currentSessionAnswers.isEmpty) return;

    _practiceSet =
        _currentSessionAnswers.map((record) {
          // Tìm phép nhân tương ứng trong _multiplications
          final multiplication = _multiplications.firstWhere(
            (m) => m.number1 == record.number1 && m.number2 == record.number2,
            orElse:
                () => Multiplication(
                  number1: record.number1,
                  number2: record.number2,
                  result: record.result,
                  star: 0,
                ),
          );
          return Multiplication(
            number1: record.number1,
            number2: record.number2,
            result: record.result,
            star: multiplication.star,
          );
        }).toList();

    _currentPracticeIndex = 0;
    _currentMultiplication = _practiceSet[0];
    _currentSessionAnswers.clear();
    _correctAnswersCount = 0;

    notifyListeners();
  }

  void _setRandomCurrentMultiplication() {
    if (_multiplications.isNotEmpty) {
      final random = Random();
      _currentMultiplication =
          _multiplications[random.nextInt(_multiplications.length)];

      notifyListeners();
    } else {
      generateMultipleQuestions(100);
    }
  }

  void retryCorrectAnswers() {
    // Lọc ra các câu trả lời đúng từ _answerHistory
    final correctAnswers =
        _answerHistory.where((record) => record.isCorrect).toList();

    if (correctAnswers.isEmpty) return;

    // Tạo practice set mới từ các câu trả lời đúng
    _practiceSet =
        correctAnswers.map((record) {
          // Tìm phép nhân tương ứng trong _multiplications
          final multiplication = _multiplications.firstWhere(
            (m) => m.number1 == record.number1 && m.number2 == record.number2,
            orElse:
                () => Multiplication(
                  number1: record.number1,
                  number2: record.number2,
                  result: record.result,
                  star: 0,
                ),
          );
          return Multiplication(
            number1: record.number1,
            number2: record.number2,
            result: record.result,
            star: multiplication.star,
          );
        }).toList();

    if (_practiceSet.length > PRACTICE_SET_SIZE) {
      _practiceSet.shuffle();
      _practiceSet = _practiceSet.sublist(0, PRACTICE_SET_SIZE);
    }

    // Reset các trạng thái
    _currentPracticeIndex = 0;
    _currentMultiplication = _practiceSet[0];
    _currentSessionAnswers.clear();
    _correctAnswersCount = 0;
    _answerHistory.clear();
    notifyListeners();
  }

  int sumStar(List<Multiplication> list) {
    return list.fold(
      0,
      (previousValue, multiplication) => previousValue + multiplication.star,
    );
  }
}

class AnswerRecord {
  int number1;
  int number2;
  int result;
  int start; // correct result
  int selectedAnswer; // user's selected answer
  final bool isCorrect;

  AnswerRecord({
    required this.number1,
    required this.number2,
    required this.result,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.start,
  });
}
