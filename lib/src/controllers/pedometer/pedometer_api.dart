import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/storage_controller.dart';
import 'package:steps_ahead/src/utils/utils.dart';

import 'debug_pedometer_controller.dart';
import 'pedometer_controller.dart';

export 'package:steps_ahead/src/models/models.dart'
    show PedestrianStatusData, StepData;

abstract class PedometerApi {
  final StorageController storage;

  PedometerApi(this.storage);

  static PedometerApi get instance {
    if (kDebugMode) {
      return get<DebugPedometerController>();
    }
    return get<PedometerController>();
  }

  static Future<PedometerApi> registerForDI() async {
    final instance = await StorageController.getInstance();
    final storage = registerSingleton(instance);
    if (kDebugMode) {
      return registerSingleton<DebugPedometerController>(
        DebugPedometerController(storage),
      );
    }
    return registerSingleton<PedometerController>(
      PedometerController(storage),
    );
  }

  Future<PermissionStatus> get appPermissionStatus async =>
      await Permission.activityRecognition.status;

  StreamController<PedestrianStatusData> pedestrianStatusStreamController =
      StreamController.broadcast();

  Stream<PedestrianStatusData> get pedestrianStatusStream =>
      pedestrianStatusStreamController.stream;

  StreamController<StepData> stepCountStreamController =
      StreamController.broadcast();

  Stream<StepData> get stepCountStream => stepCountStreamController.stream;

  int get currentSteps;

  bool isInitialized = false;

  Future<void> initialize();

  @mustCallSuper
  void dispose() {
    stepCountStreamController.close();
    pedestrianStatusStreamController.close();
  }

  Future<void> onAppLifecycleStateChange(AppLifecycleState state);

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
    storage.setSettingDouble(kSettingsKeyStepLengthInCms, stepLength);
  }

  double get avgStepLength {
    if (heightInCmsFromStorage == null) {
      return kAverageDefaultStepLength;
    }
    double stepLength = calculateAvgStepLength(userHeightInCms);
    return stepLength;
  }

  double calculateAvgStepLength(int userHeightInCms) {
    final stepLength = userHeightInCms * kAverageMultiplierForStepLength;
    return stepLength;
  }

  JSON get speed => speedInformationMap[speedIndex]!;

  int get speedIndex => speedIndexFromStorage ?? kSettingsDefaultSpeedIndex;

  int? get speedIndexFromStorage =>
      storage.getSettingInt(kSettingsKeySpeedIndex);

  set speedIndex(int index) => storage.setSettingInt(
        kSettingsKeySpeedIndex,
        index,
      );

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

  double get userMETValue =>
      (speedInformationMap[speedIndex]!["met"] as double?) ??
      kSettingsDefaultMetValue;

  double distanceTravelledFromSteps(int stepCount) {
    if (stepLength.isNaN) {
      return double.nan;
    }
    final distanceTravelled = calculateDistanceTravelledInKm(
      stepCount,
      stepLength,
    );
    return distanceTravelled;
  }

  double calculateDistanceTravelledInCm(int stepCount, double stepLength) {
    final totalDistance = stepCount * stepLength;
    return totalDistance;
  }

  double calculateDistanceTravelledInKm(int stepCount, double stepLength) {
    final totalDistanceInCm =
        calculateDistanceTravelledInCm(stepCount, stepLength);
    final totalDistanceInKm = totalDistanceInCm / 100000;
    return totalDistanceInKm;
  }

  double calculateCaloriesBurnedFromSteps(int stepCount) {
    if (userMETValue.isNaN) {
      return double.nan;
    }

    final distanceFromSteps = distanceTravelledFromSteps(stepCount);
    final activityDurationInHours = calculateActivityDurationInHours(
      distanceFromSteps,
      (speed["value"] as double),
    );
    double caloriesBurned = calculateCaloriesBurned(
      activityDurationInHours,
      userMETValue,
      userWeightInKgs,
    );
    return caloriesBurned;
  }

  double calculateCaloriesBurned(
    double activityDurationInHours,
    double metValue,
    double weightInKgs,
  ) {
    final caloriesBurned = (metValue * weightInKgs * activityDurationInHours);
    return caloriesBurned;
  }

  StepData get todayStepData =>
      getStepDataFromDateTime(DateTime.now()) ??
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

  StepData? getStepDataFromDateTime(DateTime date) {
    if (date.toDateString == DateTime.now().toDateString) {
      return StepData.fromCount(currentSteps);
    }
    final dateString = date.toDateString!;
    final jsonString = storage.getSettingString(dateString);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    return StepData.fromJson(jsonDecode(jsonString));
  }

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

  Future<bool>? setStepDataFromDateTime(String date, StepData data) {
    return storage.setSettingString(
      date,
      jsonEncode(data.toJson()),
    );
  }

  double calculateActivityDurationInHours(double distance, double speed) {
    final durationInHours = distance / speed;
    return durationInHours;
  }
}
