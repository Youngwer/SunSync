// models/reminder_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String activity;
  final DateTime time;
  final bool isCustomTime;
  final String timingOption;
  final bool enableNotification;
  final bool enableRepeat;
  final String? userId; // 添加用户ID以支持多用户

  ReminderModel({
    required this.id,
    required this.activity,
    required this.time,
    required this.isCustomTime,
    required this.timingOption,
    required this.enableNotification,
    required this.enableRepeat,
    this.userId,
  });

  // 将 ReminderModel 转换为 Map 以存储到 Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity': activity,
      'time': Timestamp.fromDate(time),
      'isCustomTime': isCustomTime,
      'timingOption': timingOption,
      'enableNotification': enableNotification,
      'enableRepeat': enableRepeat,
      'userId': userId,
    };
  }

  // 从 Firestore 的 Map 创建 ReminderModel
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? '',
      activity: map['activity'] ?? '',
      time: (map['time'] as Timestamp).toDate(),
      isCustomTime: map['isCustomTime'] ?? false,
      timingOption: map['timingOption'] ?? 'Near sunrise',
      enableNotification: map['enableNotification'] ?? true,
      enableRepeat: map['enableRepeat'] ?? false,
      userId: map['userId'],
    );
  }

  // 从 Firestore 文档创建 ReminderModel
  factory ReminderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReminderModel.fromMap(data);
  }
}
