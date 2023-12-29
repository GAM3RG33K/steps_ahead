import 'package:flutter/material.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/screens/screens.dart';

class StatsTab extends StatefulWidget {
  final Stream<StepData> stepCountStream;
  final int dailyGoal;

  const StatsTab({
    super.key,
    required this.stepCountStream,
    required this.dailyGoal,
  });

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  List<String> get tabs => ["Details", "Summary"];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Stats',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            bottom: TabBar(
              tabs: tabs
                  .map(
                    (e) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(e),
                ),
              )
                  .toList(),
            ),
          ),
          body: TabBarView(
            children: tabs.map((e) {
              return _buildTab(e);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String tabName) {
    return Builder(
      builder: (context) {
        switch (tabName) {
          case "Summary":
            return const SummaryStats();
          case "Details":
          default:
            return const DetailedStats();
        }
      },
    );
  }
}
