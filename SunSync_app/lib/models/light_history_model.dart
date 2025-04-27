// models/light_history_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class LightHistoryModel {
  final String id;
  final DateTime timestamp;
  final int lightLevel; // 0-100
  final String userId;
  final DateTime date; // 只存储日期部分，用于按天查询

  LightHistoryModel({
    required this.id,
    required this.timestamp,
    required this.lightLevel,
    required this.userId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'lightLevel': lightLevel,
      'userId': userId,
      'date': Timestamp.fromDate(date),
    };
  }

  factory LightHistoryModel.fromMap(Map<String, dynamic> map) {
    return LightHistoryModel(
      id: map['id'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      lightLevel: map['lightLevel'] ?? 0,
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
    );
  }

  factory LightHistoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LightHistoryModel.fromMap(data);
  }
}
