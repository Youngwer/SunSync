class WeatherData {
  final String locationName;
  final double temperature;
  final String condition;
  final double highTemp;
  final double lowTemp;
  final String iconCode;

  WeatherData({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.highTemp,
    required this.lowTemp,
    required this.iconCode,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    // OpenWeatherMap API 响应解析示例
    final main = json['main'];
    final weather = json['weather'][0];

    return WeatherData(
      locationName: json['name'],
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'],
      highTemp: (main['temp_max'] as num).toDouble(),
      lowTemp: (main['temp_min'] as num).toDouble(),
      iconCode: weather['icon'],
    );
  }
}
