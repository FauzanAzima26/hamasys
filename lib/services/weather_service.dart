import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WeatherService {
  final String apiKey = '8bc75c08ca4e4415bea83841251308';

  Future<Map<String, dynamic>?> fetchWeather(double lat, double lon) async {
    final String url =
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon&lang=id';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Error get weather: $e');
    }
    return null;
  }
}
