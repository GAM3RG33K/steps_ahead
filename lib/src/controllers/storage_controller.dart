import 'dart:async';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

StorageController get storageController => StorageController._instance!;

class StorageController {
  final SharedPreferences storage;

  StorageController._(this.storage);

  static StorageController? _instance;

  static bool get isInitialized => _instance != null;

  static Future<StorageController> getInstance() async {
    if (!isInitialized) {
      final storage = await SharedPreferences.getInstance();
      _instance = StorageController._(storage);
    }
    return _instance!;
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

  Future<bool> remove(String key) => storage.remove(key);
}
