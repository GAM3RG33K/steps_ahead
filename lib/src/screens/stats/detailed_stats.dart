import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/utils/utils.dart';

class DetailedStats extends StatefulWidget {
  const DetailedStats({super.key});

  @override
  State<DetailedStats> createState() => _DetailedStatsState();
}

class _DetailedStatsState extends State<DetailedStats> {
  List<StepData> stepsData = [];

  StepData? currentStep;

  @override
  void initState() {
    super.initState();
    stepsData = getStepDataForChart();
    currentStep = stepsData.last;
  }

  List<StepData> getStepDataForChart() {
    final endDate = DateTime.now().toDate!;
    final startDate = endDate.subtract(const Duration(days: 7)).toDate!;
    final data = PedometerApi.instance.getStepDataForDateRange(
      startDateTime: startDate,
      endDateTime: endDate,
    );
    return data;
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              TextStyle(
                color: kCyanColorValue.toColor!,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
    touchCallback: (p0, p1) {
      final index = p1?.spot?.touchedBarGroup.x;
      if (index != null) {
        setState(() {
          currentStep = stepsData[index];
        });
      }
    },
      );

  Widget getTitles(StepData value, TitleMeta meta) {
    final style = TextStyle(
      color: kDarkBlueColorValue.toColor!,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(value.baseDate.day.toString(), style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => getTitles(
              stepsData[value.toInt()],
              meta,
            ),
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient getBarsGradient({
    bool isSelected = false,
  }) {
    var barColors = [
      kDarkBlueColorValue.toColor!,
      kCyanColorValue.toColor!,
    ];

    if (isSelected) {
      barColors = [
        kDarkBlueColorValue.toColor!,
        kDarkBlueColorValue.toColor!,
      ];
    }

    return LinearGradient(
      colors: barColors,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }

  List<BarChartGroupData> getBarGroups(List<StepData> data) =>
      data.asMap().keys.map((e) {
        var stepData = stepsData[e];
        return BarChartGroupData(
          x: e,
          barRods: [
            BarChartRodData(
              toY: stepData.steps.toDouble(),
              gradient: getBarsGradient(isSelected: stepData == currentStep),
              width: 32,
              borderRadius: BorderRadius.circular(2),
            )
          ],
          showingTooltipIndicators: [0],
        );
      }).toList();

  double get maxY {
    var maxSteps = stepsData
        .map((e) => e.steps)
        .reduce((value, element) => max<int>(value, element))
        .toDouble();
    return maxSteps + 500;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        const SizedBox(height: 36),
        SizedBox(
          height: 400,
          child: (stepsData.isNotEmpty)
              ? BarChart(BarChartData(
                  barTouchData: barTouchData,
                  titlesData: titlesData,
                  borderData: borderData,
                  barGroups: getBarGroups(stepsData),
                  gridData: const FlGridData(show: false),
                  alignment: BarChartAlignment.spaceAround,
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: PedometerApi.instance.dailyGoal.toDouble(),
                        strokeWidth: 1,
                        dashArray: [8, 4],
                        gradient: getBarsGradient(
                          isSelected: true,
                        ),
                        color: kGrayColorValue.toColor!,
                        label: HorizontalLineLabel(
                          show: true,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: kDarkBlueColorValue.toColor!,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  maxY: maxY,
                ))
              : const Expanded(
                  child: Center(
                    child: Text("No Data to display"),
                  ),
                ),
        ),
        if (currentStep != null) ...[
          InfoTile(
            context: context,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            title:
                "${PedometerApi.instance.calculateCaloriesBurnedFromSteps(currentStep!.steps).toStringAsFixed(2)} kcal",
            subtitle: "Calories Burned",
            icon: Icons.local_fire_department,
            iconColor: materialColor1,
            tileColor: materialColorLight1,
          ),
          InfoTile(
            context: context,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            title:
                "${PedometerApi.instance.distanceTravelledFromSteps(currentStep!.steps).toStringAsFixed(2)} km",
            subtitle: "Distance Travelled",
            icon: Icons.route,
            iconColor: materialColor4,
            tileColor: materialColorLight4,
          ),
          if (currentStep!.goalAchieved)
            InfoTile(
              context: context,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              title: "Tree collected",
              subtitle: "You have met your goal",
              icon: Icons.electric_bolt,
              iconColor: materialColor2,
              tileColor: materialColorLight2,
            ),
        ]
      ],
    );
  }
}
