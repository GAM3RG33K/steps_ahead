import 'package:flutter/material.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/screens/screens.dart';

class StepsTab extends StatelessWidget {
  final Stream<StepData> stepCountStream;
  final int dailyGoal;

  const StepsTab({
    super.key,
    required this.stepCountStream,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Steps',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildStreamBuilder(
              stepCountStream.map(
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
          dailyGoal: dailyGoal,
        );
      },
    );
  }
}
