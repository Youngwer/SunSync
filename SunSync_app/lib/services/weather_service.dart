// services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // OpenMeteo API使用免费地理编码服务获取城市坐标
  final String geoBaseUrl = 'https://geocoding-api.open-meteo.com/v1';
  final String weatherBaseUrl = 'https://api.open-meteo.com/v1';

  // 通过城市名称获取天气数据
  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    try {
      // 首先获取城市的经纬度
      final geoResponse = await http.get(
        Uri.parse(
          '$geoBaseUrl/search?name=$city&count=1&language=en&format=json',
        ),
      );

      if (geoResponse.statusCode == 200) {
        final geoData = jsonDecode(geoResponse.body);
        if (geoData['results'] != null && geoData['results'].isNotEmpty) {
          final location = geoData['results'][0];
          final lat = location['latitude'];
          final lon = location['longitude'];
          final cityName = location['name'];

          // 使用经纬度获取天气数据，添加日出日落时间
          final weatherResponse = await http.get(
            Uri.parse(
              '$weatherBaseUrl/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto',
            ),
          );

          if (weatherResponse.statusCode == 200) {
            final weatherData = jsonDecode(weatherResponse.body);

            // 转换OpenMeteo数据格式为我们应用的格式
            return {
              'name': cityName,
              'main': {
                'temp': weatherData['current']['temperature_2m'],
                'temp_max': weatherData['daily']['temperature_2m_max'][0],
                'temp_min': weatherData['daily']['temperature_2m_min'][0],
              },
              'weather': [
                {
                  'main': _getWeatherCondition(
                    weatherData['current']['weather_code'],
                  ),
                  'icon': 'default',
                },
              ],
              'sunrise': weatherData['daily']['sunrise'][0],
              'sunset': weatherData['daily']['sunset'][0],
            };
          }
        }
      }
      throw Exception('Failed to load weather data');
    } catch (e) {
      throw Exception('Weather service error: $e');
    }
  }

  // 通过经纬度获取天气数据
  Future<Map<String, dynamic>> getWeatherByLocation(
    double lat,
    double lon,
  ) async {
    try {
      final weatherResponse = await http.get(
        Uri.parse(
          '$weatherBaseUrl/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset&timezone=auto',
        ),
      );

      if (weatherResponse.statusCode == 200) {
        final weatherData = jsonDecode(weatherResponse.body);

        // 反向地理编码获取城市名
        final geoResponse = await http.get(
          Uri.parse(
            '$geoBaseUrl/reverse?latitude=$lat&longitude=$lon&language=en&format=json',
          ),
        );

        String cityName = 'Unknown Location';
        if (geoResponse.statusCode == 200) {
          final geoData = jsonDecode(geoResponse.body);
          if (geoData['name'] != null) {
            cityName = geoData['name'];
          }
        }

        return {
          'name': cityName,
          'main': {
            'temp': weatherData['current']['temperature_2m'],
            'temp_max': weatherData['daily']['temperature_2m_max'][0],
            'temp_min': weatherData['daily']['temperature_2m_min'][0],
          },
          'weather': [
            {
              'main': _getWeatherCondition(
                weatherData['current']['weather_code'],
              ),
              'icon': 'default',
            },
          ],
          'sunrise': weatherData['daily']['sunrise'][0],
          'sunset': weatherData['daily']['sunset'][0],
        };
      }
      throw Exception('Failed to load weather data');
    } catch (e) {
      throw Exception('Weather service error: $e');
    }
  }

  // OpenMeteo使用WMO天气代码，需要转换为描述性文本
  String _getWeatherCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Sleet';
      case 80:
      case 81:
      case 82:
        return 'Showers';
      case 85:
      case 86:
        return 'Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Unknown';
    }
  }
}
