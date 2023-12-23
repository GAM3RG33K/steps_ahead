// ignore_for_file: constant_identifier_names

enum PedestrianStatusEnum {
  walking,
  stopped,
  unknown,
}

/// A DTO for steps taken containing a detected step and its corresponding
/// status, i.e. walking, stopped or unknown.
class PedestrianStatusData {
  static const _WALKING = 'walking';
  static const _STOPPED = 'stopped';
  static const _UNKNOWN = 'unknown';

  static const Map<String, PedestrianStatusEnum> _STATUSES = {
    _UNKNOWN: PedestrianStatusEnum.unknown,
    _STOPPED: PedestrianStatusEnum.stopped,
    _WALKING: PedestrianStatusEnum.walking,
  };

  final DateTime timeStamp;
  final PedestrianStatusEnum status;

  PedestrianStatusData({
    this.status = PedestrianStatusEnum.unknown,
    DateTime? ts,
  }) : timeStamp = ts ?? DateTime.now();

  factory PedestrianStatusData.fromNativeData({
    required String type,
    DateTime? timestamp,
  }) {
    return PedestrianStatusData(
      status: _STATUSES[type]!,
      ts: timestamp,
    );
  }

  @override
  String toString() =>
      'Pedestrian Status: $status at ${timeStamp.toIso8601String()}';
}
