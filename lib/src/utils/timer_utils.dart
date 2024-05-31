import 'dart:async';

import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/utils/utils.dart';

typedef AlarmCallback = void Function(DateTime triggerTime);

class AlarmManager {
  final StorageController storage;

  final Timer timer;

  final StreamController<DateTime> triggerStreamController;

  AlarmManager(this.storage, this.timer, this.triggerStreamController) {
    triggerStreamController.stream.listen(
      (event) {
        for (var callback in _callbackRegister.values) {
          callback(event);
        }
      },
    );
  }

  final _callbackRegister = <String, AlarmCallback>{};

  static AlarmManager get instance {
    return get<AlarmManager>();
  }

  static Future<AlarmManager> registerForDI() async {
    final storage = StorageController.instance;

    final triggerStreamController = StreamController<DateTime>.broadcast();
    final timer = Timer.periodic(
      const Duration(seconds: kDefaultTimerRepeatDuration),
      (timer) async {
        final currentDateTime = DateTime.now();
        triggerStreamController.sink.add(currentDateTime);
      },
    );

    final alarmManager = AlarmManager(
      storage,
      timer,
      triggerStreamController,
    );

    return registerSingleton<AlarmManager>(
      alarmManager,
    );
  }

  Stream<DateTime> get triggerStream => triggerStreamController.stream;

  void registerListener(String id, AlarmCallback callback) {
    _callbackRegister[id] = callback;
  }

  void removeListener(String id) => _callbackRegister.remove(id);
}
