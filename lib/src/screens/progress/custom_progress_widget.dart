import 'dart:math';

import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';

class CustomProgressWidget extends StatelessWidget {
  final int progress;

  const CustomProgressWidget({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = getAssetPathFromData(progress);
    return Center(
      child: Image.asset(
        assetPath,
        height: 200,
        width: 200,
      ),
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
