import 'package:flutter/material.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/screens/screens.dart';

class ForestTab extends StatefulWidget {
  final Stream<StepData> stepCountStream;
  final int dailyGoal;

  const ForestTab({
    super.key,
    required this.stepCountStream,
    required this.dailyGoal,
  });

  @override
  State<ForestTab> createState() => _ForestTabState();
}

class _ForestTabState extends State<ForestTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Forest',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildStreamBuilder(
              widget.stepCountStream.map(
                (event) => event.steps,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStreamBuilder(Stream<int> stepCountStream) {
    return StreamBuilder<int>(
      stream: stepCountStream,
      builder: (context, snapshot) {
        var val = snapshot.data ?? 0;

        return ProgressUI(
          currentSteps: val,
          dailyGoal: widget.dailyGoal,
        );
      },
    );
  }
}
