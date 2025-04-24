import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:math_app/models/division.dart';
import 'package:math_app/models/settings_model.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DivisionProvider with ChangeNotifier {
  List<Division> _divisions = [];
  Division? _currentDivision;
  final SettingsProvider settingsProvider;
  late SettingsModel _currentSettings;
  final List<AnswerRecord> _answerHistory = [];
  final List<AnswerRecord> _currentSessionAnswers = [];

  // Practice properties
  List<Division> _practiceSet = [];
  int _currentPracticeIndex = 0;
  static const int PRACTICE_SET_SIZE = 10;
  int _correctAnswersCount = 0;

  // Getters
  List<Division> get divisions => _divisions;
  Division? get currentDivision => _currentDivision;
  List<AnswerRecord> get answerHistory => _answerHistory;
  List<AnswerRecord> get currentSessionAnswers => _currentSessionAnswers;
  bool get isPracticeComplete => _correctAnswersCount >= PRACTICE_SET_SIZE;
  int get correctAnswersCount => _correctAnswersCount;
  int get wrongAnswersCount =>
      _currentSessionAnswers.length - _correctAnswersCount;

  DivisionProvider({required this.settingsProvider}) {
    _currentSettings = settingsProvider.settings;
    settingsProvider.addListener(onSettingsChanged);
    _initializeData();
  }

  void onSettingsChanged() {
    // Thay vì gán trực tiếp, chỉ cập nhật giá trị của _currentSettings
    final newSettings = settingsProvider.settings;
    if (_currentSettings != newSettings) {
      _currentSettings = newSettings;

      // Reset practice session
      resetPractice();

      // Tạo danh sách mới trong Future để không chặn UI thread
      Future(() async {
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          // Xóa dữ liệu cũ
          await prefs.remove('divisions');

          // Xóa danh sách cũ
          _divisions.clear();
          _currentDivision = null;

          // Tạo danh sách mới trong background
          await generateMultipleQuestions(100);

          // Cập nhật phép tính hiện tại và bắt đầu phiên luyện tập mới
          _setRandomCurrentDivision();
          startPracticeSession();
        } catch (e) {
          throw Exception(e);
        }
      });
    }
  }

  Future<void> _initializeData() async {
    await _loadDivisions();
    if (_divisions.isEmpty) {
      await generateMultipleQuestions(100);
    }
    startPracticeSession();
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

    if (_divisions.isEmpty) {
      generateMultipleQuestions(100);
      return;
    }

    // Randomly select questions based on settings
    final random = Random();
    final availableIndices = List.generate(_divisions.length, (i) => i);

    while (_practiceSet.length < PRACTICE_SET_SIZE &&
        availableIndices.isNotEmpty) {
      final randomIndex = random.nextInt(availableIndices.length);
      final questionIndex = availableIndices[randomIndex];
      _practiceSet.add(_divisions[questionIndex]);
      availableIndices.removeAt(randomIndex);
    }

    if (_practiceSet.isNotEmpty) {
      _currentDivision = _practiceSet[0];
      notifyListeners();
    }
  }

  // Record answer and handle UI updates
  Future<void> recordAnswer(int selectedAnswer) async {
    if (_currentDivision == null) return;

    final bool isCorrect = selectedAnswer == _currentDivision!.result;

    // Create answer record
    final answerRecord = AnswerRecord(
      number1: _currentDivision!.number1,
      number2: _currentDivision!.number2,
      result: _currentDivision!.result,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
    );

    // Add to history
    _answerHistory.add(answerRecord);
    _currentSessionAnswers.add(answerRecord);

    if (isCorrect) {
      _correctAnswersCount++;

      // Update star rating
      _updateStar(true);

      // Wait for visual feedback
      await Future.delayed(const Duration(seconds: 1));

      // Move to next question if not complete
      if (!isPracticeComplete) {
        if (_currentPracticeIndex < _practiceSet.length - 1) {
          _currentPracticeIndex++;
          _currentDivision = _practiceSet[_currentPracticeIndex];
        } else {
          startPracticeSession();
        }
      }
    } else {
      _updateStar(false);
    }

    notifyListeners();
  }

  // Update star rating
  void _updateStar(bool isCorrect) {
    if (_currentDivision == null) return;

    final index = _divisions.indexWhere(
      (d) =>
          d.number1 == _currentDivision!.number1 &&
          d.number2 == _currentDivision!.number2,
    );

    if (index != -1) {
      int currentStar = _divisions[index].star;
      int newStar = isCorrect ? currentStar + 1 : currentStar - 1;
      newStar = newStar.clamp(0, 5);

      _divisions[index] = Division(
        number1: _currentDivision!.number1,
        number2: _currentDivision!.number2,
        result: _currentDivision!.result,
        star: newStar,
      );

      _currentDivision = _divisions[index];
      saveDivisions();
    }
  }

  Future<void> generateMultipleQuestions(int count) async {
    final random = Random();

    // Lấy khoảng từ settings
    final resultStart = settingsProvider.settings.resultRange.start.toInt();
    final resultEnd = settingsProvider.settings.resultRange.end.toInt();
    final numberStart = settingsProvider.settings.numberRange.start.toInt();
    final numberEnd = settingsProvider.settings.numberRange.end.toInt();

    _divisions.clear();
    int attempts = 0;
    const maxAttempts = 1000;

    while (_divisions.length < count && attempts < maxAttempts) {
      attempts++;

      // 1. Random thương số (result) trong khoảng numberRange
      int result = numberStart + random.nextInt(numberEnd - numberStart + 1);

      // 2. Random số bị chia (number1) trong khoảng resultRange
      int number1 = resultStart + random.nextInt(resultEnd - resultStart + 1);

      // 3. Tính số chia (number2) = số bị chia / thương số
      if (result != 0 && number1 % result == 0) {
        int number2 = number1 ~/ result;

        // Kiểm tra số chia có trong khoảng cho phép
        if (number2 >= numberStart && number2 <= numberEnd) {
          Division division = Division(
            number1: number1, // số bị chia
            number2: number2, // số chia
            result: result, // thương số
            star: 0,
          );

          if (!_divisions.contains(division)) {
            _divisions.add(division);
          }
        }
      }

      // Cho phép UI cập nhật sau mỗi 20 phép tính
      if (_divisions.length % 20 == 0) {
        await Future.delayed(Duration.zero);
      }
    }

    await saveDivisions();
    notifyListeners();
  }

  Future<void> _setRandomCurrentDivision() async {
    if (_divisions.isEmpty) {
      generateMultipleQuestions(10);
      return;
    }

    if (_divisions.isNotEmpty) {
      final random = Random();
      int maxAttempts = 10;
      int attempts = 0;
      int newIndex = random.nextInt(_divisions.length);

      // Đảm bảo lấy phép tính khác với phép tính hiện tại
      while (attempts < maxAttempts &&
          _divisions.length > 1 &&
          _currentDivision != null &&
          _divisions[newIndex].number1 == _currentDivision!.number1 &&
          _divisions[newIndex].number2 == _currentDivision!.number2) {
        newIndex = random.nextInt(_divisions.length);
        attempts++;
      }

      if (_divisions.length > newIndex) {
        _currentDivision = _divisions[newIndex];
        notifyListeners();
      }
    }
  }

  Future<void> updateCurrentDivision(Division currentDivision) async {
    try {
      if (_divisions.isEmpty) {
        generateMultipleQuestions(10);
      }

      if (_divisions.isNotEmpty) {
        final random = Random();
        int maxAttempts = 10;
        int attempts = 0;
        int newIndex = random.nextInt(_divisions.length);

        while (attempts < maxAttempts &&
            _divisions.length > 1 &&
            _divisions[newIndex].number1 == _currentDivision?.number1 &&
            _divisions[newIndex].number2 == _currentDivision?.number2) {
          newIndex = random.nextInt(_divisions.length);
          attempts++;
        }

        if (_divisions.length > newIndex) {
          _currentDivision = _divisions[newIndex];
          notifyListeners();
        }
      }
    } catch (e) {
      if (_currentDivision == null && _divisions.isNotEmpty) {
        _currentDivision = _divisions.first;
        notifyListeners();
      }
    }
  }

  Future<void> _loadDivisions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? encodedDivisions = prefs.getStringList('divisions');

      if (encodedDivisions != null && encodedDivisions.isNotEmpty) {
        _divisions =
            encodedDivisions
                .map((e) => Division.fromJson(json.decode(e)))
                .toList();

        if (_divisions.isNotEmpty) {
          final random = Random();
          _currentDivision = _divisions[random.nextInt(_divisions.length)];
        } else {
          generateMultipleQuestions(100);
        }
      } else {
        generateMultipleQuestions(100);
      }

      notifyListeners();
    } catch (e) {
      // Tạo mặc định nếu có lỗi
      generateMultipleQuestions(10);
    }
  }

  Future<void> saveDivisions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedDivisions =
        _divisions.map((division) => json.encode(division.toJson())).toList();
    await prefs.setStringList('divisions', encodedDivisions);
    notifyListeners();
  }

  Future<void> cleanListDivision() async {
    _divisions.clear();
    _currentDivision = null;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('divisions');
    notifyListeners();
  }

  int getTotalStars() {
    return _divisions.fold(0, (sum, division) => sum + division.star);
  }

  int getStarCount(int number1, int number2) {
    final division = _divisions.firstWhere(
      (d) => d.number1 == number1 && d.number2 == number2,
      orElse:
          () => Division(
            number1: number1,
            number2: number2,
            result: number1 ~/ number2,
            star: 0,
          ),
    );
    return division.star;
  }
}
