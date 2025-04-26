import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/light_provider.dart';

class LightScreen extends StatelessWidget {
  const LightScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Light Conditions'),
        elevation: 0,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 当前光照情况
                _buildCurrentLightSection(context),

                const SizedBox(height: 20),

                // 光照历史图表（占位）
                _buildLightHistorySection(),

                const SizedBox(height: 20),

                // 光照建议
                _buildLightAdviceSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 当前光照部分
  Widget _buildCurrentLightSection(BuildContext context) {
    return Consumer<LightProvider>(
      builder: (context, lightProvider, child) {
        final isLoading = lightProvider.isLoading;
        final error = lightProvider.error;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Indoor Light Conditions',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (lightProvider.time.isNotEmpty)
                    Text(
                      lightProvider.time,
                      style: TextStyle(color: Colors.blue[800], fontSize: 14),
                    ),
                ],
              ),
              const SizedBox(height: 15),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (error != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Could not connect to light sensor',
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    // 当前光照强度
                    Row(
                      children: [
                        Icon(
                          Icons.wb_sunny,
                          color: Colors.amber[700],
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Current: ${lightProvider.currentLight}%',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 光照强度指示条
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value:
                            int.tryParse(
                              lightProvider.currentLight,
                            )?.toDouble() ??
                            0 / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getLightColor(
                            int.tryParse(lightProvider.currentLight) ?? 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 今日最高光照
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.green[700],
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Today\'s peak: ${lightProvider.highestLight}%',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 建议
                    if (lightProvider.suggestion.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.amber[800],
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                lightProvider.suggestion,
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // 光照历史图表（占位）
  Widget _buildLightHistorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.indigo[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Light History',
            style: TextStyle(
              color: Colors.indigo,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            child: const Center(
              child: Text(
                'Light history chart will be displayed here',
                style: TextStyle(color: Colors.indigo),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 光照建议部分
  Widget _buildLightAdviceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Light Adjustment Tips',
            style: TextStyle(
              color: Colors.teal,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildTipItem(
            Icons.wb_sunny_outlined,
            'Optimal Lighting',
            'Maintain 30-70% indoor light for comfortable reading and working',
          ),
          const SizedBox(height: 10),
          _buildTipItem(
            Icons.remove_red_eye,
            'Eye Protection',
            'Avoid prolonged exposure to very bright or dim light',
          ),
          const SizedBox(height: 10),
          _buildTipItem(
            Icons.lightbulb_outline,
            'Energy Saving',
            'Use natural light when possible to save energy',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.teal,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(color: Colors.teal[700], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 根据光照强度获取颜色
  Color _getLightColor(int lightLevel) {
    if (lightLevel < 30) {
      return Colors.blue[300]!; // 弱光
    } else if (lightLevel < 70) {
      return Colors.amber[400]!; // 中等光照
    } else {
      return Colors.orange[600]!; // 强光
    }
  }
}
