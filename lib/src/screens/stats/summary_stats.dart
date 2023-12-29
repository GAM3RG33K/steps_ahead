import 'package:flutter/material.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/utils/utils.dart';

class SummaryStats extends StatefulWidget {
  const SummaryStats({super.key});

  @override
  State<SummaryStats> createState() => _SummaryStatsState();
}

class _SummaryStatsState extends State<SummaryStats> {
  int totalGoalsAchieved = 0;
  int totalSteps = 0;
  double totalCaloriesBurned = 0;
  double totalDistanceTravelled = 0;

  @override
  void initState() {
    super.initState();

    final allSteps = PedometerApi.instance.getAllStepData();
    if (allSteps.isEmpty) return;
    totalSteps = allSteps
        .map((e) => e.steps)
        .reduce((value, element) => value + element);

    totalGoalsAchieved = allSteps.where((e) => e.goalAchieved).length;
    totalCaloriesBurned =
        PedometerApi.instance.calculateCaloriesBurnedFromSteps(
      totalSteps,
    );

    totalDistanceTravelled = PedometerApi.instance.distanceTravelledFromSteps(
      totalSteps,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        const SizedBox(height: 36),
        buildInfoTile(
          context: context,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          title: "$totalSteps Steps",
          subtitle: "Total Steps",
          icon: Icons.directions_walk,
          iconColor: materialColor3,
          tileColor: materialColorLight3,
        ),
        buildInfoTile(
          context: context,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          title: "${totalCaloriesBurned.toStringAsFixed(2)} kcal",
          subtitle: "Calories Burned",
          icon: Icons.local_fire_department,
          iconColor: materialColor1,
          tileColor: materialColorLight1,
        ),
        buildInfoTile(
          context: context,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          title: "${totalDistanceTravelled.toStringAsFixed(2)} km",
          subtitle: "Distance Travelled",
          icon: Icons.route,
          iconColor: materialColor4,
          tileColor: materialColorLight4,
        ),
        buildInfoTile(
          context: context,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          title: "$totalGoalsAchieved",
          subtitle: "Daily Goals Achieved",
          icon: Icons.electric_bolt,
          iconColor: materialColor2,
          tileColor: materialColorLight2,
        ),
      ],
    );
  }
}
