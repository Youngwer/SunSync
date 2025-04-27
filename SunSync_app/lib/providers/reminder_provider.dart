// providers/reminder_provider.dart

import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../services/firebase_service.dart';
import '../services/simple_notification_manager.dart';

class ReminderProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final SimpleNotificationManager _notificationManager =
      SimpleNotificationManager();

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReminderProvider() {
    _initializeProvider();
  }

  // 初始化 Provider
  Future<void> _initializeProvider() async {
    _isLoading = true;
    _error = null; // 清除之前的错误
    notifyListeners();

    try {
      // 如果用户未登录，先进行匿名登录
      if (!_firebaseService.isUserLoggedIn) {
        print('User not logged in, attempting anonymous login...');
        await _firebaseService.signInAnonymously();
      } else {
        print('User already logged in: ${_firebaseService.currentUserId}');
      }

      // 监听 Firestore 的变化
      _firebaseService.getUserReminders().listen(
        (remindersList) {
          _reminders = remindersList;
          _notificationManager.updateReminders(_reminders); // 更新通知管理器的提醒列表
          _isLoading = false;
          _error = null;
          notifyListeners();
        },
        onError: (error) {
          print('Error in Firestore listener: $error');
          _error = error.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      print('Error in provider initialization: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 公共方法用于重新初始化
  Future<void> reinitialize() async {
    await _initializeProvider();
  }

  // 添加提醒
  Future<void> addReminder(ReminderModel reminder) async {
    try {
      await _firebaseService.addReminder(reminder);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // 更新提醒
  Future<void> updateReminder(String id, ReminderModel updatedReminder) async {
    try {
      await _firebaseService.updateReminder(updatedReminder);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // 删除提醒
  Future<void> deleteReminder(String id) async {
    try {
      await _firebaseService.deleteReminder(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _notificationManager.dispose();
    super.dispose();
  }
}
