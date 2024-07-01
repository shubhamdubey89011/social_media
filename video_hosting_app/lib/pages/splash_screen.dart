// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_easy_animations/flutter_easy_animations.dart';
import 'package:corp_tale/constants/color_const.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Automatically start the animation

    _stopAnimationAfterDelay();
  }

  void _stopAnimationAfterDelay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context)
          .pushReplacementNamed('/login'); // Redirect to login screen
    });
    final animates = [
      AnimateStyles.rubberBand(
          _controller,
          const Image(
            image: AssetImage("assets/images/app_icon.png"),
            height: 60,
          )
          // const Text(
          //   'Corp Tale',
          //   style: TextStyle(color: Colors.amber, fontSize: 35),
          // ),
          ),
    ];
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 200),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: ColorConstants.linearGradientColor7,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Center(
          child: GridView.count(
            crossAxisCount: 1,
            children: animates
                .map((e) => Center(
                      child: e,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
