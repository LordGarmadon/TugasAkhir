import 'package:cloud_firestore/cloud_firestore.dart';

class HealthDetail {
  HealthDetail({
    required this.email,
    required this.systole,
    required this.diastole,
    required this.recordedTime,
  });

  HealthDetail.fromJson(Map<String, Object?> json)
      : this(
          email: json['email']! as String,
          systole: json['systole']! as String,
          diastole: json['diastole']! as String,
          recordedTime: json['recorded_time']! as Timestamp,
        );

  final String email;
  final String systole;
  final String diastole;
  final Timestamp recordedTime;

  Map<String, Object?> toJson() {
    return {
      'email': email,
      'systole': systole,
      'diastole': diastole,
      'recorded_time': recordedTime,
    };
  }
}
