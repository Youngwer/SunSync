// widgets/activity_suggestion_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/weather_provider.dart';
import '../screens/new_reminder_screen.dart';

class ActivitySuggestionWidget extends StatelessWidget {
  const ActivitySuggestionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final condition = weatherProvider.condition.toLowerCase();
        final recommendation = _getActivityRecommendation(condition);

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activity Suggestion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          recommendation['icon'] as IconData,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              recommendation['description'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 快速设置提醒按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          () =>
                              _navigateToQuickReminder(context, recommendation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_alarm, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Set ${recommendation['activity']} Reminder',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getActivityRecommendation(String condition) {
    if (condition.contains('rain') ||
        condition.contains('snow') ||
        condition.contains('thunderstorm') ||
        condition.contains('drizzle') ||
        condition.contains('hail')) {
      return {
        'icon': Icons.self_improvement,
        'title': 'Indoor Activities',
        'description':
            'Perfect time for yoga, meditation, or indoor exercises. Stay cozy and focus on your wellbeing.',
        'activity': 'Meditation',
      };
    } else if (condition.contains('clear') || condition.contains('sunny')) {
      return {
        'icon': Icons.directions_run,
        'title': 'Outdoor Activities',
        'description':
            'Great weather for running, cycling, or walking in the park. Enjoy the sunshine!',
        'activity': 'Running',
      };
    } else if (condition.contains('cloud')) {
      return {
        'icon': Icons.directions_walk,
        'title': 'Light Outdoor Activities',
        'description':
            'Nice weather for a walk or light jogging. The cloud cover provides comfortable conditions.',
        'activity': 'Walking',
      };
    } else {
      return {
        'icon': Icons.fitness_center,
        'title': 'Flexible Activities',
        'description':
            'Choose activities based on your preference. Both indoor and outdoor options are suitable.',
        'activity': 'Exercise',
      };
    }
  }

  void _navigateToQuickReminder(
    BuildContext context,
    Map<String, dynamic> recommendation,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('Set Reminder'),
                centerTitle: true,
              ),
              extendBodyBehindAppBar: true,
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade900,
                      Colors.blue.shade800,
                      Colors.blue.shade700,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: NewReminderScreen(
                    preSelectedActivity: recommendation['activity'] as String,
                    onSave: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Reminder created successfully'),
                          backgroundColor: Colors.green.withOpacity(0.8),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
