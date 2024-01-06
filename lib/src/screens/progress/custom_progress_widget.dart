import 'dart:math';

import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';

class CustomProgressWidget extends StatelessWidget {
  final int progress;
  final double height;
  final double width;
  final Color? tint;

  const CustomProgressWidget({
    super.key,
    required this.progress,
    this.height = 300,
    this.width = 300,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = getAssetPathFromData(progress);
    return Image.asset(
      assetPath,
      height: height,
      width: width,
    );
  }

  String getAssetPathFromData(int progress) {
    String path = kCustomProgressAssetPathPrefix;
    int index = progress ~/ kCustomProgressAssetPathMultiplier;
    index = max(min(50, index), 1);
    path += "/tile$index.png";
    return path;
  }
}
