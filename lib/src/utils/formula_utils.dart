import 'utils.dart';

class FormulaUtils {
  static FormulaUtils get instance {
    return get<FormulaUtils>();
  }

  FormulaUtils();

  int calculateProgressForStepsAndGoal({
    required int currentSteps,
    required int dailyGoal,
  }) {
    return (currentSteps * 100) ~/ dailyGoal;
  }

  double calculateAvgStepLength(
    int userHeightInCms,
    double stepLengthMultiplier,
  ) {
    final stepLength = userHeightInCms * stepLengthMultiplier;
    return stepLength;
  }

  double calculateBMI(
    int userHeightInCms,
    double userWeightInKgs,
  ) {
    final userHeightInMeters = (userHeightInCms / 100);
    final bmi = userWeightInKgs / (userHeightInMeters * userHeightInMeters);
    return bmi;
  }

  double calculateDistanceTravelledInCm(
    int stepCount,
    double stepLength,
  ) {
    final totalDistance = stepCount * stepLength;
    return totalDistance;
  }

  double calculateDistanceTravelledInKm(
    int stepCount,
    double stepLength,
  ) {
    final totalDistanceInCm =
        calculateDistanceTravelledInCm(stepCount, stepLength);
    final totalDistanceInKm = totalDistanceInCm / 100000;
    return totalDistanceInKm;
  }

  double calculateCaloriesBurned(
    double activityDurationInHours,
    double metValue,
    double weightInKgs,
  ) {
    final caloriesBurned = (metValue * weightInKgs * activityDurationInHours);
    return caloriesBurned;
  }

  double calculateActivityDurationInHours(
    double distance,
    double speed,
  ) {
    final durationInHours = distance / speed;
    return durationInHours;
  }
}
