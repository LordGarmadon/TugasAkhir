class ReadableDetail {
  ReadableDetail({
    required this.name,
    required this.systole,
    required this.diastole,
    required this.recordedTime,
  });

  final String name;
  final int systole;
  final int diastole;
  final String recordedTime;

  Map<String, Object?> toJson() {
    return {
      'nama': name,
      'sistol': systole,
      'diastol': diastole,
      'recorded_time': recordedTime,
    };
  }
}
