import 'package:equatable/equatable.dart';

/// Weather data returned from the MET Norway API
class WeatherModel extends Equatable {
  final WeatherLocation location;
  final WeatherCurrent current;
  final DateTime updated;
  final DateTime expires;

  const WeatherModel({
    required this.location,
    required this.current,
    required this.updated,
    required this.expires,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, {
    required double latitude,
    required double longitude,
    required double altitude,
    String? locationName,
    required Map<String, String> headers,
  }) {
    final data = json['properties'];
    final currentTimeseries = data['timeseries'][0];
    final instant = currentTimeseries['data']['instant']['details'];

    // Get the weather symbol from the next_1_hours summary if available
    String symbolCode = 'unknown';
    if (currentTimeseries['data']['next_1_hours']?['summary']?['symbol_code'] != null) {
      symbolCode = currentTimeseries['data']['next_1_hours']['summary']['symbol_code'];
    } else if (currentTimeseries['data']['next_6_hours']?['summary']?['symbol_code'] != null) {
      symbolCode = currentTimeseries['data']['next_6_hours']['summary']['symbol_code'];
    } else if (currentTimeseries['data']['next_12_hours']?['summary']?['symbol_code'] != null) {
      symbolCode = currentTimeseries['data']['next_12_hours']['summary']['symbol_code'];
    }

    // Get precipitation amount from next_1_hours if available
    final precipitation = currentTimeseries['data']['next_1_hours']?['details']?['precipitation_amount'];

    // Parse headers for caching information
    final lastModified = headers['last-modified'] != null 
        ? DateTime.tryParse(headers['last-modified']!) ?? DateTime.now()
        : DateTime.now();
    
    final expires = headers['expires'] != null 
        ? DateTime.tryParse(headers['expires']!) ?? DateTime.now().add(const Duration(hours: 1))
        : DateTime.now().add(const Duration(hours: 1));

    return WeatherModel(
      location: WeatherLocation(
        latitude: double.parse(latitude.toStringAsFixed(4)),
        longitude: double.parse(longitude.toStringAsFixed(4)),
        altitude: altitude.round().toDouble(),
        name: locationName ?? 'Unknown',
      ),
      current: WeatherCurrent(
        temperature: instant['air_temperature']?.toDouble() ?? 0.0,
        symbolCode: symbolCode,
        precipitation: precipitation?.toDouble(),
        windSpeed: instant['wind_speed']?.toDouble(),
        windDirection: instant['wind_from_direction']?.toDouble(),
        humidity: instant['relative_humidity']?.toDouble(),
        pressure: instant['air_pressure_at_sea_level']?.toDouble(),
        cloudCover: instant['cloud_area_fraction']?.toDouble(),
      ),
      updated: lastModified,
      expires: expires,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      'updated': updated.toIso8601String(),
      'expires': expires.toIso8601String(),
    };
  }

  /// Convert to the existing WeatherData format for compatibility
  WeatherData toWeatherData() {
    return WeatherData(
      temperature: current.temperature,
      condition: getWeatherDescription(current.symbolCode),
      icon: getWeatherIcon(current.symbolCode),
      humidity: (current.humidity ?? 0).round(),
      windSpeed: current.windSpeed ?? 0,
    );
  }

  @override
  List<Object?> get props => [location, current, updated, expires];
}

class WeatherLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double altitude;
  final String name;

  const WeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude, altitude, name];
}

class WeatherCurrent extends Equatable {
  final double temperature;
  final String symbolCode;
  final double? precipitation;
  final double? windSpeed;
  final double? windDirection;
  final double? humidity;
  final double? pressure;
  final double? cloudCover;

  const WeatherCurrent({
    required this.temperature,
    required this.symbolCode,
    this.precipitation,
    this.windSpeed,
    this.windDirection,
    this.humidity,
    this.pressure,
    this.cloudCover,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'symbolCode': symbolCode,
      'precipitation': precipitation,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'humidity': humidity,
      'pressure': pressure,
      'cloudCover': cloudCover,
    };
  }

  @override
  List<Object?> get props => [
    temperature,
    symbolCode,
    precipitation,
    windSpeed,
    windDirection,
    humidity,
    pressure,
    cloudCover,
  ];
}

