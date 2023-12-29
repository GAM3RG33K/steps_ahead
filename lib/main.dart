import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/screens/screens.dart';
import 'package:steps_ahead/src/utils/logs_utils.dart';
import 'package:steps_ahead/src/utils/transformer_utils.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await PedometerApi.registerForDI();

    runApp(const MyApp());
  }, (error, stackTrace) {
    Log.e(
        error: error,
        stackTrace: stackTrace,
        message: "main: runZonedGuarded : ");
  });
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
    PedometerApi.instance.onAppLifecycleStateChange(state);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kProjectName,
      theme: buildThemeData(),
      home: const SplashScreen(),
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
