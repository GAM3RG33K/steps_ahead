import 'package:steps_ahead/src/utils/utils.dart';

class StepData {
  final DateTime lastUpdateTimeStamp;
  final int steps;
  final bool goalAchieved;

  StepData({
    required this.lastUpdateTimeStamp,
    required this.steps,
    this.goalAchieved = false,
  });

  factory StepData.fromCount(int stepsCount) {
    return StepData(
      lastUpdateTimeStamp: DateTime.now(),
      steps: stepsCount,
    );
  }

  String get baseDateString =>
      lastUpdateTimeStamp.toIso8601String().split("T")[0];

  DateTime get baseDate => DateTime.parse(baseDateString);

  factory StepData.fromJson(JSON json) {
    return StepData(
      steps: json["steps"] ?? 0,
      lastUpdateTimeStamp: json["lastUpdateTimeStamp"] == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(
              json["lastUpdateTimeStamp"] as int,
            ),
    );
  }

  JSON toJson() {
    return {
      "steps": steps,
      "lastUpdateTimeStamp": lastUpdateTimeStamp.millisecondsSinceEpoch,
    };
  }

  StepData addSteps(int steps) {
    return StepData(
      lastUpdateTimeStamp: DateTime.now(),
      steps: this.steps + steps,
    );
  }

  StepData copyWith({
    DateTime? timeStamp,
    int? steps,
    bool? goalAchieved,
  }) {
    return StepData(
      lastUpdateTimeStamp: timeStamp ?? lastUpdateTimeStamp,
      steps: steps ?? this.steps,
      goalAchieved: goalAchieved ?? this.goalAchieved,
    );
  }
}
