import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/utils/utils.dart';

class DebugPedometerController extends PedometerController {
  DebugPedometerController(super.storage) {
    debugTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (timer) {
        stepCount += 50;
        stepCountStreamController.sink.add(
          StepData.fromCount(
            stepCount,
            dailyGoal,
          ),
        );
      },
    );
  }

  int stepCount = 0;
  Timer? debugTimer;

  @override
  List<StepData> getStepDataForDateRange({
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) {
    final startDate = startDateTime.toDate!;
    final endDate = endDateTime.toDate!;
    final data = <StepData>[];
    for (var i = startDate;
        !(i.isAfter(endDate));
        i = i.add(const Duration(days: 1))) {
      final stepData = getStepDataFromDateTime(i);

      if (stepData == null) continue;

      data.add(stepData);
    }
    return data;
  }

  @override
  StepData? getStepDataFromDateTime(DateTime date) {
    if (date.toDateString == DateTime.now().toDateString) {
      return StepData.fromCount(
        currentSteps,
        dailyGoal,
      );
    }
    var stepCount = Random().nextInt(6000) + 2500;
    final stepData = StepData(
      steps: stepCount,
      lastUpdateTimeStamp: date,
      goalAchieved: stepCount > 5000,
      goalAtTheTime: dailyGoal,
    );
    return stepData;
  }

  @override
  Future<void> initialize() async {
    super.initialize();
    final alarmManager = AlarmManager.instance;
    alarmManager.registerListener("debugChange", (triggerTime) async {
      Log.d(
        message:
            "DebugPedometerController.initialize : debugChange trigger: $triggerTime",
      );

      final storedTime = storage.getSettingInt(kCurrentTimerDateKey);
      await storage.setSettingInt(
        kCurrentTimerDateKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      if (storedTime == null) {
        return;
      }

      final dateTime = DateTime.fromMillisecondsSinceEpoch(
        storedTime,
      );

      final currentDateTime = DateTime.now();
      if (dateTime.minute != triggerTime.minute) {
        Log.d(
          message: "DebugPedometerController.debugChange : Resetting data",
        );
        stepCount = 0;
        stepCountStreamController.sink.add(
          StepData.fromCount(stepCount, dailyGoal),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    debugTimer?.cancel();
    debugTimer = null;
    stepCount = 0;
  }

  @override
  int get currentSteps => stepCount;

  @override
  List<StepData> getAllStepData() {
    final endDate = DateTime.now().toDate!;
    final startDate = endDate.subtract(const Duration(days: 30)).toDate!;

    final data = getStepDataForDateRange(
      startDateTime: startDate,
      endDateTime: endDate,
    );
    return data;
  }

  @override
  Future<void> onAppLifecycleStateChange(
    AppLifecycleState state, {
    Future<void> Function(AppLifecycleState state)? processState,
  }) async {
    storage.onAppLifecycleStateChange(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        // widget is resumed
        break;
      case AppLifecycleState.inactive:
        // widget is inactive
        break;
      case AppLifecycleState.paused:
        // widget is paused
        break;
      case AppLifecycleState.detached:
        // widget is detached
        break;
      case AppLifecycleState.hidden:
        // widget is not visible
        break;
    }

    processState?.call(state);
  }

  @override
  void onPedestrianStatusChanged(PedestrianStatus event) {
    // TODO: implement onPedestrianStatusChanged
  }

  @override
  void onStepCount(int steps, DateTime timestamp) {
    // TODO: implement onStepCount
  }

  @override
  void setupInitialSteps() {
    // TODO: implement setupInitialSteps
  }
}