/// Campus locations in Norway
enum Campus {
  oslo('Oslo'),
  bergen('Bergen'),
  stavanger('Stavanger'),
  trondheim('Trondheim');

  const Campus(this.displayName);
  final String displayName;
}

/// Coordinates for each campus
class CampusCoordinates {
  static const Map<Campus, WeatherLocation> coordinates = {
    Campus.oslo: WeatherLocation(
      latitude: 59.9139,
      longitude: 10.7522,
      altitude: 23,
      name: 'Oslo',
    ),
    Campus.bergen: WeatherLocation(
      latitude: 60.3913,
      longitude: 5.3221,
      altitude: 12,
      name: 'Bergen',
    ),
    Campus.stavanger: WeatherLocation(
      latitude: 58.9700,
      longitude: 5.7331,
      altitude: 9,
      name: 'Stavanger',
    ),
    Campus.trondheim: WeatherLocation(
      latitude: 63.4305,
      longitude: 10.3951,
      altitude: 56,
      name: 'Trondheim',
    ),
  };

  static WeatherLocation? getCoordinates(Campus campus) {
    return coordinates[campus];
  }

  static WeatherLocation? getCoordinatesByName(String campusName) {
    for (var campus in Campus.values) {
      if (campus.displayName.toLowerCase() == campusName.toLowerCase()) {
        return coordinates[campus];
      }
    }
    return null;
  }
}

/// Helper function to get a description of the weather based on the symbol code
String getWeatherDescription(String symbolCode) {
  const descriptions = <String, String>{
    'clearsky_day': 'Clear sky',
    'clearsky_night': 'Clear sky',
    'clearsky_polartwilight': 'Clear sky',
    'fair_day': 'Fair',
    'fair_night': 'Fair',
    'fair_polartwilight': 'Fair',
    'partlycloudy_day': 'Partly cloudy',
    'partlycloudy_night': 'Partly cloudy',
    'partlycloudy_polartwilight': 'Partly cloudy',
    'cloudy': 'Cloudy',
    'rainshowers_day': 'Rain showers',
    'rainshowers_night': 'Rain showers',
    'rainshowers_polartwilight': 'Rain showers',
    'rainshowersandthunder_day': 'Rain showers and thunder',
    'rainshowersandthunder_night': 'Rain showers and thunder',
    'rainshowersandthunder_polartwilight': 'Rain showers and thunder',
    'sleetshowers_day': 'Sleet showers',
    'sleetshowers_night': 'Sleet showers',
    'sleetshowers_polartwilight': 'Sleet showers',
    'snowshowers_day': 'Snow showers',
    'snowshowers_night': 'Snow showers',
    'snowshowers_polartwilight': 'Snow showers',
    'rain': 'Rain',
    'heavyrain': 'Heavy rain',
    'heavyrainandthunder': 'Heavy rain and thunder',
    'sleet': 'Sleet',
    'snow': 'Snow',
    'snowandthunder': 'Snow and thunder',
    'fog': 'Fog',
    'sleetshowersandthunder_day': 'Sleet showers and thunder',
    'sleetshowersandthunder_night': 'Sleet showers and thunder',
    'sleetshowersandthunder_polartwilight': 'Sleet showers and thunder',
    'snowshowersandthunder_day': 'Snow showers and thunder',
    'snowshowersandthunder_night': 'Snow showers and thunder',
    'snowshowersandthunder_polartwilight': 'Snow showers and thunder',
    'rainandthunder': 'Rain and thunder',
    'sleetandthunder': 'Sleet and thunder',
    'lightrainshowersandthunder_day': 'Light rain showers and thunder',
    'lightrainshowersandthunder_night': 'Light rain showers and thunder',
    'lightrainshowersandthunder_polartwilight': 'Light rain showers and thunder',
    'heavyrainshowersandthunder_day': 'Heavy rain showers and thunder',
    'heavyrainshowersandthunder_night': 'Heavy rain showers and thunder',
    'heavyrainshowersandthunder_polartwilight': 'Heavy rain showers and thunder',
    'lightssleetshowersandthunder_day': 'Light sleet showers and thunder',
    'lightssleetshowersandthunder_night': 'Light sleet showers and thunder',
    'lightssleetshowersandthunder_polartwilight': 'Light sleet showers and thunder',
    'heavysleetshowersandthunder_day': 'Heavy sleet showers and thunder',
    'heavysleetshowersandthunder_night': 'Heavy sleet showers and thunder',
    'heavysleetshowersandthunder_polartwilight': 'Heavy sleet showers and thunder',
    'lightssnowshowersandthunder_day': 'Light snow showers and thunder',
    'lightssnowshowersandthunder_night': 'Light snow showers and thunder',
    'lightssnowshowersandthunder_polartwilight': 'Light snow showers and thunder',
    'heavysnowshowersandthunder_day': 'Heavy snow showers and thunder',
    'heavysnowshowersandthunder_night': 'Heavy snow showers and thunder',
    'heavysnowshowersandthunder_polartwilight': 'Heavy snow showers and thunder',
    'lightrainandthunder': 'Light rain and thunder',
    'lightsleetandthunder': 'Light sleet and thunder',
    'heavysleetandthunder': 'Heavy sleet and thunder',
    'lightsnowandthunder': 'Light snow and thunder',
    'heavysnowandthunder': 'Heavy snow and thunder',
    'lightrainshowers_day': 'Light rain showers',
    'lightrainshowers_night': 'Light rain showers',
    'lightrainshowers_polartwilight': 'Light rain showers',
    'heavyrainshowers_day': 'Heavy rain showers',
    'heavyrainshowers_night': 'Heavy rain showers',
    'heavyrainshowers_polartwilight': 'Heavy rain showers',
    'lightsleetshowers_day': 'Light sleet showers',
    'lightsleetshowers_night': 'Light sleet showers',
    'lightsleetshowers_polartwilight': 'Light sleet showers',
    'heavysleetshowers_day': 'Heavy sleet showers',
    'heavysleetshowers_night': 'Heavy sleet showers',
    'heavysleetshowers_polartwilight': 'Heavy sleet showers',
    'lightsnowshowers_day': 'Light snow showers',
    'lightsnowshowers_night': 'Light snow showers',
    'lightsnowshowers_polartwilight': 'Light snow showers',
    'heavysnowshowers_day': 'Heavy snow showers',
    'heavysnowshowers_night': 'Heavy snow showers',
    'heavysnowshowers_polartwilight': 'Heavy snow showers',
    'lightrain': 'Light rain',
    'lightsleet': 'Light sleet',
    'heavysleet': 'Heavy sleet',
    'lightsnow': 'Light snow',
    'heavysnow': 'Heavy snow',
  };

  return descriptions[symbolCode] ?? 'Unknown weather condition';
}

