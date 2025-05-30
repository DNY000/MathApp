import 'package:flutter/material.dart';

class SettingsModel {
  bool isMultiplication; // A x B mode
  RangeValues resultRange;
  RangeValues numberRange;
  bool checkAnswer;
  bool checkNumberRange;
  double practicePercentage;
  bool showBlocks;
  int answerTimeSeconds;
  int processingDivison;
  int processingMul;
  int sumCount;
  SettingsModel({
    this.isMultiplication = true,
    this.resultRange = const RangeValues(1, 90000),
    this.numberRange = const RangeValues(1, 300),
    this.checkAnswer = false,
    this.checkNumberRange = false,
    this.practicePercentage = 20,
    this.showBlocks = true,
    this.answerTimeSeconds = 15,
    this.processingDivison = 0,
    this.processingMul = 0,
    this.sumCount = 1,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'isMultiplication': isMultiplication,
      'resultRangeStart': resultRange.start,
      'resultRangeEnd': resultRange.end,
      'numberRangeStart': numberRange.start,
      'numberRangeEnd': numberRange.end,
      'checkNumberRange': checkNumberRange,
      'checkAnswer': checkAnswer,
      'practicePercentage': practicePercentage,
      'showBlocks': showBlocks,
      'answerTimeSeconds': answerTimeSeconds,
      'processingDivison': processingDivison,
      'processingMul': processingMul,
      'sumCount': sumCount,
    };
  }

  // Create from JSON
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      isMultiplication: json['isMultiplication'] ?? true,
      resultRange: RangeValues(
        json['resultRangeStart']?.toDouble() ?? 1,
        json['resultRangeEnd']?.toDouble() ?? 1000,
      ),
      numberRange: RangeValues(
        json['numberRangeStart']?.toDouble() ?? 1,
        json['numberRangeEnd']?.toDouble() ?? 300,
      ),
      checkAnswer: json['checkAnswer'] ?? false,
      checkNumberRange: json['checkNumberRange'] ?? false,
      practicePercentage: json['practicePercentage']?.toDouble() ?? 20,
      showBlocks: json['showBlocks'] ?? true,
      answerTimeSeconds: json['answerTimeSeconds'] ?? 15,
      processingDivison: json['processingDivison'] ?? 0.0,
      processingMul: json['processingMul'] ?? 0.0,
      sumCount: json['sumCount'] ?? 1,
    );
  }

  // Copy with method for immutability
  SettingsModel copyWith({
    bool? isMultiplication,
    RangeValues? resultRange,
    RangeValues? numberRange,
    bool? checkAnswer,
    double? practicePercentage,
    bool? showBlocks,
    int? answerTimeSeconds,
    String? operator,
    bool? checkNumberRange,
    int? processingDivison,
    int? processingMul,
    int? sumCount,
  }) {
    return SettingsModel(
      isMultiplication: isMultiplication ?? this.isMultiplication,
      resultRange: resultRange ?? this.resultRange,
      numberRange: numberRange ?? this.numberRange,
      checkNumberRange: checkNumberRange ?? this.checkNumberRange,
      checkAnswer: checkAnswer ?? this.checkAnswer,
      practicePercentage: practicePercentage ?? this.practicePercentage,
      showBlocks: showBlocks ?? this.showBlocks,
      answerTimeSeconds: answerTimeSeconds ?? this.answerTimeSeconds,
      processingDivison: processingDivison ?? this.processingDivison,
      processingMul: processingMul ?? this.processingMul,
      sumCount: sumCount ?? this.sumCount,
    );
  }
}
