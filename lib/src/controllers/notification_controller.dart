import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/utils/utils.dart';

class NotificationController {
  static NotificationController get instance => get<NotificationController>();
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  NotificationDetails? _androidNotificationDetails;
  NotificationDetails? _iosNotificationDetails;

  NotificationDetails? get notificationDetailsForPlatform {
    switch (Platform.operatingSystem) {
      case "android":
        return androidNotificationDetails;

      case "ios":
        return iosNotificationDetails;
      default:
        return null;
    }
  }

  // A unique Notification ID
  int notificationIdCounter = 7 * 31;
  int stepCounterId = 24769;

  NotificationController(this.notificationsPlugin);

  NotificationDetails get androidNotificationDetails {
    if (_androidNotificationDetails == null) {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'com.happydevworks.steps_ahead',
        'Steps Ahead Notifications',
        channelDescription:
            'Notifications raised by Steps ahead app containing '
            'progress tracking information & other app related notifications',
        importance: Importance.max,
        priority: Priority.high,
        silent: true,
        color: kPrimaryColorValue.toColor!,
      );

      _androidNotificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
    }
    return _androidNotificationDetails!;
  }

  NotificationDetails get iosNotificationDetails {
    if (_iosNotificationDetails == null) {
      const iosPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: true,
        presentSound: false,
        subtitle: 'Steps ahead app containing progress tracking information '
            '& other app related notifications',
      );

      _iosNotificationDetails = const NotificationDetails(
        iOS: iosPlatformChannelSpecifics,
      );
    }
    return _iosNotificationDetails!;
  }

  Future<void> initialize() async {
    switch (Platform.operatingSystem) {
      case "android":
        await androidPermissionSetup();
        break;

      case "ios":
        await iosPermissionSetup();
        break;
      default:
        showToast(
          "Unknown Platform(${Platform.operatingSystem}) Detected!!,"
          " Can't show App notifications",
          showLonger: true,
        );
        return;
    }

    const initializationSettingsAndroid = AndroidInitializationSettings(
      'logo_transparent',
    );

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotificationCallback,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          onDidReceiveNotificationResponseCallback,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponseCallback,
    );
  }

  Future<void> androidPermissionSetup() async {
    var androidNotificationPermissionGranted = await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    androidNotificationPermissionGranted ??= false;
    if (!androidNotificationPermissionGranted) {
      showToast(
        "Please allow the permission to show notifications from the app settings",
        showLonger: true,
      );
      return;
    }
  }

  Future<void> iosPermissionSetup() async {
    var iosNotificationPermissionGranted = await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    iosNotificationPermissionGranted ??= false;
    if (!iosNotificationPermissionGranted) {
      showToast(
        "Please allow the permission to show notifications from the app settings",
        showLonger: true,
      );
      return;
    }
  }

  Future<int> showNotificationWithId({
    required int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {
    notificationDetails ??= notificationDetailsForPlatform;

    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    return id;
  }

  Future<int> showNotification({
    String? title,
    String? body,
    NotificationDetails? notificationDetails,
    String? payload,
  }) async {
    notificationIdCounter++;
    return showNotificationWithId(
      id: notificationIdCounter,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  Future<void> cancelNotification({required int id}) async {
    return notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotification() async {
    return notificationsPlugin.cancelAll();
  }
}

void onDidReceiveLocalNotificationCallback(
  int id,
  String? title,
  String? body,
  String? payload,
) {
  final prettyJSONString = getPrettyJSONString({
    "id": id,
    "title": title,
    "body": body,
    "payload": payload,
  });

  Log.d(
    message: "onDidReceiveLocalNotificationCallback : $prettyJSONString",
  );
}

void onDidReceiveNotificationResponseCallback(
  NotificationResponse details,
) {
  final prettyJSONString = getPrettyJSONString({
    "id": details.id,
    "actionId": details.actionId,
    "input": details.input,
    "payload": details.payload,
    "notificationResponseType": details.notificationResponseType,
  });

  Log.d(
    message: "onDidReceiveNotificationResponseCallback : $prettyJSONString",
  );
}

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponseCallback(
  NotificationResponse details,
) {
  final prettyJSONString = getPrettyJSONString({
    "id": details.id,
    "actionId": details.actionId,
    "input": details.input,
    "payload": details.payload,
    "notificationResponseType": details.notificationResponseType,
  });

  Log.d(
    message: "onDidReceiveNotificationResponseCallback : $prettyJSONString",
  );
}
