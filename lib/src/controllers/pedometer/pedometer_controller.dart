import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
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
        .listen((event) => onStepCount(event))
        .onError(onStepCountError);
  }

  void onStepCount(StepCount event) {
    Log.d(message: "onStepCount : $event");
    final newSteps = getUpdatedCurrentSteps(event);
    todayStepData = newSteps;
    stepCountStreamController.sink.add(newSteps);
    _currentSteps = newSteps.steps;

    if (_currentSteps >= dailyGoal) {
      setGoalAchieved();
    }
  }

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
  Future<void> onAppLifecycleStateChange(AppLifecycleState state) async {
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
  }

  @override
  int get currentSteps => _currentSteps;
}
