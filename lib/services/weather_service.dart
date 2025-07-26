import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '6b39089f3379cc8538f2b6789a431aa8';

  static Future<Map<String, dynamic>> fetchWeatherByCoords(
      double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'temp': data['main']['temp'],
        'desc': data['weather'][0]['description'],
        'icon': data['weather'][0]['icon'],
        'city': data['name'],
        'country': data['sys']['country'],
        'humidity': data['main']['humidity'],
        'wind': data['wind']['speed'],
        'sunrise': data['sys']['sunrise'],
        'sunset': data['sys']['sunset'],
        'coord': data['coord'],
      };
    } else {
      throw Exception('Failed to load weather');
    }
  }

  static Future<Map<String, dynamic>?> fetchWeatherByCity(String city) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'temp': data['main']['temp'],
        'desc': data['weather'][0]['description'],
        'icon': data['weather'][0]['icon'],
        'city': data['name'],
        'country': data['sys']['country'],
        'humidity': data['main']['humidity'],
        'wind': data['wind']['speed'],
        'sunrise': data['sys']['sunrise'],
        'sunset': data['sys']['sunset'],
        'coord': data['coord'],
      };
    } else {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> citySuggestions(
      String query) async {
    final url =
        'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=en&format=json';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null) {
        return List<Map<String, dynamic>>.from(data['results']);
      }
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetch5DayForecast(
      double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, dynamic>> forecast = [];
      for (var item in data['list']) {
        if (item['dt_txt'].toString().contains('12:00:00')) {
          forecast.add({
            'date': item['dt_txt'].toString().substring(0, 10),
            'temp': item['main']['temp'],
            'desc': item['weather'][0]['description'],
            'icon': item['weather'][0]['icon'],
          });
        }
      }
      return forecast;
    } else {
      throw Exception('Failed to load forecast');
    }
  }

  static String iconUrl(String iconCode) =>
      "https://openweathermap.org/img/wn/$iconCode@2x.png";
}
