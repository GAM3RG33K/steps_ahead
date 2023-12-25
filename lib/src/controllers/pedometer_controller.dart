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

  int get dailyGoal => dailyGoalFromStorage ?? kSettingsDefaultDailyGoal;

  int? get dailyGoalFromStorage => storage.getSettingInt(kSettingsKeyDailyGoal);

  set dailyGoal(int goal) => storage.setSettingInt(
        kSettingsKeyDailyGoal,
        goal,
      );

  int get userHeightInCms =>
      heightInCmsFromStorage ?? kSettingsDefaultHeightInCms;

  int? get heightInCmsFromStorage =>
      storage.getSettingInt(kSettingsKeyHeightInCms);

  set userHeightInCms(int height) => storage.setSettingInt(
        kSettingsKeyHeightInCms,
        height,
      );

  double get userWeightInKgs =>
      weightInKgsFromStorage ?? kSettingsDefaultWeightInKGs;

  double? get weightInKgsFromStorage =>
      storage.getSettingDouble(kSettingsKeyWeightInKGs);

  set userWeightInKgs(double weight) => storage.setSettingDouble(
        kSettingsKeyWeightInKGs,
        weight,
      );

  double get stepLength => stepLengthFromStorage ?? avgStepLength;

  double? get stepLengthFromStorage =>
      storage.getSettingDouble(kSettingsKeyStepLengthInCms);

  set stepLength(double stepLength) {
    storage.setSettingDouble(kSettingsKeyWeightInKGs, stepLength);
  }

  double get avgStepLength {
    if (heightInCmsFromStorage == null) {
      return double.nan;
    }
    double stepLength = calculateAvgStepLength(userHeightInCms);
    return stepLength;
  }

  double calculateAvgStepLength(int userHeightInCms) {
    final stepLength = userHeightInCms * kAverageMultiplierForStepLength;
    return stepLength;
  }

  double get userBMI {
    if (heightInCmsFromStorage == null || weightInKgsFromStorage == null) {
      return double.nan;
    }
    double bmi = calculateBMI(userHeightInCms, userWeightInKgs);
    return bmi;
  }

  double calculateBMI(int userHeightInCms, double userWeightInKgs) {
    final userHeightInMeters = (userHeightInCms / 100);
    final bmi = userWeightInKgs / (userHeightInMeters * userHeightInMeters);
    return bmi;
  }

  double get userMET {
    if (userBMI.isNaN) {
      return double.nan;
    }
    double metVal = calculateMETValue(
      userHeightInCms,
      userWeightInKgs,
      bmi: userBMI,
    );
    return metVal;
  }

  double calculateMETValue(int userHeightInCms, double userWeightInKgs,
      {double? bmi}) {
    bmi ??= userBMI;

    // weight in kgs * 0.0022
    final metWeightPart = (userWeightInKgs * kMetConstantA);

    // height in cms * 0.000155
    final metHeightPart = (userHeightInCms * kMetConstantB);

    // bmi * 0.000063
    final metBmiPart = (bmi * kMetConstantC);

    // MET value = a * weight + b * height - c * BMI
    final metValue = metWeightPart + metHeightPart - metBmiPart;

    return metValue;
  }

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
