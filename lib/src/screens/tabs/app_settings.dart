import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/utils/utils.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  int dailyGoal = kSettingsDefaultDailyGoal;

  @override
  void initState() {
    dailyGoal =
        pedometerController.storage.getSettingInt(kSettingsKeyDailyGoal) ??
            kSettingsDefaultDailyGoal;
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
              subtitle: dailyGoal.toString(),
              onClick: () async {
                final input = await getInputFromUser(
                  context: context,
                  title: "Daily Goal",
                  message: dailyGoal.toString(),
                  keyboardType: TextInputType.number,
                );
                setState(() {
                  final number = num.tryParse(input ?? '')?.toInt();
                  if (number != null) {
                    dailyGoal = number;
                    pedometerController.storage.setSettingInt(
                      kSettingsKeyDailyGoal,
                      dailyGoal,
                    );
                  }
                });
              },
            ),
            buildSeparator(),
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
    required VoidCallback onClick,
  }) {
    return ListTile(
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
      onTap: onClick,
    );
  }

  Widget buildSeparator() {
    return const Divider();
  }
}
