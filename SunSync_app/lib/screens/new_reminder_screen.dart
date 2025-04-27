// Updated new_reminder_screen.dart with proper preSelectedActivity handling

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

  final List<Map<String, dynamic>> _activities = [
    {'name': 'Running', 'icon': Icons.directions_run, 'color': Colors.orange},
    {'name': 'Walking', 'icon': Icons.directions_walk, 'color': Colors.green},
    {'name': 'Yoga', 'icon': Icons.self_improvement, 'color': Colors.purple},
    {'name': 'Photography', 'icon': Icons.camera_alt, 'color': Colors.blue},
    {'name': 'Meditation', 'icon': Icons.spa, 'color': Colors.teal},
    {'name': 'Exercise', 'icon': Icons.fitness_center, 'color': Colors.red},
    {'name': 'Cycling', 'icon': Icons.pedal_bike, 'color': Colors.amber},
    {'name': 'Hiking', 'icon': Icons.terrain, 'color': Colors.brown},
  ];

  final List<Map<String, dynamic>> _timingOptions = [
    {'name': 'Sunrise', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    {'name': 'Sunset', 'icon': Icons.nights_stay, 'color': Colors.indigo},
    {'name': 'Custom time', 'icon': Icons.access_time, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editingReminder != null) {
      _setupEditMode();
    } else {
      // 处理预选活动
      if (widget.preSelectedActivity != null) {
        _selectedActivity = widget.preSelectedActivity;
      } else {
        _selectedActivity = _activities[0]['name'];
      }
      _updateReminderDateTime();
    }

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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: 340,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'Select Time',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _updateReminderDateTime();
                        });
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                widget.editingReminder != null
                    ? 'Reminder updated successfully'
                    : 'Reminder created successfully',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error saving reminder: ${e.toString()}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.white, Colors.blue[50]!],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _activities.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  final isSelected = _selectedActivity == activity['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedActivity = activity['name'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 95,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors:
                              isSelected
                                  ? [
                                    (activity['color'] as Color).withOpacity(
                                      0.8,
                                    ),
                                    (activity['color'] as Color),
                                  ]
                                  : [Colors.white, Colors.grey[50]!],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected
                                  ? (activity['color'] as Color)
                                  : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                isSelected
                                    ? (activity['color'] as Color).withOpacity(
                                      0.3,
                                    )
                                    : Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            activity['icon'] as IconData,
                            size: 32,
                            color:
                                isSelected
                                    ? Colors.white
                                    : activity['color'] as Color,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activity['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  isSelected ? Colors.white : Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'When',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),

            // 时间选择器
            SizedBox(
              height: 120,
              child: Row(
                children:
                    _timingOptions.map((option) {
                      final isSelected =
                          _selectedTimingOption == option['name'];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTimingOption = option['name'];
                              if (option['name'] == 'Custom time') {
                                _isCustomTime = true;
                                _showCustomTimePicker();
                              } else {
                                _isCustomTime = false;
                                _updateReminderDateTime();
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors:
                                    isSelected
                                        ? [
                                          (option['color'] as Color)
                                              .withOpacity(0.8),
                                          (option['color'] as Color),
                                        ]
                                        : [Colors.white, Colors.grey[50]!],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? (option['color'] as Color)
                                        : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isSelected
                                          ? (option['color'] as Color)
                                              .withOpacity(0.3)
                                          : Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  option['icon'] as IconData,
                                  size: 30,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : option['color'] as Color,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  option['name'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (isSelected) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat(
                                      'HH:mm',
                                    ).format(_reminderDateTime),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 时间微调按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _reminderDateTime = _reminderDateTime.subtract(
                          const Duration(minutes: 15),
                        );
                      });
                    },
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    label: const Text('15 min'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.blue[200]!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _reminderDateTime = _reminderDateTime.add(
                          const Duration(minutes: 15),
                        );
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('15 min'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.blue[200]!),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 设置选项
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    'Notification',
                    Icons.notifications_active,
                    Colors.purple,
                    _enableNotification,
                    (value) {
                      setState(() {
                        _enableNotification = value;
                      });
                    },
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  _buildSettingItem(
                    'Repeat Daily',
                    Icons.repeat,
                    Colors.green,
                    _enableRepeat,
                    (value) {
                      setState(() {
                        _enableRepeat = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: Colors.blue.withOpacity(0.5),
                ),
                child: Text(
                  widget.editingReminder != null
                      ? 'Update Reminder'
                      : 'Save Reminder',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: color,
                  activeTrackColor: color.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
