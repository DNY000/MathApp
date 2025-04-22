import 'package:flutter/material.dart';
import 'package:math_app/views/home/home.dart';
import 'package:math_app/ultis/t_image.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigatorHome();
  }

  Future<void> _navigatorHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 34, 61, 61),
      body: Center(child: Image.asset(TImage.techlead)),
    );
  }
}
