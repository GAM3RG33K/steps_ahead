import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/storage_controller.dart';
import 'package:steps_ahead/src/models/models.dart';
import 'package:steps_ahead/src/utils/utils.dart';

export 'package:steps_ahead/src/models/models.dart'
    show PedestrianStatusData, StepData;

PedometerController get pedometerController => PedometerController._instance!;

class PedometerController {
  final StorageController storage;

  PedometerController._(this.storage);

  static PedometerController? _instance;

  Future<PermissionStatus> get appPermissionStatus async =>
      await Permission.activityRecognition.status;

  StreamController<PedestrianStatusData> pedestrianStatusStreamController =
      StreamController.broadcast();

  Stream<PedestrianStatusData> get pedestrianStatusStream =>
      pedestrianStatusStreamController.stream;

  StreamController<StepData> stepCountStreamController =
      StreamController.broadcast();

  Stream<StepData> get stepCountStream => stepCountStreamController.stream;

  int currentSteps = 0;

  static bool get isInitialized => _instance != null;

  static Future<PedometerController> getInstance() async {
    if (!isInitialized) {
      final _storage = await StorageController.getInstance();
      _instance = PedometerController._(_storage);
      await _initPedometerStreams(_instance!);
    }
    return _instance!;
  }

  static Future<void> _initPedometerStreams(
    PedometerController instance,
  ) async {
    final status = await Permission.activityRecognition.request();
    if (status.isDenied) {
      showToast(
        "Please allow the permission to access your movements from the app settings",
        showlonger: true,
      );
    }

    Pedometer.pedestrianStatusStream.listen(
      (event) {
        onPedestrianStatusChanged(event);
        instance.pedestrianStatusStreamController.sink.add(
          PedestrianStatusData.fromNativeData(
            type: event.status,
            timestamp: event.timeStamp,
          ),
        );
      },
    ).onError(onPedestrianStatusError);

    Pedometer.stepCountStream.listen(
      (event) {
        onStepCount(event);
        final newSteps = instance.getUpdatedCurrentSteps(event);
        instance.todayStepData = newSteps;
        instance.stepCountStreamController.sink.add(newSteps);
      },
    ).onError(onStepCountError);

    // // update steps
    // final lastSensorOutput = (await Pedometer.stepCountStream.last);
    // onStepCount(lastSensorOutput);
    // final newSteps = instance.getUpdatedCurrentSteps(lastSensorOutput);
    // instance.stepCountStreamController.sink.add(newSteps);

    // // update status
    // final lastSensorStatus = (await Pedometer.pedestrianStatusStream.last);
    // onPedestrianStatusChanged(lastSensorStatus);
    // instance.pedestrianStatusStreamController.sink.add(
    //   PedestrianStatusData.fromNativeData(
    //     type: lastSensorStatus.status,
    //     timestamp: lastSensorStatus.timeStamp,
    //   ),
    // );
  }

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

  int get dailyGoal =>
      storage.getSettingInt(kSettingsKeyDailyGoal) ?? kSettingsDefaultDailyGoal;

  StepData get todayStepData =>
      getStepDataFromDateTime(DateTime.now().toDateString!) ??
      StepData(
        lastUpdateTimeStamp: DateTime.now(),
        steps: 0,
      );

  set todayStepData(StepData stepData) => setStepDataFromDateTime(
        stepData.lastUpdateTimeStamp.toDateString!,
        stepData,
      );

  int get lastSensorOutputFromStorage =>
      storage.getSettingInt(kSettingsKeyLastSensorOutput) ??
      kSettingsDefaultLastSensorOutput;

  set lastSensorOutputFromStorage(int steps) => storage.setSettingInt(
        kSettingsKeyLastSensorOutput,
        steps,
      );

  StepData getUpdatedCurrentSteps(StepCount stepCount) {
    final lastSensorData = lastSensorOutputFromStorage;
    final sensorDiff = max(lastSensorData - stepCount.steps, 0);
    lastSensorOutputFromStorage = stepCount.steps;

    final newSteps = todayStepData.addSteps(sensorDiff);
    return newSteps;
  }

  StepData? getStepDataFromDateTime(String date) {
    final jsonString = storage.getSettingString(date);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    return StepData.fromJson(jsonDecode(jsonString));
  }

  Future<bool>? setStepDataFromDateTime(String date, StepData data) {
    return storage.setSettingString(
      date,
      jsonEncode(data.toJson()),
    );
  }
}

void onStepCount(StepCount event) {
  Log.d(message: "onStepCount : $event");
}

void onPedestrianStatusChanged(PedestrianStatus event) {
  Log.d(message: "onPedestrianStatusChanged : $event");
}

void onPedestrianStatusError(e) {
  Log.e(error: e, message: "onPedestrianStatusError : ");
}

void onStepCountError(e) {
  Log.e(error: e, message: "onStepCountError : ");
}
