import 'dart:async';
import 'package:flutter/material.dart';
import 'package:math_app/ultis/colors.dart';

class CountdownProgress extends StatefulWidget {
  final int durationInSeconds;
  final VoidCallback onComplete;
  final double height;

  const CountdownProgress({
    super.key,
    required this.durationInSeconds,
    required this.onComplete,
    required this.height,
  });

  @override
  State<CountdownProgress> createState() => CountdownProgressState();
}

class CountdownProgressState extends State<CountdownProgress> {
  late Timer _timer;
  double _timeLeft = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.durationInSeconds.toDouble();
    startTimer();
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft -= 0.1;
        });
      } else {
        stopTimer();
        widget.onComplete();
      }
    });
  }

  void stopTimer() {
    _timer.cancel();
    _isRunning = false;
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      _timeLeft = widget.durationInSeconds.toDouble();
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          // Sử dụng timeLeft/duration để có được progress mượt
          value: _timeLeft / widget.durationInSeconds,
          backgroundColor: TColors.button,
          valueColor: AlwaysStoppedAnimation<Color>(TColors.yellow1),
          minHeight: widget.height,
        ),
        SizedBox(height: 4),
      ],
    );
  }
}
