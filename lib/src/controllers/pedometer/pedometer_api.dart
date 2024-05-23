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
    final pedometerController = PedometerController(storage);
    await pedometerController.initialize();
    return registerSingleton<PedometerController>(
      pedometerController,
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

  Future<void> initialize() =>
      throw UnimplementedError('initialize Not implemented Yet');

  @mustCallSuper
  void dispose() {
    stepCountStreamController.close();
    pedestrianStatusStreamController.close();
  }

  Future<void> onAppLifecycleStateChange(
    AppLifecycleState state, {
    Future<void> Function(AppLifecycleState state)? processState,
  }) =>
      throw UnimplementedError('onAppLifecycleStateChange Not implemented Yet');

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
    double stepLength = FormulaUtils.instance.calculateAvgStepLength(
      userHeightInCms,
      kAverageMultiplierForStepLength,
    );
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
    double bmi =
        FormulaUtils.instance.calculateBMI(userHeightInCms, userWeightInKgs);
    return bmi;
  }

  double get userMETValue =>
      (speedInformationMap[speedIndex]!["met"] as double?) ??
      kSettingsDefaultMetValue;

  double distanceTravelledFromSteps(int stepCount) {
    if (stepLength.isNaN) {
      return double.nan;
    }
    final distanceTravelled =
        FormulaUtils.instance.calculateDistanceTravelledInKm(
      stepCount,
      stepLength,
    );
    return distanceTravelled;
  }

  double calculateCaloriesBurnedFromSteps(int stepCount) {
    if (userMETValue.isNaN) {
      return double.nan;
    }

    final distanceFromSteps = distanceTravelledFromSteps(stepCount);
    final activityDurationInHours =
        FormulaUtils.instance.calculateActivityDurationInHours(
      distanceFromSteps,
      (speed["value"] as double),
    );
    double caloriesBurned = FormulaUtils.instance.calculateCaloriesBurned(
      activityDurationInHours,
      userMETValue,
      userWeightInKgs,
    );
    return caloriesBurned;
  }

  StepData get todayStepData =>
      getStepDataFromDateTime(DateTime.now()) ??
      StepData(
        lastUpdateTimeStamp: DateTime.now(),
        steps: 0,
        goalAtTheTime: dailyGoal,
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

  void setGoalAchieved() {
    todayStepData = todayStepData.copyWith(
      goalAchieved: true,
    );
  }

  StepData? getStepDataFromDateTime(DateTime date) {
    if (date.toDateString == DateTime.now().toDateString) {
      return StepData.fromCount(currentSteps, dailyGoal);
    }
    final dateString = date.toDateString!;
    return getStepDataFromKey(getStorageKeyFromDate(dateString));
  }

  StepData? getStepDataFromKey(String key) {
    final jsonString = storage.getSettingString(key);
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

  List<StepData> getAllStepData() {
    final keys = storage.getKeys();
    final data = keys
        .where((key) => key.startsWith(kStepDataPrefix))
        .map((key) => getStepDataFromKey(key)!)
        .toList();
    return data;
  }

  Future<bool>? setStepDataFromDateTime(String date, StepData data) {
    return storage.setSettingString(
      getStorageKeyFromDate(date),
      jsonEncode(data.toJson()),
    );
  }

  String getStorageKeyFromDate(String date) => kStepDataPrefix + date;
}
