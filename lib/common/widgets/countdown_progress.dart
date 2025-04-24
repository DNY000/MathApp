import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_app/ultis/colors.dart';

class CountdownProgress extends StatefulWidget {
  final int durationInSeconds;
  final Function()? onComplete;
  final double height;

  const CountdownProgress({
    super.key,
    required this.durationInSeconds,
    this.onComplete,
    this.height = 4,
  });

  @override
  State<CountdownProgress> createState() => _CountdownProgressState();
}

class _CountdownProgressState extends State<CountdownProgress> {
  late Timer _timer;
  late int _remainingSeconds;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationInSeconds;
    _progress = 1.0;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _progress = _remainingSeconds / widget.durationInSeconds;
        } else {
          _timer.cancel();
          widget.onComplete?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          minHeight: widget.height.h,
          backgroundColor: TColors.button,
          valueColor: AlwaysStoppedAnimation<Color>(
            _progress > 0.5 ? TColors.yellow1 : Colors.red,
          ),
        ),
      ],
    );
  }
}
