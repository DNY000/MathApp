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
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.durationInSeconds.toDouble();
    startTimer();
  }

  void startTimer() {
    if (_isRunning || _timeLeft <= 0) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _timeLeft = (_timeLeft - 0.1).clamp(
          0,
          widget.durationInSeconds.toDouble(),
        );

        if (_timeLeft <= 0 && !_isCompleted) {
          _isCompleted = true;
          stopTimer();
          widget.onComplete();
        }
      });
    });
  }

  void stopTimer() {
    if (_timer.isActive) _timer.cancel();
    _isRunning = false;
  }

  void resumeTimer() {
    if (!_isRunning && _timeLeft > 0) {
      startTimer();
    }
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      _timeLeft = widget.durationInSeconds.toDouble();
      _isCompleted = false;
    });
    startTimer();
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _timeLeft / widget.durationInSeconds,
          backgroundColor: TColors.button,
          valueColor: AlwaysStoppedAnimation<Color>(TColors.yellow1),
          minHeight: widget.height,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
