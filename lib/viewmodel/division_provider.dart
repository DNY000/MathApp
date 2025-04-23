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
  late final SettingsModel _currentSettings;
  final List<AnswerRecord> _answerHistory = [];

  // Getters
  List<Division> get divisions => _divisions;
  Division? get currentDivision => _currentDivision;
  List<AnswerRecord> get answerHistory => _answerHistory;

  // Add getters for correct and wrong answers count
  int get correctAnswers =>
      _answerHistory.where((record) => record.isCorrect).length;
  int get wrongAnswers =>
      _answerHistory.where((record) => !record.isCorrect).length;

  // Add method to record answers
  void recordAnswer(bool isCorrect, int selectedAnswer) {
    if (_currentDivision != null) {
      _answerHistory.add(
        AnswerRecord(
          number1: _currentDivision!.number1,
          number2: _currentDivision!.number2,
          result: _currentDivision!.result,
          isCorrect: isCorrect,
          selectedAnswer: selectedAnswer,
        ),
      );
      notifyListeners();
    }
  }

  // Add method to clear history when starting new practice
  void clearAnswerHistory() {
    _answerHistory.clear();
    notifyListeners();
  }

  DivisionProvider({required this.settingsProvider}) {
    _currentSettings = settingsProvider.settings;
    _loadDivisions();
  }

  Future<void> onSettingsUpdated() async {
    final newSettings = settingsProvider.settings;
    if (_hasSettingsChanged(newSettings)) {
      _currentSettings = newSettings;
      await cleanListDivision();
      await generateMultipleQuestions(100);
      await _setRandomCurrentDivision();
    }
  }

  bool _hasSettingsChanged(SettingsModel newSettings) {
    return _currentSettings.resultRange != newSettings.resultRange ||
        _currentSettings.numberRange != newSettings.numberRange ||
        _currentSettings.isMultiplication != newSettings.isMultiplication;
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

  Future<void> generateMultipleQuestions(int count) async {
    final random = Random();

    // Lấy khoảng từ settings
    double resultRangeStart = settingsProvider.settings.resultRange.start;
    double resultRangeEnd = settingsProvider.settings.resultRange.end;
    double numberRangeStart = settingsProvider.settings.numberRange.start;
    double numberRangeEnd = settingsProvider.settings.numberRange.end;

    // Chuyển về int để dễ tính toán
    final resultStart = resultRangeStart.toInt();
    final resultEnd = resultRangeEnd.toInt();
    final numberStart = numberRangeStart.toInt();
    final numberEnd = numberRangeEnd.toInt();

    // Xóa danh sách cũ
    _divisions.clear();
    int maxAttempts = 1000;
    int attempts = 0;

    // Tạo phép chia cho đến khi đủ số lượng hoặc đã thử quá nhiều lần
    while (_divisions.length < count && attempts < maxAttempts) {
      attempts++;

      // Tạo số chia (divisor) và thương số (quotient) trước
      int number2 =
          numberStart +
          random.nextInt(numberEnd - numberStart + 1); // số chia (number2)
      int number1 =
          numberStart +
          random.nextInt(numberEnd - numberStart + 1); // thương số (result)

      // Tính số bị chia (dividend) = số chia * thương số
      int result = number1 * number2; // số bị chia (number1)

      // Kiểm tra xem số bị chia có trong khoảng cho phép không
      if (result >= resultStart && result <= resultEnd && number2 != 0) {
        // Tạo đối tượng Division (số bị chia, số chia, thương số)
        Division division = Division(
          number1: result, // số bị chia (dividend)
          number2: number2, // số chia (divisor)
          result: number1, // thương số (quotient)
          star: 0,
        );

        // Thêm vào danh sách nếu chưa tồn tại
        if (!_divisions.contains(division)) {
          _divisions.add(division);
        }

        // Cho phép UI cập nhật sau mỗi 20 phép tính được tạo
        if (_divisions.length % 20 == 0) {
          await Future.delayed(Duration.zero);
        }
      }
    }

    // Nếu không tạo được phép chia nào, thêm ít nhất một phép chia hợp lệ
    if (_divisions.isEmpty) {
      int divisor = numberStart; // Bắt đầu với số chia nhỏ nhất
      int quotient = numberStart; // Bắt đầu với thương số nhỏ nhất
      int dividend = divisor * quotient; // Tính số bị chia

      if (dividend <= resultEnd) {
        _divisions.add(
          Division(
            number1: dividend,
            number2: divisor,
            result: quotient,
            star: 0,
          ),
        );
      }
    }

    // Lưu danh sách vào SharedPreferences
    await saveDivisions();
    notifyListeners();
  }

  Future<void> cleanListDivision() async {
    _divisions.clear();
    _currentDivision = null;
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('divisions');
    notifyListeners();
  }

  void updateStar(int count) {
    if (_currentDivision != null) {
      final index = _divisions.indexWhere(
        (d) =>
            d.number1 == _currentDivision!.number1 &&
            d.number2 == _currentDivision!.number2,
      );

      if (index != -1) {
        _divisions[index] = Division(
          number1: _currentDivision!.number1,
          number2: _currentDivision!.number2,
          result: _currentDivision!.result,
          star: count,
        );
        _currentDivision = _divisions[index];
        saveDivisions();
        notifyListeners();
      }
    }
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
