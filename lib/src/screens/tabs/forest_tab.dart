import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/screens/screens.dart';
import 'package:steps_ahead/src/utils/utils.dart';

class ForestTab extends StatefulWidget {
  final Stream<StepData> stepCountStream;
  final int dailyGoal;
  final int initialSteps;

  const ForestTab({
    super.key,
    required this.stepCountStream,
    required this.dailyGoal,
    this.initialSteps = 0,
  });

  @override
  State<ForestTab> createState() => _ForestTabState();
}

class _ForestTabState extends State<ForestTab> {
  List<StepData> stepsData = [];

  @override
  void initState() {
    super.initState();
    stepsData = getStepDataForChart();
  }

  List<StepData> getStepDataForChart() {
    final endDate = DateTime.now().toDate!;
    final startDate = endDate.subtract(const Duration(days: 7)).toDate!;
    final data = PedometerApi.instance.getStepDataForDateRange(
      startDateTime: startDate,
      endDateTime: endDate,
    );
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          const Flexible(
            fit: FlexFit.loose,
            flex: 4,
            child: SizedBox.shrink(),
          ),
          buildStreamBuilder(
            widget.stepCountStream.map(
              (event) => event.steps,
            ),
            initialSteps: widget.initialSteps,
          ),
          const Flexible(
            fit: FlexFit.loose,
            flex: 4,
            child: SizedBox.shrink(),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.loose,
            child: ListView(
              reverse: true,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children:
                  listItems(stepsData.take(stepsData.length - 1).toList()),
            ),
          ),
        ],
      ),
    );
  }

  Size get cellSize => Size.square(treeSize.height * 0.5);

  Size get treeSize => const Size.square(80);

  List<Widget> listItems(List<StepData> stepsData) {
    final progressTrees = stepsData.map(
      (stepData) {
        final progress = stepData.progress;
        final treeHeight = treeSize.height * getSizeMultiplier(progress);
        final treeWidth = treeSize.width * getSizeMultiplier(progress);

        final stackHeight = treeSize.height;
        final stackWidth = treeSize.width;

        return Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          message: "${stepData.baseDateString}"
              "\nProgress - $progress%",
          child: SizedOverflowBox(
            size: cellSize,
            child: SizedBox(
              height: stackHeight,
              width: stackWidth,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    child: CustomProgressWidget(
                      progress: progress,
                      height: treeHeight,
                      width: treeWidth,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).toList();

    final treesInChunks = partition(progressTrees, 7);
    final listItems = treesInChunks
        .map((e) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: e,
            ))
        .toList();
    return listItems;
  }

  double getSizeMultiplier(int e) {
    final multiplier = (e * 0.01);
    if (multiplier > 1) {
      return 1;
    }
    if (multiplier <= 0.75) {
      return 0.75;
    }
    return multiplier;
  }

  Widget buildStreamBuilder(Stream<int> stepCountStream,
      {int initialSteps = 0}) {
    return StreamBuilder<int>(
      initialData: initialSteps,
      stream: stepCountStream,
      builder: (context, snapshot) {
        var val = snapshot.data ?? 0;

        return ProgressUI(
          currentSteps: val,
          dailyGoal: widget.dailyGoal,
          additionalInfo: false,
        );
      },
    );
  }
}
