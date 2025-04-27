// services/simple_notification_manager.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

class SimpleNotificationManager {
  static final SimpleNotificationManager _instance =
      SimpleNotificationManager._internal();
  factory SimpleNotificationManager() => _instance;
  SimpleNotificationManager._internal();

  Timer? _timer;
  List<ReminderModel> _reminders = [];
  BuildContext? _context;

  void init(BuildContext context) {
    _context = context;
    startChecking();
  }

  void updateReminders(List<ReminderModel> reminders) {
    _reminders = reminders;
  }

  void startChecking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkReminders();
    });
  }

  void _checkReminders() {
    if (_context == null || _reminders.isEmpty) return;

    final now = DateTime.now();
    for (var reminder in _reminders) {
      if (_shouldNotify(reminder, now)) {
        _showNotification(reminder);
      }
    }
  }

  bool _shouldNotify(ReminderModel reminder, DateTime now) {
    // 检查是否在提醒时间的前后1分钟内
    final difference = reminder.time.difference(now).inMinutes.abs();
    return difference <= 1 && now.second < 30; // 避免重复提醒
  }

  void _showNotification(ReminderModel reminder) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.alarm, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Activity Reminder'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reminder.activity,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'It\'s time for your scheduled activity!',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Dismiss'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    _context = null;
  }
}
