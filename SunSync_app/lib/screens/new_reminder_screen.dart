// screens/new_reminder_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';
import '../providers/weather_provider.dart';

class NewReminderScreen extends StatefulWidget {
  final ReminderModel? editingReminder;
  final VoidCallback? onSave;
  final String? preSelectedActivity;

  const NewReminderScreen({
    Key? key,
    this.editingReminder,
    this.onSave,
    this.preSelectedActivity,
  }) : super(key: key);

  @override
  State<NewReminderScreen> createState() => _NewReminderScreenState();
}

class _NewReminderScreenState extends State<NewReminderScreen> {
  String? _selectedActivity;
  String _selectedTimingOption = 'Sunrise';
  DateTime _reminderDateTime = DateTime.now();
  bool _enableNotification = true;
  bool _enableRepeat = false;
  bool _isCustomTime = false;
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _activities = [
    'Running',
    'Walking',
    'Yoga',
    'Photography',
    'Meditation',
    'Exercise',
    'Cycling',
    'Hiking',
  ];

  final List<String> _timingOptions = ['Sunrise', 'Sunset', 'Custom time'];

  @override
  void initState() {
    super.initState();
    if (widget.editingReminder != null) {
      _setupEditMode();
    } else {
      _selectedActivity = _activities[0];
      _updateReminderDateTime();
    }

    // 监听天气数据变化，更新日出日落时间
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).addListener(_onWeatherDataChanged);
    });
  }

  @override
  void dispose() {
    Provider.of<WeatherProvider>(
      context,
      listen: false,
    ).removeListener(_onWeatherDataChanged);
    super.dispose();
  }

  void _onWeatherDataChanged() {
    if (!_isCustomTime) {
      setState(() {
        _updateReminderDateTime();
      });
    }
  }

  void _setupEditMode() {
    _selectedActivity = widget.editingReminder!.activity;
    _reminderDateTime = widget.editingReminder!.time;
    _selectedTimingOption = widget.editingReminder!.timingOption;
    _isCustomTime = widget.editingReminder!.isCustomTime;
    _enableNotification = widget.editingReminder!.enableNotification;
    _enableRepeat = widget.editingReminder!.enableRepeat;

    if (_isCustomTime) {
      _selectedTime = TimeOfDay.fromDateTime(widget.editingReminder!.time);
    }
  }

  void _updateReminderDateTime() {
    if (_selectedTimingOption == 'Custom time') {
      _isCustomTime = true;
      final now = DateTime.now();
      _reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
    } else {
      _isCustomTime = false;
      // 从 WeatherProvider 获取实际的日出日落时间
      final weatherProvider = Provider.of<WeatherProvider>(
        context,
        listen: false,
      );

      if (_selectedTimingOption == 'Sunrise' &&
          weatherProvider.sunrise != null) {
        _reminderDateTime = weatherProvider.sunrise!;
      } else if (_selectedTimingOption == 'Sunset' &&
          weatherProvider.sunset != null) {
        _reminderDateTime = weatherProvider.sunset!;
      } else {
        // 如果天气数据不可用，使用默认值
        final now = DateTime.now();
        if (_selectedTimingOption == 'Sunrise') {
          _reminderDateTime = DateTime(now.year, now.month, now.day, 6, 0);
        } else {
          _reminderDateTime = DateTime(now.year, now.month, now.day, 18, 0);
        }
      }
    }
  }

  void _showCustomTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const Text(
                      'Select Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _updateReminderDateTime();
                        });
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  ),
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedTime = TimeOfDay(
                        hour: newDateTime.hour,
                        minute: newDateTime.minute,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveReminder() async {
    final reminder = ReminderModel(
      id:
          widget.editingReminder?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      activity: _selectedActivity!,
      time: _reminderDateTime,
      isCustomTime: _isCustomTime,
      timingOption: _selectedTimingOption,
      enableNotification: _enableNotification,
      enableRepeat: _enableRepeat,
    );

    final provider = Provider.of<ReminderProvider>(context, listen: false);

    try {
      if (widget.editingReminder != null) {
        await provider.updateReminder(widget.editingReminder!.id, reminder);
      } else {
        await provider.addReminder(reminder);
      }

      if (widget.onSave != null) {
        widget.onSave!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.editingReminder != null
                ? 'Reminder updated'
                : 'Reminder saved',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving reminder: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedActivity,
                items:
                    _activities.map((activity) {
                      return DropdownMenuItem(
                        value: activity,
                        child: Text(activity),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivity = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'When',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isCustomTime ? Colors.blue[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _isCustomTime ? Icons.access_time : Icons.wb_sunny,
                  color: _isCustomTime ? Colors.blue[700] : Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedTimingOption,
                      items:
                          _timingOptions.map((timing) {
                            return DropdownMenuItem(
                              value: timing,
                              child: Text(timing),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTimingOption = value!;
                          if (value == 'Custom time') {
                            _isCustomTime = true;
                            _showCustomTimePicker();
                          } else {
                            _isCustomTime = false;
                            _updateReminderDateTime();
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: _isCustomTime ? _showCustomTimePicker : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isCustomTime ? Colors.blue[200]! : Colors.grey[200]!,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          DateFormat('HH:mm').format(_reminderDateTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isCustomTime)
                    Icon(Icons.edit, color: Colors.blue[400], size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _reminderDateTime = _reminderDateTime.subtract(
                        const Duration(minutes: 15),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[100],
                    foregroundColor: Colors.blue,
                    elevation: 0,
                  ),
                  child: const Text('-15 min'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _reminderDateTime = _reminderDateTime.add(
                        const Duration(minutes: 15),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[100],
                    foregroundColor: Colors.blue,
                    elevation: 0,
                  ),
                  child: const Text('+15 min'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Notification',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enable Notification'),
                  Text(
                    'Receive alerts for this activity',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Switch(
                value: _enableNotification,
                onChanged: (value) {
                  setState(() {
                    _enableNotification = value;
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Repeat Daily'),
                  Text(
                    'Reminder will repeat every day',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Switch(
                value: _enableRepeat,
                onChanged: (value) {
                  setState(() {
                    _enableRepeat = value;
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                widget.editingReminder != null ? 'Update' : 'Save',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
