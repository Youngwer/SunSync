// screens/my_reminders_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';

class MyRemindersScreen extends StatelessWidget {
  final Function(ReminderModel) onEdit;
  final Function() onCreateNew;

  const MyRemindersScreen({
    Key? key,
    required this.onEdit,
    required this.onCreateNew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        if (reminderProvider.reminders.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminderProvider.reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminderProvider.reminders[index];
            return _buildReminderCard(context, reminder);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onCreateNew,
            child: const Text('Create your first reminder'),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, ReminderModel reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActivityIcon(reminder.activity),
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.activity,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(reminder.time),
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEdit(reminder),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteReminder(context, reminder.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  reminder.timingOption,
                  reminder.isCustomTime ? Icons.access_time : Icons.wb_sunny,
                  reminder.isCustomTime ? Colors.blue : Colors.orange,
                ),
                const SizedBox(width: 8),
                if (reminder.enableRepeat)
                  _buildInfoChip('Daily', Icons.repeat, Colors.green),
                const SizedBox(width: 8),
                if (reminder.enableNotification)
                  _buildInfoChip(
                    'Notifications',
                    Icons.notifications,
                    Colors.purple,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'walking':
        return Icons.directions_walk;
      case 'yoga':
        return Icons.self_improvement;
      case 'photography':
        return Icons.camera_alt;
      case 'meditation':
        return Icons.spa;
      case 'exercise':
        return Icons.fitness_center;
      case 'cycling':
        return Icons.pedal_bike;
      case 'hiking':
        return Icons.terrain;
      default:
        return Icons.alarm;
    }
  }

  void _deleteReminder(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await Provider.of<ReminderProvider>(
                    context,
                    listen: false,
                  ).deleteReminder(id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting reminder: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
