import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/controllers/notifications/app_forground_service_controller.dart';
import 'package:steps_ahead/src/screens/screens.dart';

import 'src/utils/utils.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await registerDependencies();

    runApp(const MyApp());
  }, (error, stackTrace) {
    Log.e(
        error: error,
        stackTrace: stackTrace,
        message: "main: runZonedGuarded : ");
  });
}

Future<void> registerDependencies() async {
  registerSingleton(FormulaUtils());
  final notificationController = AppNotificationController(
    FlutterLocalNotificationsPlugin(),
  );
  await notificationController.initialize();
  registerSingleton(notificationController);

  final foregroundServiceController = AppForegroundServiceController();
  await foregroundServiceController.initialize();
  registerSingleton(foregroundServiceController);

  await PedometerApi.registerForDI();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    PedometerApi.instance.onAppLifecycleStateChange(
      state,
      processState: (state) async {
        if (state == AppLifecycleState.paused) {
          final steps = PedometerApi.instance.currentSteps;
          final notificationTitle = "$steps steps till now";
          const notificationText = "Click here to get real-time updates";
          AppForegroundServiceController.instance.updateForegroundTask(
            notificationTitle: notificationTitle,
            notificationText: notificationText,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kProjectName,
      theme: buildThemeData(),
      home: const WithForegroundTask(child: SplashScreen()),
    );
  }

  ThemeData buildThemeData() {
    final themeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColorValue.toColor!,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
    return themeData.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(themeData.textTheme),
    );
  }
}