/// Get an emoji icon for a weather symbol code
String getWeatherIcon(String symbolCode) {
  // Simple mapping to emojis - can be expanded
  if (symbolCode.contains('clearsky')) return '☀️';
  if (symbolCode.contains('fair')) return '🌤️';
  if (symbolCode.contains('partlycloudy')) return '⛅';
  if (symbolCode.contains('cloudy')) return '☁️';
  if (symbolCode.contains('rain')) return '🌧️';
  if (symbolCode.contains('snow')) return '❄️';
  if (symbolCode.contains('sleet')) return '🌨️';
  if (symbolCode.contains('thunder')) return '⛈️';
  if (symbolCode.contains('fog')) return '🌫️';
  
  return '🌤️'; // Default icon
}

/// Get the URL for a weather icon from MET Norway
String getWeatherIconUrl(String symbolCode, {String size = 'svg'}) {
  return 'https://api.met.no/images/weathericons/$symbolCode.$size';
}

/// Keep the existing WeatherData class for backward compatibility
class WeatherData extends Equatable {
  final double temperature;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
      temperature: (map['temperature'] ?? 0).toDouble(),
      condition: map['condition'] ?? '',
      icon: map['icon'] ?? '',
      humidity: map['humidity'] ?? 0,
      windSpeed: (map['wind_speed'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'condition': condition,
      'icon': icon,
      'humidity': humidity,
      'wind_speed': windSpeed,
    };
  }

  @override
  List<Object?> get props => [
    temperature,
    condition,
    icon,
    humidity,
    windSpeed,
  ];
}