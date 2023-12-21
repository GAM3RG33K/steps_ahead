import 'dart:math';

import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';

class CustomProgressWidget extends StatelessWidget {
  final int currentSteps;
  final int dailyGoal;

  const CustomProgressWidget({
    super.key,
    required this.currentSteps,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = getAssetPathFromData(currentSteps, dailyGoal);
    return Center(
      child: Image.asset(
        assetPath,
        height: 200,
        width: 200,
      ),
    );
  }

  String getAssetPathFromData(int currentSteps, int dailyGoal) {
    String path = kCustomProgressAssetPathPrefix;
    final progress = ((currentSteps * 100) ~/ dailyGoal);
    int index = progress ~/ kCustomProgressAssetPathMultiplier;
    index = max(min(50, index), 1);
    path += "/tile$index.png";
    return path;
  }
}
