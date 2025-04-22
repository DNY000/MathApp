import 'dart:math';
import 'package:flutter/material.dart';
import 'package:math_app/models/division.dart';
import 'package:math_app/viewmodel/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DivisionProvider with ChangeNotifier {
  SettingsProvider settingsProvider = SettingsProvider();
  List<Division> _divisions = [];
  Division? _currentDivision;

  List<Division> get divisions => _divisions;
  Division? get currentDivision => _currentDivision;

  DivisionProvider() {
    _loadDivisions();
  }

  // Load divisions from SharedPreferences
  Future<void> _loadDivisions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedDivisions = prefs.getStringList('divisions');
    if (encodedDivisions != null) {
      _divisions = encodedDivisions.map((e) => Division.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveDivisions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedDivisions =
        _divisions.map((division) => division.toJson()).toList();
    await prefs.setStringList('divisions', encodedDivisions);
    notifyListeners();
  }

  void generateRandomQuestion() {
    final random = Random();
    int number1 = random.nextInt(9) + 1;
    int number2 = random.nextInt(9) + 1;
    int result = number1 ~/ number2;

    _currentDivision = Division(
      number1: number1,
      number2: number2,
      result: result,
    );
    notifyListeners();
  }

  // Update the star rating for a division
  void updateStar(bool isCorrect) {
    if (_currentDivision != null) {
      if (isCorrect) {
        if (_currentDivision!.star < 5) _currentDivision!.star++;
      } else {
        if (_currentDivision!.star > 0) _currentDivision!.star--;
      }

      // Save the division again after updating the star
      _saveDivisions();
    }
  }

  // Add a new division if it doesn't exist
  void addDivisionIfNew(Division division) {
    if (!_divisions.contains(division)) {
      _divisions.add(division);
      _saveDivisions();
    }
  }

  // Generate multiple answers including the correct one
  List<int> generateAnswers() {
    if (_currentDivision == null) return [];

    List<int> answers = [_currentDivision!.result];
    while (answers.length < 4) {
      int wrongAnswer = Random().nextInt(10);
      if (!answers.contains(wrongAnswer)) {
        answers.add(wrongAnswer);
      }
    }
    answers.shuffle();
    return answers;
  }
}
