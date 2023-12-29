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
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
      ),
    );
  }

  Widget buildInfoTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color tileColor,
    required Color iconColor,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: tileColor,
        child: ListTile(
          enabled: false,
          dense: true,
          leading: CircleAvatar(
            backgroundColor: iconColor,
            child: Icon(
              icon,
              size: 24,
              color: tileColor,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: iconColor,
                ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: iconColor,
                      ),
                )
              : null,
        ),
      ),
    );
  }
}
