import 'package:flutter/material.dart';
import 'package:math_app/models/multiplication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_app/models/settings_model.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'dart:convert';
import 'dart:math';

class MultiplicationProvider with ChangeNotifier {
  List<Multiplication> _multiplications = [];
  Multiplication? _currentMultiplication;
  final SettingsProvider settingsProvider;
  SettingsModel _currentSettings;
  final List<AnswerRecord> _answerHistory = [];

  // Add practice properties
  List<Multiplication> _practiceSet = [];
  int _currentPracticeIndex = 0;
  static const int PRACTICE_SET_SIZE = 10;

  // Add getters
  List<Multiplication> get practiceSet => _practiceSet;
  int get currentPracticeIndex => _currentPracticeIndex;
  bool get isPracticeComplete => _answerHistory.length >= PRACTICE_SET_SIZE;
  Multiplication? get currentMultiplication => _currentMultiplication;
  List<AnswerRecord> get answerHistory => _answerHistory;

  // Constructor
  MultiplicationProvider({required this.settingsProvider})
    : _currentSettings = settingsProvider.settings {
    settingsProvider.addListener(onSettingsChanged);
    _loadMultiplications();
  }

  List<Multiplication> get multiplications => _multiplications;

  void setMultiplications(List<Multiplication> multiplications) {
    _multiplications = multiplications;
    notifyListeners();
  }

  // Reset practice session
  void resetPractice() {
    _practiceSet.clear();
    _currentPracticeIndex = 0;
    _answerHistory.clear();
    notifyListeners();
  }

  // Set random current multiplication
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

  // Start practice session
  void startPracticeSession() {
    // Reset current session
    _currentPracticeIndex = 0;
    _answerHistory.clear();
    _practiceSet.clear();

    if (_multiplications.isEmpty) {
      generateMultipleQuestions(100);
    }

    // Randomly select 10 questions from current multiplications
    final random = Random();
    final availableIndices = List.generate(_multiplications.length, (i) => i);

    while (_practiceSet.length < PRACTICE_SET_SIZE &&
        availableIndices.isNotEmpty) {
      final randomIndex = random.nextInt(availableIndices.length);
      final questionIndex = availableIndices[randomIndex];
      _practiceSet.add(_multiplications[questionIndex]);
      availableIndices.removeAt(randomIndex);
    }

    // Set first question
    if (_practiceSet.isNotEmpty) {
      _currentMultiplication = _practiceSet[0];
    }

    notifyListeners();
  }

