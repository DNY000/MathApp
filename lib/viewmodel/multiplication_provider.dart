import 'package:flutter/material.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_app/models/settings_model.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'dart:convert';
import 'dart:math';

class MultiplicationProvider with ChangeNotifier {
  List<Multiplication> _multiplications = []; //
  List<Multiplication> listByNumber = [];
  Multiplication? _currentMultiplication;
  final SettingsProvider settingsProvider;
  SettingsModel _currentSettings;
  final List<AnswerRecord> answerHistory = [];
  List<Multiplication> _practiceSet = [];
  List<Multiplication> listAnswerTesting = [];
  int _currentPracticeIndex = 0;
  // ignore: constant_identifier_names
  static const int PRACTICE_SET_SIZE = 10;
  int _correctAnswersCount = 0;
  List<Multiplication> _currentMultiplications = [];

  List<Multiplication> get currentMultiplications => _currentMultiplications;
  // Getters
  List<Multiplication> get practiceSet => _practiceSet;
  int get currentPracticeIndex => _currentPracticeIndex;
  bool get isPracticeComplete => _correctAnswersCount >= PRACTICE_SET_SIZE;
  Multiplication? get currentMultiplication => _currentMultiplication;
  int get correctAnswersCount => _correctAnswersCount;
  int get wrongAnswersCount =>
      answerHistory.where((record) => !record.isCorrect).length;

  MultiplicationProvider({required this.settingsProvider})
    : _currentSettings = settingsProvider.settings {
    settingsProvider.addListener(_onSettingsChanged);
    _loadMultiplications();
  }

  @override
  void dispose() {
    settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    _currentSettings = settingsProvider.settings;

    _loadMultiplications();
  }

  List<Multiplication> get multiplications => _multiplications;

  List<Multiplication> get10Answer() {
    if (_multiplications.isEmpty) {
      generateMultipleQuestions(100);
    }
    final List<Multiplication> tempList = List.from(_multiplications);
    tempList.shuffle();
    return tempList.take(10).toList();
  }

  List<Multiplication> dsnumber(int number) {
    _currentMultiplications = List.generate(12, (index) {
      final existingMultiplication = _multiplications.firstWhere(
        (element) => element.number1 == number && element.number2 == index,
        orElse:
            () => Multiplication(
              number1: number,
              number2: index,
              result: number * index,
              star: 0,
            ),
      );
      return existingMultiplication;
    });
    notifyListeners();
    return _currentMultiplications;
  }

  // xóa dữ liệu khi trả lời
  void resetPractice() {
    _practiceSet.clear();

    _currentPracticeIndex = 0;
    _correctAnswersCount = 0;
    _currentMultiplication = null;
    answerHistory.clear();
    notifyListeners();
  }

  void startPracticeSession() {
    resetPractice();
    notifyListeners();
    if (_multiplications.isEmpty) {
      return;
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

      // Lấy thông tin cài đặt đã lưu
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

      await Future(() async {
        // Reset practice session trước khi thay đổi dữ liệu
        resetPractice();

        if (settingsChanged) {
          // Xóa và cập nhật dữ liệu khi có thay đổi
          await prefs.remove('multiplications');
          _multiplications.clear();

          // Lưu cài đặt mới
          await prefs.setInt('resultRangeStart', currentResultStart);
          await prefs.setInt('resultRangeEnd', currentResultEnd);
          await prefs.setInt('numberRangeStart', currentNumberStart);
          await prefs.setInt('numberRangeEnd', currentNumberEnd);

          generateMultipleQuestions(100);
        } else {
          // Load dữ liệu cũ nếu không có thay đổi
          List<String>? encodedMultiplications = prefs.getStringList(
            'multiplications',
          );

          if (encodedMultiplications != null &&
              encodedMultiplications.isNotEmpty) {
            _multiplications =
                encodedMultiplications
                    .map((e) => Multiplication.fromJson(json.decode(e)))
                    .toList();
          } else {
            // Tạo mới nếu không có dữ liệu
            generateMultipleQuestions(100);
          }
        }

        // Khởi tạo practice session
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

    // _multiplications.clear();
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

    answerHistory.add(answerRecord);

    if (isCorrect) {
      _correctAnswersCount++;
      // _consecutiveCorrectAnswers++;

      updateStar(true);
      if (_currentPracticeIndex < _practiceSet.length - 1) {
        _currentPracticeIndex++;
        _currentMultiplication = _practiceSet[_currentPracticeIndex];
      }

      // Chỉ notify khi trả lời đúng để cập nhật UI và chuyển câu mới
      notifyListeners();
    } else {
      // _consecutiveCorrectAnswers = 0;
      // Chỉ cập nhật sao mà không notify để tránh random lại giao diện
      updateStarWithoutNotify(false);
    }
  }

  // Update star mà không gọi notifyListeners để tránh render lại UI
  void updateStarWithoutNotify(bool isCorrect) {
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

      // Lưu thay đổi vào SharedPreferences không gọi notifyListeners
      saveMultiplicationsWithoutNotify();
    }
  }

  // Phiên bản của saveMultiplications không gọi notifyListeners
  Future<void> saveMultiplicationsWithoutNotify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedMultiplications =
        _multiplications
            .map((multiplication) => json.encode(multiplication.toJson()))
            .toList();
    await prefs.setStringList('multiplications', encodedMultiplications);
    // Không gọi notifyListeners để tránh UI render lại
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
      notifyListeners();
    }
  }

  void _setRandomCurrentMultiplication() {
    try {
      if (_multiplications.isNotEmpty) {
        final random = Random();
        _currentMultiplication =
            _multiplications[random.nextInt(_multiplications.length)];

        notifyListeners();
      }
    } catch (e) {
      throw (Exception(e));
    }
  }

  // chức năng chơi lại
  void retryCorrectAnswers() {
    final correctAnswers =
        answerHistory.where((record) => record.isCorrect).toList();

    if (correctAnswers.isEmpty) return;

    _practiceSet =
        correctAnswers.map((record) {
          return Multiplication(
            number1: record.number1,
            number2: record.number2,
            result: record.result,
            star: record.start,
          );
        }).toList();

    if (_practiceSet.length > PRACTICE_SET_SIZE) {
      _practiceSet.shuffle();
      _practiceSet = _practiceSet.sublist(0, PRACTICE_SET_SIZE);
    }

    _currentPracticeIndex = 0;
    _currentMultiplication = _practiceSet[0];
    // _currentSessionAnswers.clear();
    _correctAnswersCount = 0;
    // _consecutiveCorrectAnswers = 0;
    answerHistory.clear();
    notifyListeners();
  }

  int sumStar(List<Multiplication> list) {
    return list.fold(
      0,
      (previousValue, multiplication) => previousValue + multiplication.star,
    );
  }

  Future<void> resetAllStars() async {
    try {
      for (int i = 0; i < _multiplications.length; i++) {
        if (_multiplications[i].star > 0) {
          _multiplications[i] = Multiplication(
            number1: _multiplications[i].number1,
            number2: _multiplications[i].number2,
            result: _multiplications[i].result,
            star: 0,
          );
        }
      }

      // Lưu thay đổi vào SharedPreferences
      await saveMultiplications();
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    }
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
  @override
  String toString() {
    return 'Phép tính: $number1 x $number2 = $result\n'
        'Đáp án đã chọn: $selectedAnswer\n'
        'Kết quả: ${isCorrect ? "Đúng" : "Sai"}\n'
        'Số sao: $start';
  }
}
