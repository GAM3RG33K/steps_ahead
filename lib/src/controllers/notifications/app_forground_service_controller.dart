import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/utils/utils.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  SendPort? _sendPort;

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    final customData =
        await FlutterForegroundTask.getData<String>(key: 'customData');
    print('ForegroundTaskHandler.onStart:');
    print('customData: $customData');
  }

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    sendPort?.send(timestamp);
    print('ForegroundTaskHandler.onRepeatEvent:');
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    print('ForegroundTaskHandler.onDestroy:');
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed >> $id');
    if (id == "exitButton") {
      FlutterForegroundTask.stopService();
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
    _sendPort?.send('onNotificationPressed');
  }
}

class AppForegroundServiceController {
  static AppForegroundServiceController get instance =>
      get<AppForegroundServiceController>();

  // A unique Notification ID
  int notificationIdCounter = 7 * 31;
  int stepCounterId = 24769;

  AppForegroundServiceController();

  Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        foregroundServiceType: AndroidForegroundServiceType.HEALTH,
        channelId: '$kPackageId.tracker_updates',
        channelName: 'Tracker update Notification',
        channelDescription:
            'This notification appears when app is running & is tracking the walking activity',
        channelImportance: NotificationChannelImportance.MIN,
        priority: NotificationPriority.MIN,
        visibility: NotificationVisibility.VISIBILITY_PRIVATE,
        iconData: const NotificationIconData(
          resType: ResourceType.drawable,
          resPrefix: ResourcePrefix.img,
          name: 'logo_transparent',
        ),
        isSticky: true,
        playSound: false,
        enableVibration: false,
        buttons: [
          const NotificationButton(id: 'exitButton', text: 'Exit'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> get isRunningService => FlutterForegroundTask.isRunningService;

  Future<bool> get isAppOnForeground => FlutterForegroundTask.isAppOnForeground;

  Future<bool> startForegroundTask({
    required String notificationTitle,
    required String notificationText,
    Function? callback,
  }) {
    return FlutterForegroundTask.startService(
      notificationTitle: notificationTitle,
      notificationText: notificationText,
      callback: callback,
    );
  }

  Future<bool> updateForegroundTask({
    required String notificationTitle,
    required String notificationText,
    Function? callback,
  }) {
    return FlutterForegroundTask.updateService(
      notificationTitle: notificationTitle,
      notificationText: notificationText,
      callback: callback,
    );
  }

  Future<bool> stopForegroundTask() {
    return FlutterForegroundTask.stopService();
  }

  Future<void> updateNotification(int steps, String bodyText) async {
    final appForegroundServiceController =
        AppForegroundServiceController.instance;

    final notificationTitle = "$steps steps today";
    final notificationText = bodyText;

    var isForegroundServiceRunning =
        await appForegroundServiceController.isRunningService;
    if (!isForegroundServiceRunning) {
      await appForegroundServiceController.startForegroundTask(
        notificationText: notificationText,
        notificationTitle: notificationTitle,
        callback: startCallback,
      );
    } else {
      await appForegroundServiceController.updateForegroundTask(
        notificationTitle: notificationTitle,
        notificationText: notificationText,
        callback: startCallback,
      );
    }
  }

  String generateNotificationData(
    PedometerApi pedometerApi,
    int steps,
    int goal,
  ) {
    final calories = pedometerApi.calculateCaloriesBurnedFromSteps(steps);
    final distanceTravelled = pedometerApi.distanceTravelledFromSteps(steps);
    final progress = FormulaUtils.instance.calculateProgressForStepsAndGoal(
      currentSteps: steps,
      dailyGoal: goal,
    );

    final bodyTextCalorie = "${calories.toStringAsFixed(2)} kcal";
    final bodyTextDistance = "${distanceTravelled.toStringAsFixed(2)} Kms";
    final bodyTextProgress =
        "${progress.toStringAsFixed(2)}% of your daily goal";
    final bodyText = "$bodyTextCalorie $bodyTextDistance $bodyTextProgress";
    return bodyText;
  }
}