  // Load multiplications from SharedPreferences
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
          await _generateMultipleQuestionsAsync(100);
        } else {
          // Nếu cài đặt không thay đổi, đọc danh sách từ SharedPreferences
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
            await _generateMultipleQuestionsAsync(100);
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

  // Generate multiple questions
  void generateMultipleQuestions(int count) {
    final random = Random();

    // Use current settings
    final resultStart = _currentSettings.resultRange.start.toInt();
    final resultEnd = _currentSettings.resultRange.end.toInt();
    final numberStart = _currentSettings.numberRange.start.toInt();
    final numberEnd = _currentSettings.numberRange.end.toInt();

    _multiplications.clear();
    int attempts = 0;
    const maxAttempts = 200;

    while (_multiplications.length < count && attempts < maxAttempts) {
      attempts++;

      // Generate numbers within current number range
      int number1 = numberStart + random.nextInt(numberEnd - numberStart + 1);
      int number2 = numberStart + random.nextInt(numberEnd - numberStart + 1);

      int result = number1 * number2;

      // Verify result is within current result range
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

  // Save multiplications to SharedPreferences
  Future<void> saveMultiplications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedMultiplications =
        _multiplications
            .map((multiplication) => json.encode(multiplication.toJson()))
            .toList();
    await prefs.setStringList('multiplications', encodedMultiplications);
    notifyListeners();
  }

  // Handle settings changes
  void onSettingsChanged() {
    _currentSettings = settingsProvider.settings;

    // Reset practice session
    resetPractice();

    // Tạo danh sách mới trong Future để không chặn UI thread
    Future(() async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Xóa dữ liệu cũ
        await prefs.remove('multiplications');

        // Xóa danh sách cũ
        _multiplications.clear();

        // Tạo danh sách mới trong background
        await _generateMultipleQuestionsAsync(100);

        // Cập nhật phép tính hiện tại và bắt đầu phiên luyện tập mới
        _setRandomCurrentMultiplication();
        startPracticeSession();
      } catch (e) {
        throw Exception(e);
      }
    });
  }

  // Tạo danh sách phép tính bất đồng bộ để không làm đơ UI
  Future<void> _generateMultipleQuestionsAsync(int count) async {
    final random = Random();

    // Lấy thông số cài đặt hiện tại
    final resultStart = _currentSettings.resultRange.start.toInt();
    final resultEnd = _currentSettings.resultRange.end.toInt();
    final numberStart = _currentSettings.numberRange.start.toInt();
    final numberEnd = _currentSettings.numberRange.end.toInt();

    List<Multiplication> newList = [];
    int attempts = 0;
    const maxAttempts = 500;

    // Tạo từng phép tính, nhưng không chặn UI thread
    while (newList.length < count && attempts < maxAttempts) {
      attempts++;

      // Tạo số trong khoảng cho phép
      int number1 = numberStart + random.nextInt(numberEnd - numberStart + 1);
      int number2 = numberStart + random.nextInt(numberEnd - numberStart + 1);

      int result = number1 * number2;

      // Kiểm tra kết quả trong khoảng cho phép
      if (result >= resultStart && result <= resultEnd) {
        Multiplication multiplication = Multiplication(
          number1: number1,
          number2: number2,
          result: result,
          star: 0,
        );

        if (!newList.contains(multiplication)) {
          newList.add(multiplication);
        }
      }

      // Cho phép UI cập nhật mỗi 20 phép tính
      if (newList.length % 20 == 0) {
        await Future.delayed(Duration.zero);
      }
    }

    // Cập nhật danh sách và lưu vào SharedPreferences
    _multiplications = newList;

    // Lưu danh sách mới vào SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedMultiplications =
        _multiplications
            .map((multiplication) => json.encode(multiplication.toJson()))
            .toList();

    await prefs.setStringList('multiplications', encodedMultiplications);

    // Lưu cài đặt hiện tại
    await prefs.setInt('resultRangeStart', resultStart);
    await prefs.setInt('resultRangeEnd', resultEnd);
    await prefs.setInt('numberRangeStart', numberStart);
    await prefs.setInt('numberRangeEnd', numberEnd);

    notifyListeners();
  }

  // Update star count for a multiplication
  void updateStar(bool isCorrect) {
    if (_currentMultiplication != null) {
      final index = _multiplications.indexWhere(
        (m) =>
            m.number1 == _currentMultiplication!.number1 &&
            m.number2 == _currentMultiplication!.number2,
      );

      if (index != -1) {
        // Lấy số sao hiện tại
        int currentStar = _multiplications[index].star;

        // Tăng số sao nếu đúng, giảm nếu sai
        int newStar = isCorrect ? currentStar + 1 : currentStar - 1;

        // Giới hạn số sao từ 0-5
        newStar = newStar.clamp(0, 5);

        // Cập nhật phép tính
        _multiplications[index] = Multiplication(
          number1: _currentMultiplication!.number1,
          number2: _currentMultiplication!.number2,
          result: _currentMultiplication!.result,
          star: newStar,
        );

        _currentMultiplication = _multiplications[index];

        // Tăng chỉ số câu hỏi hiện tại
        _currentPracticeIndex++;

        notifyListeners();
      }
    }
  }

  // Update current multiplication
  Future<void> updateCurrentMultiplication(
    Multiplication newMultiplication,
  ) async {
    try {
      if (_multiplications.isEmpty) {
        // Nếu list trống, tạo mới danh sách nhỏ trước để tránh đơ
        generateMultipleQuestions(10);
      }

      if (_multiplications.isNotEmpty) {
        var random = Random();
        int maxAttempts = 10; // Giới hạn số lần thử để tránh vòng lặp vô hạn
        int attempts = 0;
        var newIndex = random.nextInt(_multiplications.length);

        // Đảm bảo lấy được một phép tính khác và tránh vòng lặp vô hạn
        while (attempts < maxAttempts &&
            _multiplications.length > 1 &&
            (_multiplications[newIndex].number1 ==
                    _currentMultiplication?.number1 &&
                _multiplications[newIndex].number2 ==
                    _currentMultiplication?.number2)) {
          newIndex = random.nextInt(_multiplications.length);
          attempts++;

          // Cho phép UI cập nhật nếu phải thử nhiều lần
          if (attempts % 5 == 0) {
            await Future.delayed(Duration.zero);
          }
        }

        // Đảm bảo _currentMultiplication không bị null
        if (_multiplications.length > newIndex) {
          _currentMultiplication = _multiplications[newIndex];
          notifyListeners();
        }
      }
    } catch (e) {
      // Bảo vệ khỏi lỗi, đảm bảo luôn có phép tính
      if (_currentMultiplication == null && _multiplications.isNotEmpty) {
        _currentMultiplication = _multiplications.first;
        notifyListeners();
      }
    }
  }

  // Ghi lại lịch sử trả lời
  void recordAnswer(bool isCorrect, int selectedAnswer) {
    if (_currentMultiplication != null) {
      // Chỉ ghi nhận câu trả lời nếu chưa đủ 10 câu
      if (_answerHistory.length < PRACTICE_SET_SIZE) {
        _answerHistory.add(
          AnswerRecord(
            number1: _currentMultiplication!.number1,
            number2: _currentMultiplication!.number2,
            result: _currentMultiplication!.result,
            selectedAnswer: selectedAnswer,
            isCorrect: isCorrect,
          ),
        );

        // Cập nhật số sao và chỉ số câu hỏi hiện tại
        updateStar(isCorrect);

        // Nếu chưa đủ 10 câu, chuyển sang câu tiếp theo
        if (_answerHistory.length < PRACTICE_SET_SIZE &&
            _currentPracticeIndex < _practiceSet.length) {
          _currentMultiplication = _practiceSet[_currentPracticeIndex];
        }

        notifyListeners();
      }
    }
  }

  // Lấy số câu đúng và số câu sai
  int get correctAnswers =>
      _answerHistory.where((record) => record.isCorrect).length;
  int get wrongAnswers =>
      _answerHistory.where((record) => !record.isCorrect).length;
}

class AnswerRecord {
  int number1;
  int number2;
  int result; // correct result
  int selectedAnswer; // user's selected answer
  final bool isCorrect;

  AnswerRecord({
    required this.number1,
    required this.number2,
    required this.result,
    required this.selectedAnswer,
    required this.isCorrect,
  });
}

class AnswerRecordProvider extends ChangeNotifier {
  List<AnswerRecord> listAnswer = [];
  void addAnswer({
    required int number1,
    required int number2,
    required int result,
    required bool isCorrect,
  }) {
    AnswerRecord a = AnswerRecord(
      number1: number1,
      number2: number2,
      result: result,
      selectedAnswer: 0,
      isCorrect: isCorrect,
    );
    listAnswer.add(a);
    notifyListeners();
  }

  void cleanAnswer() {
    listAnswer.clear();
  }
}
