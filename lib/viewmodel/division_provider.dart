import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:math_app/models/division.dart';
import 'package:math_app/models/settings_model.dart';
import 'package:math_app/viewmodel/multiplication_provider.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DivisionProvider with ChangeNotifier {
  List<Division> _divisions = []; // danh sách phép chia chính
  Division? _currentDivision; //  phép chia hiện tại
  final SettingsProvider settingsProvider; // khởi tạo  provider setting
  SettingsModel _currentSettings; // setting hiện tại
  final List<AnswerRecord> answerHistory = []; //list câu hỏi
  List<Division> _practiceSet = []; // List phép tính random trong luyện tập
  List<Division> listAnswerTesting = []; //list câu hỏi trong  kiểm tra
  int _currentPracticeIndex = 0; // vị trị phép tính hiện tại
  // ignore: constant_identifier_names
  static const int PRACTICE_SET_SIZE = 10; // giá trị mặc định khi chuyển màn
  int _correctAnswersCount = 0; // số câu trả lời đúng
  List<Division> _currentDivisions =
      []; // List này lấy ra số phép tính trong bảng tính

  // Getters
  List<Division> get currentDivisions => _currentDivisions;
  List<Division> get practiceSet => _practiceSet;
  int get currentPracticeIndex => _currentPracticeIndex;
  bool get isPracticeComplete => _correctAnswersCount >= PRACTICE_SET_SIZE;
  Division? get currentDivision => _currentDivision;
  int get correctAnswersCount => _correctAnswersCount;
  int get wrongAnswersCount =>
      answerHistory.where((record) => !record.isCorrect).length;

  DivisionProvider({required this.settingsProvider})
    : _currentSettings = settingsProvider.settings {
    settingsProvider.addListener(_onSettingsChanged);
    _loadDivisions();
  }
  @override
  void dispose() {
    settingsProvider.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    // print("Settings changed - Reloading divisions");
    _currentSettings = settingsProvider.settings;
    _loadDivisions();
  }

  List<Division> get divisions => _divisions;

  List<Division> get10AnswerDivison() {
    if (_divisions.isEmpty) {
      generateMultipleQuestions(100);
    }
    final List<Division> tempList = List.from(_divisions);
    tempList.shuffle();
    return tempList.take(10).toList();
  }

  List<Division> dsnumber(int number) {
    _currentDivisions = List.generate(12, (index) {
      final existingDivision = _divisions.firstWhere(
        (element) => element.number1 == number && element.number2 == index,
        orElse:
            () => Division(
              number1: number * index,
              number2: index,
              result: number,
              star: 0,
            ),
      );
      return existingDivision;
    });
    notifyListeners();
    return _currentDivisions;
  }

  void resetPractice() {
    _practiceSet.clear();
    _currentPracticeIndex = 0;
    _correctAnswersCount = 0;
    _currentDivision = null;
    answerHistory.clear();
    notifyListeners();
  }

  void resetAndStartNewPractice() {
    resetPractice();

    if (_divisions.isEmpty) {
      generateMultipleQuestions(100);
    }

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
    }

    notifyListeners();
  }

  void startPracticeSession() {
    resetPractice();
    notifyListeners();
    if (_divisions.isEmpty) {
      return;
    }

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
    }

    notifyListeners();
  }

  Future<void> _loadDivisions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final currentResultStart = _currentSettings.resultRange.start.toInt();
      final currentResultEnd = _currentSettings.resultRange.end.toInt();
      final currentNumberStart = _currentSettings.numberRange.start.toInt();
      final currentNumberEnd = _currentSettings.numberRange.end.toInt();

      final savedResultStart = prefs.getInt('resultRangeStart') ?? -1;
      final savedResultEnd = prefs.getInt('resultRangeEnd') ?? -1;
      final savedNumberStart = prefs.getInt('numberRangeStart') ?? -1;
      final savedNumberEnd = prefs.getInt('numberRangeEnd') ?? -1;

      final settingsChanged =
          savedResultStart != currentResultStart ||
          savedResultEnd != currentResultEnd ||
          savedNumberStart != currentNumberStart ||
          savedNumberEnd != currentNumberEnd;

      await Future(() async {
        resetPractice();

        if (settingsChanged) {
          await prefs.remove('divisions');
          _divisions.clear();

          await prefs.setInt('resultRangeStart', currentResultStart);
          await prefs.setInt('resultRangeEnd', currentResultEnd);
          await prefs.setInt('numberRangeStart', currentNumberStart);
          await prefs.setInt('numberRangeEnd', currentNumberEnd);

          generateMultipleQuestions(100);
        } else {
          List<String>? encodedDivisions = prefs.getStringList('divisions');

          if (encodedDivisions != null && encodedDivisions.isNotEmpty) {
            _divisions =
                encodedDivisions
                    .map((e) => Division.fromJson(json.decode(e)))
                    .toList();
          } else {
            generateMultipleQuestions(100);
          }
        }

        _setRandomCurrentDivision();
        startPracticeSession();
        notifyListeners();
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  void generateMultipleQuestions(int count) {
    final random = Random();

    final resultStart = _currentSettings.resultRange.start.toInt();
    final resultEnd = _currentSettings.resultRange.end.toInt();
    final numberStart = _currentSettings.numberRange.start.toInt();
    final numberEnd = _currentSettings.numberRange.end.toInt();

    int attempts = 0;
    const maxAttempts = 200;

    while (_divisions.length < count && attempts < maxAttempts) {
      attempts++;

      int number1 = numberStart + random.nextInt(numberEnd - numberStart + 1);
      int number2 = numberStart + random.nextInt(numberEnd - numberStart + 1);

      if (number2 != 0 && number1 % number2 == 0) {
        int result = number1 ~/ number2;

        if (result >= resultStart && result <= resultEnd) {
          Division division = Division(
            number1: number1,
            number2: number2,
            result: result,
            star: 0,
          );

          if (!_divisions.contains(division)) {
            _divisions.add(division);
          }
        }
      }
    }

    saveDivisions();
    notifyListeners();
  }

  Future<void> saveDivisions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedDivisions =
        _divisions.map((division) => json.encode(division.toJson())).toList();
    await prefs.setStringList('divisions', encodedDivisions);
    notifyListeners();
  }

  Future<void> recordAnswer(int selectedAnswer) async {
    if (_currentDivision == null) return;

    final bool isCorrect = selectedAnswer == _currentDivision!.result;

    final answerRecord = AnswerRecord(
      number1: _currentDivision!.number1,
      number2: _currentDivision!.number2,
      result: _currentDivision!.result,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      start: _currentDivision!.star,
    );

    answerHistory.add(answerRecord);
    // sessionAnswerHistory.add(answerRecord);

    if (isCorrect) {
      _correctAnswersCount++;
      updateStar(true);
      if (_currentPracticeIndex < _practiceSet.length - 1) {
        _currentPracticeIndex++;
        _currentDivision = _practiceSet[_currentPracticeIndex];
      }

      // Chỉ notify khi trả lời đúng để cập nhật UI và chuyển câu mới
      notifyListeners();
    } else {
      // Chỉ cập nhật sao mà không notify để tránh random lại giao diện
      updateStarWithoutNotify(false);
      // Không chuyển sang phép tính tiếp theo khi trả lời sai
    }
  }

  // Update star mà không gọi notifyListeners để tránh render lại UI
  void updateStarWithoutNotify(bool isCorrect) {
    if (_currentDivision == null) return;

    final index = _divisions.indexWhere(
      (d) =>
          d.number1 == _currentDivision!.number1 &&
          d.number2 == _currentDivision!.number2,
    );

    if (index != -1) {
      int currentStar = _divisions[index].star;
      int newStar = currentStar;

      if (isCorrect) {
        if (currentStar < 5) {
          newStar = currentStar + 1;
        }
      } else {
        if (currentStar > 0) {
          newStar = currentStar - 1;
        }
      }

      _divisions[index] = Division(
        number1: _currentDivision!.number1,
        number2: _currentDivision!.number2,
        result: _currentDivision!.result,
        star: newStar,
      );

      _currentDivision = _divisions[index];

      // Lưu thay đổi vào SharedPreferences không gọi notifyListeners
      saveDivisionsWithoutNotify();
    }
  }

  // Phiên bản của saveDivisions không gọi notifyListeners
  Future<void> saveDivisionsWithoutNotify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedDivisions =
        _divisions.map((division) => json.encode(division.toJson())).toList();
    await prefs.setStringList('divisions', encodedDivisions);
    // Không gọi notifyListeners để tránh UI render lại
  }

  void updateStar(bool isCorrect) {
    if (_currentDivision == null) return;

    final index = _divisions.indexWhere(
      (d) =>
          d.number1 == _currentDivision!.number1 &&
          d.number2 == _currentDivision!.number2,
    );

    if (index != -1) {
      int currentStar = _divisions[index].star;
      int newStar = currentStar;

      if (isCorrect) {
        if (currentStar < 5) {
          newStar = currentStar + 1;
        }
      } else {
        if (currentStar > 0) {
          newStar = currentStar - 1;
        }
      }

      _divisions[index] = Division(
        number1: _currentDivision!.number1,
        number2: _currentDivision!.number2,
        result: _currentDivision!.result,
        star: newStar,
      );

      _currentDivision = _divisions[index];
      saveDivisions();
      notifyListeners();
    }
  }

  void _setRandomCurrentDivision() {
    try {
      if (_divisions.isNotEmpty) {
        final random = Random();
        _currentDivision = _divisions[random.nextInt(_divisions.length)];
        notifyListeners();
      }
    } catch (e) {
      throw (Exception(e));
    }
  }

  void retryCorrectAnswers() {
    final correctAnswers =
        answerHistory.where((record) => record.isCorrect).toList();

    if (correctAnswers.isEmpty) return;

    _practiceSet =
        correctAnswers.map((record) {
          return Division(
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
    _currentDivision = _practiceSet[0];
    _correctAnswersCount = 0;
    answerHistory.clear();
    notifyListeners();
  }

  int sumStar(List<Division> list) {
    return list.fold(
      0,
      (previousValue, division) => previousValue + division.star,
    );
  }

  Future<void> resetAllStars() async {
    try {
      for (int i = 0; i < _divisions.length; i++) {
        if (_divisions[i].star > 0) {
          _divisions[i] = Division(
            number1: _divisions[i].number1,
            number2: _divisions[i].number2,
            result: _divisions[i].result,
            star: 0,
          );
        }
      }

      await saveDivisions();
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    }
  }
}
