// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Multiplication {
  int number1;
  int number2;
  int result;
  int star;
  Multiplication({
    required this.number1,
    required this.number2,
    required this.result,
    this.star = 0,
  });

  Multiplication copyWith({
    int? number1,
    int? number2,
    int? result,
    int? star,
  }) {
    return Multiplication(
      number1: number1 ?? this.number1,
      number2: number2 ?? this.number2,
      result: result ?? this.result,
      star: star ?? this.star,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'number1': number1,
      'number2': number2,
      'result': result,
      'star': star,
    };
  }

  factory Multiplication.fromMap(Map<String, dynamic> map) {
    return Multiplication(
      number1: map['number1'] as int,
      number2: map['number2'] as int,
      result: map['result'] as int,
      star: map['star'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Multiplication.fromJson(String source) =>
      Multiplication.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Multiplication(number1: $number1, number2: $number2, result: $result, star: $star)';
  }

  @override
  bool operator ==(covariant Multiplication other) {
    if (identical(this, other)) return true;

    return other.number1 == number1 &&
        other.number2 == number2 &&
        other.result == result &&
        other.star == star;
  }

  @override
  int get hashCode {
    return number1.hashCode ^
        number2.hashCode ^
        result.hashCode ^
        star.hashCode;
  }
}
