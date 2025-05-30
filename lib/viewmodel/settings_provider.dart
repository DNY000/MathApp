import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../core/shared_preferences/shared_prefs.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _settingsKey = 'math_app_settings';
  late SettingsModel _settings;

  SettingsModel get settings => _settings;

  // Initialize settings
  Future<void> init() async {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  void _loadSettings() {
    final settingsData = SharedPrefs.instance.getObject<SettingsModel>(
      _settingsKey,
      (json) => SettingsModel.fromJson(json),
    );
    _settings = settingsData ?? SettingsModel();
    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    await SharedPrefs.instance.saveObject<SettingsModel>(
      _settingsKey,
      _settings,
      SettingsModel.fromJson,
    );
  }

  // Notify all listeners that settings have changed
  // void notifySettingsChanged() {
  //   notifyListeners();
  // }

  // Update methods for each setting
  void updateMode(bool isMultiplication) {
    _settings = _settings.copyWith(isMultiplication: isMultiplication);
    _saveSettings();
    notifyListeners();
    // notifySettingsChanged();
  }

  void updateProcessing(bool isMultiplication, int processing) {
    if (isMultiplication) {
      _settings = _settings.copyWith(processingMul: processing);
    } else {
      _settings = _settings.copyWith(processingDivison: processing);
    }
    _saveSettings();
    notifyListeners();
    // notifySettingsChanged();
  }

  void updateResultRange(RangeValues range) {
    final numberRange = _settings.numberRange;
    if (range.start < numberRange.start || range.end < numberRange.end) {
      final adjustedRange = RangeValues(1, 90000);
      _settings = _settings.copyWith(resultRange: adjustedRange);
    } else {
      final litmitedRange = RangeValues(
        range.start < 1
            ? 1
            : range.start > range.end
            ? 1
            : range.start,
        range.end > 90000 ? 90000 : range.end,
      );
      _settings = _settings.copyWith(resultRange: litmitedRange);
    }
    _saveSettings();
    notifyListeners();
  }

  void updateNumberRange(RangeValues range) {
    final limitedRange = RangeValues(
      range.start < 1
          ? 1
          : range.start > range.end
          ? 1
          : range.start,
      range.end > 300 ? 300 : range.end,
    );
    _settings = _settings.copyWith(numberRange: limitedRange);
    _saveSettings();
    notifyListeners();
    // notifySettingsChanged();
  }

  void updateCheckAnswer(bool value) {
    _settings = _settings.copyWith(checkAnswer: value);
    _saveSettings();
    notifyListeners();
    // notifySettingsChanged();
  }

  void updateCheckNumberRange(bool value) {
    _settings = _settings.copyWith(checkNumberRange: value);
    _saveSettings();
    notifyListeners();
    // notifySettingsChanged();
  }

  void updatePracticePercentage(double value) {
    _settings = _settings.copyWith(practicePercentage: value);
    _saveSettings();
    notifyListeners();
    // notifySettingsChanged();
  }

  void updateShowBlocks(bool value) {
    _settings = _settings.copyWith(showBlocks: value);
    _saveSettings();
    notifyListeners();
    // notifySettingsChanged();
  }

  void updateAnswerTime(int seconds) {
    _settings = _settings.copyWith(answerTimeSeconds: seconds);
    _saveSettings();
    notifyListeners();
    // notifySettingsChanged();
  }

  // Reset settings to defaults
  Future<void> resetSettings() async {
    _settings = SettingsModel();
    await _saveSettings();
    notifyListeners();
    // notifySettingsChanged();
  }

  Future<void> resetStar() async {
    _settings = _settings.copyWith(processingDivison: 0, processingMul: 0);
    await _saveSettings();
    notifyListeners();
  }
}
