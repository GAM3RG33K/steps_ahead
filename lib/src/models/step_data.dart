import 'package:steps_ahead/src/utils/utils.dart';

class StepData {
  final DateTime lastUpdateTimeStamp;
  final int steps;
  final bool goalAchieved;
  final int goalAtTheTime;

  StepData({
    required this.lastUpdateTimeStamp,
    required this.steps,
    required this.goalAtTheTime,
    this.goalAchieved = false,
  });

  factory StepData.fromCount(int stepsCount, int goalAtTheTime) {
    return StepData(
      lastUpdateTimeStamp: DateTime.now(),
      steps: stepsCount,
      goalAtTheTime: goalAtTheTime,
    );
  }

  String get baseDateString =>
      lastUpdateTimeStamp.toIso8601String().split("T")[0];

  DateTime get baseDate => DateTime.parse(baseDateString);

  int get progress => FormulaUtils.instance.calculateProgressForStepsAndGoal(
        currentSteps: steps,
        dailyGoal: goalAtTheTime,
      );

  factory StepData.fromJson(JSON json) {
    return StepData(
      steps: json["steps"] ?? 0,
      goalAtTheTime: json["goalAtTheTime"] ?? 1,
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
      "goalAtTheTime": goalAtTheTime,
    };
  }

  StepData addSteps(int steps) {
    return StepData(
      lastUpdateTimeStamp: DateTime.now(),
      steps: this.steps + steps,
      goalAtTheTime: goalAtTheTime,
    );
  }

  StepData copyWith({
    DateTime? timeStamp,
    int? steps,
    bool? goalAchieved,
    int? goalAtTheTime,
  }) {
    return StepData(
      lastUpdateTimeStamp: timeStamp ?? lastUpdateTimeStamp,
      steps: steps ?? this.steps,
      goalAchieved: goalAchieved ?? this.goalAchieved,
      goalAtTheTime: goalAtTheTime ?? this.goalAtTheTime,
    );
  }
}
