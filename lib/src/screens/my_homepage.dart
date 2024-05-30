import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/controllers/notifications/app_forground_service_controller.dart';
import 'package:steps_ahead/src/screens/screens.dart';
import 'package:steps_ahead/src/utils/formula_utils.dart';
import 'package:steps_ahead/src/utils/transformer_utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _bottomNavIndex = 1;

  List<NavBarEntry> navbarItems = [
    NavBarEntry(
      title: 'Forest',
      iconData: Icons.forest_outlined,
      activeIconData: Icons.forest,
    ),
    NavBarEntry(
      title: 'Tree',
      iconData: Icons.offline_bolt_outlined,
      activeIconData: Icons.offline_bolt,
    ),
    NavBarEntry(
      title: 'Stats',
      iconData: Icons.show_chart,
      activeIconData: Icons.show_chart,
    ),
  ];

  @override
  void initState() {
    super.initState();
    PedometerApi.instance.stepCountStream.listen((event) {
      final pedometerApi = PedometerApi.instance;
      final goal = pedometerApi.dailyGoal;
      final steps = pedometerApi.todayStepData.steps;

      final calories = pedometerApi.calculateCaloriesBurnedFromSteps(steps);
      final distanceTravelled = pedometerApi.distanceTravelledFromSteps(steps);
      final progress = FormulaUtils.instance.calculateProgressForStepsAndGoal(
        currentSteps: steps,
        dailyGoal: goal,
      );

      final bodyTextCalorie = "${calories.toStringAsFixed(2)} kcal";
      final bodyTextDistance = "${distanceTravelled.toStringAsFixed(2)} Kms";
      final bodyTextProgress =
          "${progress.toStringAsFixed(2)}% of your daily goal";
      final bodyText = "$bodyTextCalorie $bodyTextDistance $bodyTextProgress";
      updateNotification(steps, bodyText);
    });
  }

  Future<void> updateNotification(int steps, String bodyText) async {
    final appForegroundServiceController =
        AppForegroundServiceController.instance;

    final notificationTitle = "$steps steps today";
    final notificationText = bodyText;

    if (!(await appForegroundServiceController.isRunningService)) {
      await appForegroundServiceController.startForegroundTask(
        notificationText: notificationText,
        notificationTitle: notificationTitle,
      );
    } else {
      await appForegroundServiceController.updateForegroundTask(
        notificationTitle: notificationTitle,
        notificationText: notificationText,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          Tooltip(
            message: "Settings",
            child: InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AppSettingsScreen(),
                  ),
                );
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.settings,
                  size: 24,
                  color: kGrayColorValue.toColor!,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context),
      body: buildCurrentTab(_bottomNavIndex),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: navbarItems.asMap().keys.map((index) {
        final e = navbarItems[index];
        var activeParam = index == _bottomNavIndex;
        return BottomNavigationBarItem(
          backgroundColor: kGrayColorValue.toColor!.withOpacity(0.125),
          icon: e.build(
            context,
            isActiveParam: false,
          ),
          activeIcon: e.build(
            context,
            isActiveParam: activeParam,
          ),
          label: e.title,
          tooltip: e.title,
        );
      }).toList(),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: _bottomNavIndex,
      onTap: (index) => setState(() => _bottomNavIndex = index),
    );
  }

  Widget buildCurrentTab(int index) {
    var countStream = PedometerApi.instance.stepCountStream;
    var dailyGoal = PedometerApi.instance.dailyGoal;
    switch (index) {
      case 0:
        return ForestTab(
          key: const ValueKey(0),
          stepCountStream: countStream,
          dailyGoal: dailyGoal,
        );
      case 2:
        return StatsTab(
          key: const ValueKey(2),
          stepCountStream: countStream,
          dailyGoal: dailyGoal,
        );
      case 1:
      default:
        return StepsTab(
          key: const ValueKey(1),
          stepCountStream: countStream,
          dailyGoal: dailyGoal,
        );
    }
  }
}

class NavBarEntry {
  final String title;
  final IconData iconData;

  final IconData? activeIconData;
  final bool isActive;

  NavBarEntry({
    required this.title,
    required this.iconData,
    this.isActive = true,
    this.activeIconData,
  });

  Widget build(BuildContext context, {bool? isActiveParam}) {
    var active = isActiveParam ?? isActive;
    return Tooltip(
      message: title,
      child: Icon(
        (active ? (activeIconData ?? iconData) : iconData),
        size: active ? 32 : 24,
        color: active ? kPrimaryColorValue.toColor! : kGrayColorValue.toColor!,
      ),
    );
  }
}
