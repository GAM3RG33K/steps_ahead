import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/screens/screens.dart';
import 'package:steps_ahead/src/utils/utils.dart';

class ProgressUI extends StatefulWidget {
  final int currentSteps;
  final int dailyGoal;

  const ProgressUI({
    super.key,
    required this.currentSteps,
    required this.dailyGoal,
  });

  @override
  State<ProgressUI> createState() => _ProgressUIState();
}

class _ProgressUIState extends State<ProgressUI> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              widget.currentSteps.toString(),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 36,
                    color: kPrimaryColorValue.toColor!,
                  ),
            ),
            const SizedBox(width: 16),
            Text(
              "/",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 16),
            Text(
              widget.dailyGoal.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: widget.currentSteps / widget.dailyGoal,
          borderRadius: BorderRadius.circular(10),
          color: kPrimaryColorValue.toColor!,
          backgroundColor: kGrayColorValue.toColor!,
        ),
        const SizedBox(height: 24),
        CustomProgressWidget(
          currentSteps: widget.currentSteps,
          dailyGoal: widget.dailyGoal,
        ),
      ],
    );
  }
}