import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/screens/screens.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int get dailyGoal =>
      pedometerController.getSettingInt(kSettingsDailyGoalKey) ??
      kSettingsDailyGoalDefault;

  @override
  void initState() {
    super.initState();
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
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AppSettingsScreen(),
                      ),
                    );
                    setState(() {});
                  },
                  child: const Text('App Settings'),
                ),
                PopupMenuItem(
                  onTap: () async {
                    await AppSettings.openAppSettings(
                      type: AppSettingsType.settings,
                    );
                    setState(() {});
                  },
                  child: const Text('System Settings'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
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
                pedometerController.stepCountStream.map(
                  (event) => event.steps,
                ),
              ),
            ],
          ),
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
