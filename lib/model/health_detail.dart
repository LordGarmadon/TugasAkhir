import 'package:cloud_firestore/cloud_firestore.dart';

class HealthDetail {
  HealthDetail({
    required this.userId,
    required this.systole,
    required this.diastole,
    required this.recordedTime,
  });

  HealthDetail.fromJson(Map<String, Object?> json)
      : this(
          userId: json['user_id']! as String,
          systole: json['sistol']! as int,
          diastole: json['diastol']! as int,
          recordedTime: json['recorded_time']! as Timestamp,
        );

  final String userId;
  final int systole;
  final int diastole;
  final Timestamp recordedTime;

  Map<String, Object?> toJson() {
    return {
      'user_id': userId,
      'sistol': systole,
      'diastol': diastole,
      'recorded_time': recordedTime,
    };
  }
}
