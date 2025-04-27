// screens/reminder_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import 'new_reminder_screen.dart';
import 'my_reminders_screen.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ReminderModel? _editingReminder;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _editReminder(ReminderModel reminder) {
    setState(() {
      _editingReminder = reminder;
    });
    _tabController.animateTo(0);
  }

  void _onSave() {
    setState(() {
      _editingReminder = null;
    });
    _tabController.animateTo(1);
  }

  void _createNewReminder() {
    setState(() {
      _editingReminder = null;
    });
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'New Reminder'), Tab(text: 'My Reminders')],
        ),
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          if (reminderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reminderProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${reminderProvider.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 重新初始化 provider
                      Provider.of<ReminderProvider>(
                        context,
                        listen: false,
                      ).reinitialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              NewReminderScreen(
                editingReminder: _editingReminder,
                onSave: _onSave,
              ),
              MyRemindersScreen(
                onEdit: _editReminder,
                onCreateNew: _createNewReminder,
              ),
            ],
          );
        },
      ),
    );
  }
}
