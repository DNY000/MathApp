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

  // Practice properties
  List<Multiplication> _practiceSet = [];
  int _currentPracticeIndex = 0;
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

  void setMultiplications(List<Multiplication> multiplications) {
    _multiplications = multiplications;
    notifyListeners();
  }

  // lay danh sách các phép tính cố số thứ nhất bằng 2 và số thứ 2 nhỏ hơn hoặc bằng 11
  // dk nữa là số sao lơn hơn 1()
  void dsnumber(int number, List<Multiplication> ds) {
    int n = sumStar(multiplications);
    print('sô soa là $n');
    listByNumber =
        ds
            .where(
              (element) =>
                  element.number1 == 1 &&
                  element.number2 <= 11 &&
                  element.star > 0,
            )
            .toList();
    print(listByNumber.toString());
  }

  // Reset practice session
  void resetPractice() {
    _practiceSet.clear();
    _currentPracticeIndex = 0;
    _currentSessionAnswers.clear();
    _correctAnswersCount = 0;
    notifyListeners();
  }

  // Start new practice session
  void startPracticeSession() {
    resetPractice();

    if (_multiplications.isEmpty) {
      generateMultipleQuestions(100);
    }

    // Randomly select questions based on settings
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

  // Record answer and handle UI updates
  Future<void> recordAnswer(int selectedAnswer) async {
    if (_currentMultiplication == null) return;

    final bool isCorrect = selectedAnswer == _currentMultiplication!.result;

    // Create answer record
    final answerRecord = AnswerRecord(
      number1: _currentMultiplication!.number1,
      number2: _currentMultiplication!.number2,
      result: _currentMultiplication!.result,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
    );

    // Add to history
    _answerHistory.add(answerRecord);
    _currentSessionAnswers.add(answerRecord);

    if (isCorrect) {
      _correctAnswersCount++;

      // Update star rating
      updateStar(true);

      // Wait for visual feedback
      await Future.delayed(const Duration(seconds: 1));

      // Move to next question if not complete
      if (!isPracticeComplete) {
        if (_currentPracticeIndex < _practiceSet.length - 1) {
          _currentPracticeIndex++;
          _currentMultiplication = _practiceSet[_currentPracticeIndex];
        } else {
          startPracticeSession();
        }
      }
    } else {
      updateStar(false);
    }

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
      int newStar = isCorrect ? currentStar + 1 : currentStar - 1;
      newStar = newStar.clamp(0, 5);

      _multiplications[index] = Multiplication(
        number1: _currentMultiplication!.number1,
        number2: _currentMultiplication!.number2,
        result: _currentMultiplication!.result,
        star: newStar,
      );

      _currentMultiplication = _multiplications[index];
    }
  }

  // Retry current session
  void retryCurrentSession() {
    if (_currentSessionAnswers.isEmpty) return;

    // Create new practice set from current session answers
    _practiceSet =
        _currentSessionAnswers
            .map(
              (record) => Multiplication(
                number1: record.number1,
                number2: record.number2,
                result: record.result,
                star: 0,
              ),
            )
            .toList();

    _currentPracticeIndex = 0;
    _currentMultiplication = _practiceSet[0];
    _currentSessionAnswers.clear();
    _correctAnswersCount = 0;

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

  void retryCorrectAnswers() {
    // Lọc ra các câu trả lời đúng từ _answerHistory
    final correctAnswers =
        _answerHistory.where((record) => record.isCorrect).toList();

    if (correctAnswers.isEmpty) return;

    // Tạo practice set mới từ các câu trả lời đúng
    _practiceSet =
        correctAnswers
            .map(
              (record) => Multiplication(
                number1: record.number1,
                number2: record.number2,
                result: record.result,
                star: 0,
              ),
            )
            .toList();

    // Nếu có nhiều hơn PRACTICE_SET_SIZE câu, chọn ngẫu nhiên PRACTICE_SET_SIZE câu
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
