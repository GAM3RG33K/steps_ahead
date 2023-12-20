import 'dart:async';
import 'dart:ui';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_ahead/src/utils/utils.dart';

PedometerController get pedometerController => PedometerController._instance!;

class PedometerController {
  final SharedPreferences storage;

  PedometerController._(this.storage);

  static PedometerController? _instance;

  Future<PermissionStatus> get appPermissionStatus async =>
      await Permission.activityRecognition.status;

  Stream<PedestrianStatus> get pedestrianStatusStream =>
      Pedometer.pedestrianStatusStream;

  Stream<StepCount> get stepCountStream => Pedometer.stepCountStream;

  int currentSteps = 0;

  static bool get isInitialized => _instance != null;

  static Future<PedometerController> getInstance() async {
    if (!isInitialized) {
      final storage = await SharedPreferences.getInstance();
      _instance = PedometerController._(storage);
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

    instance.pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    instance.stepCountStream.listen(
      (event) {
        instance.currentSteps = event.steps;
        onStepCount(event);
      },
    ).onError(onStepCountError);
  }

  Future<void> onAppLifecycleStateChange(AppLifecycleState state) async {
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

  Object? getSetting(String key) => storage.get(key);

  String? getSettingString(String key) => storage.getString(key);

  bool? getSettingBool(String key) => storage.getBool(key);

  int? getSettingInt(String key) => storage.getInt(key);

  double? getSettingDouble(String key) => storage.getDouble(key);

  List<String>? getSettingStringList(String key) => storage.getStringList(key);

  Future<bool> setSettingString(String key, String val) =>
      storage.setString(key, val);

  Future<bool> setSettingBool(String key, bool val) =>
      storage.setBool(key, val);

  Future<bool> setSettingInt(String key, int val) => storage.setInt(key, val);

  Future<bool> setSettingDouble(String key, double val) =>
      storage.setDouble(key, val);

  Future<bool> setSettingStringList(String key, List<String> val) =>
      storage.setStringList(key, val);
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
