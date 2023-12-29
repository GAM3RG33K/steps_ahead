import 'package:flutter/material.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/utils/utils.dart';

class ProgressAdditionalInformation extends StatelessWidget {
  final int steps;
  final int goal;

  const ProgressAdditionalInformation({
    super.key,
    required this.steps,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      children: [
        buildInfoTile(
          context: context,
          title:
              "${PedometerApi.instance.calculateCaloriesBurnedFromSteps(steps).toStringAsFixed(2)} kcal",
          subtitle: "Calories Burned",
          icon: Icons.local_fire_department,
          iconColor: materialColor1,
          tileColor: materialColorLight1,
        ),
        buildInfoTile(
          context: context,
          title:
              "${PedometerApi.instance.distanceTravelledFromSteps(steps).toStringAsFixed(2)} km",
          subtitle: "Distance Travelled",
          icon: Icons.route,
          iconColor: materialColor4,
          tileColor: materialColorLight4,
        ),
        buildInfoTile(
          context: context,
          title: "${(steps * 100 / goal).toStringAsFixed(2)}%",
          subtitle: "Goal achieved",
          icon: Icons.location_on,
          iconColor: materialColor2,
          tileColor: materialColorLight2,
        ),
      ],
    );
  }
}
