// services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 获取当前用户ID
  String? get currentUserId => _auth.currentUser?.uid;

  // 提醒集合引用
  CollectionReference get _remindersCollection =>
      _firestore.collection('reminders');

  // 获取用户的所有提醒
  Stream<List<ReminderModel>> getUserReminders() {
    if (currentUserId == null) return Stream.value([]);

    return _remindersCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('time', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ReminderModel.fromFirestore(doc))
                  .toList(),
        );
  }

  // 添加新提醒
  Future<void> addReminder(ReminderModel reminder) async {
    if (currentUserId == null) throw Exception('User not logged in');

    await _remindersCollection.doc(reminder.id).set({
      ...reminder.toMap(),
      'userId': currentUserId,
    });
  }

  // 更新提醒
  Future<void> updateReminder(ReminderModel reminder) async {
    if (currentUserId == null) throw Exception('User not logged in');

    await _remindersCollection.doc(reminder.id).update({
      ...reminder.toMap(),
      'userId': currentUserId,
    });
  }

  // 删除提醒
  Future<void> deleteReminder(String reminderId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    await _remindersCollection.doc(reminderId).delete();
  }

  // 匿名登录
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      print('Successfully signed in anonymously: ${userCredential.user?.uid}');
      return userCredential;
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }

  // 检查用户是否已登录
  bool get isUserLoggedIn => _auth.currentUser != null;
}
