import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/campus_model.dart' as cm;
import '../../data/services/weather_service.dart';

/// Lazily fetch weather for a campus by its display name.
/// Returns null on failure to avoid blocking UI.
final campusWeatherProvider = FutureProvider.family<cm.WeatherData?, String>((ref, campusName) async {
  try {
    final model = await WeatherService.getCampusWeatherByName(campusName);
    final legacy = model.toWeatherData();
    return cm.WeatherData(
      temperature: legacy.temperature,
      condition: legacy.condition,
      icon: legacy.icon,
      humidity: legacy.humidity,
      windSpeed: legacy.windSpeed,
    );
  } catch (_) {
    return null;
  }
});