import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:steps_ahead/constants.dart';
import 'package:steps_ahead/src/controllers/controllers.dart';
import 'package:steps_ahead/src/utils/transformer_utils.dart';

class DetailedStats extends StatefulWidget {
  const DetailedStats({super.key});

  @override
  State<DetailedStats> createState() => _DetailedStatsState();
}

class _DetailedStatsState extends State<DetailedStats> {
  List<StepData> stepsData = [];

  @override
  void initState() {
    super.initState();
    stepsData = getStepDataForChart();
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
          tooltipBgColor: Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              TextStyle(
                color: kCyanColorValue.toColor!,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
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

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          kDarkBlueColorValue.toColor!,
          kCyanColorValue.toColor!,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> getBarGroups(List<StepData> data) =>
      data.asMap().keys.map((e) {
        return BarChartGroupData(
          x: e,
          barRods: [
            BarChartRodData(
              toY: stepsData[e].steps.toDouble(),
              gradient: _barsGradient,
              width: 24,
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
      children: [
        const SizedBox(height: 24),
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
                  maxY: maxY,
                ))
              : const Expanded(
                  child: Center(
                    child: Text("No Data to display"),
                  ),
                ),
        ),
      ],
    );
  }
}
