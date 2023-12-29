import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:steps_ahead/src/utils/utils.dart';

import 'pedometer_api.dart';

class DebugPedometerController extends PedometerApi {
  DebugPedometerController(super.storage) {
    debugTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (timer) {
        stepCount += 50;
        stepCountStreamController.sink.add(
          StepData.fromCount(stepCount),
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
      return StepData.fromCount(currentSteps);
    }
    final stepData = StepData(
      steps: Random().nextInt(6000) + 2500,
      lastUpdateTimeStamp: date,
    );
    return stepData;
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> onAppLifecycleStateChange(AppLifecycleState state) async {}

  @override
  void dispose() {
    super.dispose();
    debugTimer?.cancel();
    debugTimer = null;
    stepCount = 0;
  }

  @override
  int get currentSteps => stepCount;
}
