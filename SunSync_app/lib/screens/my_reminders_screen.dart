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

  final List<String> _timingOptions = ['Sunrise', 'Sunset', 'Custom time'];

  @override
  void initState() {
    super.initState();
    if (widget.editingReminder != null) {
      _setupEditMode();
    } else {
      _selectedActivity = _activities[0]['name'];
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
      builder: (BuildContext context) {
        return Container(
          height: 320,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                    Text(
                      'Select Time',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
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
                          color: Colors.blue[600],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[200]),
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
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving reminder: ${e.toString()}'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
          Text(
            'Select Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _activities.length,
              itemBuilder: (context, index) {
                final activity = _activities[index];
                final isSelected = _selectedActivity == activity['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedActivity = activity['name'];
                    });
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            isSelected
                                ? [
                                  (activity['color'] as Color).withOpacity(0.8),
                                  (activity['color'] as Color),
                                ]
                                : [Colors.grey[100]!, Colors.grey[200]!],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? (activity['color'] as Color)
                                : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              isSelected
                                  ? (activity['color'] as Color).withOpacity(
                                    0.3,
                                  )
                                  : Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
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
                            color: isSelected ? Colors.white : Colors.grey[800],
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

          const SizedBox(height: 32),

          Text(
            'When',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    _isCustomTime
                        ? [Colors.blue[50]!, Colors.blue[100]!]
                        : [Colors.orange[50]!, Colors.orange[100]!],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isCustomTime ? Colors.blue[200]! : Colors.orange[200]!,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            _isCustomTime
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isCustomTime ? Icons.access_time : Icons.wb_sunny,
                        color:
                            _isCustomTime
                                ? Colors.blue[700]
                                : Colors.orange[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedTimingOption,
                          items:
                              _timingOptions.map((timing) {
                                return DropdownMenuItem(
                                  value: timing,
                                  child: Text(
                                    timing,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[800],
                                    ),
                                  ),
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
                const SizedBox(height: 16),
                InkWell(
                  onTap: _isCustomTime ? _showCustomTimePicker : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('HH:mm').format(_reminderDateTime),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
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
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[600],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.blue[200]!),
                          ),
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
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[600],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.blue[200]!),
                          ),
                        ),
                        child: const Text('+15 min'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  'Enable Notification',
                  'Receive alerts for this activity',
                  Icons.notifications,
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
                  'Reminder will repeat every day',
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

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.editingReminder != null
                    ? 'Update Reminder'
                    : 'Save Reminder',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
