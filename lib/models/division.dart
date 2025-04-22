// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Division {
  int number1;
  int number2;
  int result;
  int star;
  Division({
    required this.number1,
    required this.number2,
    required this.result,
    this.star = 0,
  });
  Map<String, dynamic> toMap() {
    return {
      'number1': number1,
      'number2': number2,
      'result': result,
      'star': star,
    };
  }

  factory Division.fromMap(Map<String, dynamic> map) {
    return Division(
      number1: map['number1'],
      number2: map['number2'],
      result: map['result'],
      star: map['star'],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Division.fromJson(String source) =>
      Division.fromMap(jsonDecode(source));
}
