import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/screens/my_homepage.dart';

const kRepeatCount = 1;
const kAnimationLength = 1250;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kAnimationLength),
    );

    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController?.repeat();
        Future.delayed(
          const Duration(milliseconds: kRepeatCount * kAnimationLength),
          () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  return const MyHomePage(title: kProjectName);
                },
              ),
            );
          },
        );
      }
    });

    animationController?.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Transform.rotate(
              angle: -(pi / 2),
              child: Lottie.asset(
                kLogoLottieAsset,
                controller: animationController,
                animate: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
