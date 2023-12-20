class StepsData {
  final DateTime lastUpdateTimeStamp;
  final int stepsCount;

  StepsData({
    required this.lastUpdateTimeStamp,
    required this.stepsCount,
  });

  factory StepsData.fromCount(int stepsCount) {
    return StepsData(
      lastUpdateTimeStamp: DateTime.now(),
      stepsCount: stepsCount,
    );
  }

  factory StepsData.fromCountWithTimeStamp({
    required int stepsCount,
    required DateTime lastUpdatedTimestamp,
  }) {
    return StepsData(
      lastUpdateTimeStamp: lastUpdatedTimestamp,
      stepsCount: stepsCount,
    );
  }

  String get baseDateString =>
      lastUpdateTimeStamp.toIso8601String().split("T")[0];

  DateTime get baseDate => DateTime.parse(baseDateString);
}
