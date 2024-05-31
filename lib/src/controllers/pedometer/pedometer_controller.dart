import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/utils/utils.dart';

import 'pedometer_api.dart';

export 'package:steps_ahead/src/models/models.dart'
    show PedestrianStatusData, StepData;

class PedometerController extends PedometerApi {
  PedometerController(super.storage);

  int _currentSteps = 0;

  @override
  Future<void> initialize() async {
    if (!isInitialized) {
      await _initPedometerStreams();

      setupInitialSteps();

      final alarmManager = AlarmManager.instance;
      alarmManager.registerListener("dateChange", (triggerTime) async {
        Log.d(
          message:
              "PedometerController.initialize : dateChange trigger: $triggerTime",
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
        if (currentDateTime.toDateString != dateTime.toDateString) {
          resetDataForTheDay();
        }
      });
      isInitialized = true;
    }
  }

  Future<void> _initPedometerStreams() async {
    final status = await Permission.activityRecognition.request();
    if (status.isDenied) {
      showToast(
        "Please allow the permission to access your movements from the app settings",
        showLonger: true,
      );
    }

    Pedometer.pedestrianStatusStream
        .listen(
          (event) => onPedestrianStatusChanged(event),
        )
        .onError(onPedestrianStatusError);

    Pedometer.stepCountStream
        .listen((event) => onStepCount(event.steps, event.timeStamp))
        .onError(onStepCountError);
  }

  @override
  void setupInitialSteps() {
    Log.d(message: "setupInitialSteps :");

    final newSteps = todayStepData.steps > 0
        ? todayStepData
        : todayStepData.addSteps(lastSensorOutputFromStorage);

    stepCountStreamController.sink.add(newSteps);
    _currentSteps = newSteps.steps;

    if (_currentSteps >= dailyGoal) {
      setGoalAchieved();
    }
  }

  @override
  void onStepCount(int steps, DateTime timestamp) {
    Log.d(message: "onStepCount : steps: $steps, ts: $timestamp");
    final newSteps = getUpdatedCurrentSteps(steps);
    todayStepData = newSteps;
    stepCountStreamController.sink.add(newSteps);
    _currentSteps = newSteps.steps;

    if (_currentSteps >= dailyGoal) {
      setGoalAchieved();
    }
  }

  @override
  void onPedestrianStatusChanged(PedestrianStatus event) {
    Log.d(message: "onPedestrianStatusChanged : $event");
    pedestrianStatusStreamController.sink.add(
      PedestrianStatusData.fromNativeData(
        type: event.status,
        timestamp: event.timeStamp,
      ),
    );
  }

  void onPedestrianStatusError(e) {
    Log.e(error: e, message: "onPedestrianStatusError : ");
  }

  void onStepCountError(e) {
    Log.e(error: e, message: "onStepCountError : ");
  }

  @override
  Future<void> onAppLifecycleStateChange(
    AppLifecycleState state, {
    Future<void> Function(AppLifecycleState state)? processState,
  }) async {
    storage.onAppLifecycleStateChange(state);

    Log.d(message: "PedometerController.onAppLifecycleStateChange : $state");
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
  int get currentSteps => _currentSteps;

  void resetDataForTheDay() {
    Log.i(message: "Steps Ahead: Resetting data for the day");
    _currentSteps = 0;
    todayStepData = StepData(
      lastUpdateTimeStamp: DateTime.now(),
      steps: 0,
      goalAtTheTime: dailyGoal,
    );
    lastSensorOutputFromStorage = 0;
  }
}
