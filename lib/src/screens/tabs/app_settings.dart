import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildSettingTile(
              title: "System Settings",
              subtitle: "Open System settings for this app",
              onClick: () async {
                await AppSettings.openAppSettings(
                  type: AppSettingsType.settings,
                );
              },
            ),
            buildSeparator(),
            buildTitle("Goals"),
            buildSettingTile(
              title: "Daily Goal",
              subtitle: pedometerController.dailyGoal.toString(),
              onClick: () async {
                final input = await getInputFromUser(
                  context: context,
                  title: "Daily Goal",
                  message: pedometerController.dailyGoal.toString(),
                  keyboardType: TextInputType.number,
                );
                setState(() {
                  final number = num.tryParse(input ?? '')?.toInt();
                  if (number != null) {
                    pedometerController.dailyGoal = number;
                  }
                });
              },
            ),
            buildSeparator(),
            buildTitle("Advanced"),
            buildDropdownSettingTile<int>(
              title: "Speed",
              items: speedInformationMap.keys.map(
                (index) {
                  final e = speedInformationMap[index]!;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      e["title"],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ).toList(),
              onChange: (value) {
                if (value == null) return;
                pedometerController.speedIndex = value;
                setState(() {});
              },
              defaultValue: pedometerController.speedIndex,
            ),
            buildSettingTile(
              title: "Height in cm",
              subtitle: pedometerController.userHeightInCms.toString(),
              onClick: () async {
                final input = await getInputFromUser(
                  context: context,
                  title: "Height in cm",
                  message: pedometerController.userHeightInCms.toString(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (input) {
                    final number = num.tryParse(input ?? '')?.toInt();
                    if (number != null && number > 0 || !(number!.isInfinite)) {
                      return true;
                    }
                    return false;
                  },
                );
                setState(() {
                  final number = num.tryParse(input ?? '')?.toInt();
                  if (number != null) {
                    pedometerController.userHeightInCms = number;
                  }
                });
              },
            ),
            buildSettingTile(
              title: "Weight in kg",
              subtitle: pedometerController.userWeightInKgs.toString(),
              onClick: () async {
                final input = await getInputFromUser(
                  context: context,
                  title: "Weight in kg",
                  message: pedometerController.userWeightInKgs.toString(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (input) {
                    final number = num.tryParse(input ?? '')?.toDouble();
                    if (number != null && number > 0 || !(number!.isInfinite)) {
                      return true;
                    }
                    return false;
                  },
                );
                setState(() {
                  final number = num.tryParse(input ?? '')?.toDouble();
                  if (number != null) {
                    pedometerController.userWeightInKgs = number;
                  }
                });
              },
            ),
            buildSettingTile(
              title: "Step length in cm",
              subtitle: pedometerController.stepLength.toString(),
              onClick: () async {
                final input = await getInputFromUser(
                  context: context,
                  title: "Step length in cm",
                  message: pedometerController.stepLength.toString(),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (input) {
                    final number = num.tryParse(input ?? '')?.toDouble();
                    if (number != null && number > 0 || !(number!.isInfinite)) {
                      return true;
                    }
                    return false;
                  },
                );
                setState(() {
                  final number = num.tryParse(input ?? '')?.toDouble();
                  if (number != null) {
                    pedometerController.stepLength = number;
                  }
                });
              },
            ),
            buildSettingTile(
              title: "BMI - ${pedometerController.userBMI.toStringAsFixed(2)}",
              subtitle:
                  "Body Mass Index, It's a measurement tool used to estimate the amount of body fat.*",
              isEnabled: false,
            ),
            buildSettingTile(
              title:
                  "MET Value - ${pedometerController.userMETValue.toStringAsFixed(2)}",
              subtitle:
                  "Metabolic Equivalent of Task (MET) concept assigns values to activities based on their intensity relative to resting metabolic rate.*",
              isEnabled: false,
            ),
            buildSeparator(),
            buildTitle("About"),
            buildSettingTile(
              title: "Github",
              subtitle:
                  "Checkout the app's source code. File issues or suggestions here to improve this app",
              onClick: () async {
                var canLaunch = await canLaunchUrlString(kAppRepositoryUrl);
                if (canLaunch) {
                  launchUrlString(kAppRepositoryUrl);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: kPrimaryColorValue.toColor!,
          ),
    );
  }

  Widget buildSettingTile({
    required String title,
    String? subtitle,
    VoidCallback? onClick,
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        enabled: isEnabled,
        dense: true,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            : null,
        onTap: onClick,
      ),
    );
  }

  Widget buildDropdownSettingTile<T>({
    required String title,
    String? subtitle,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChange,
    T? defaultValue,
    bool isEnabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        enabled: isEnabled,
        dense: true,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: DropdownButton<T>(
          items: items,
          onChanged: onChange,
          value: defaultValue,
          isDense: true,
        ),
      ),
    );
  }

  Widget buildSeparator() {
    return const Divider();
  }
}
