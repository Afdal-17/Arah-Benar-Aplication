import 'dart:math';

const double _kaabaLat = 21.4225;
const double _kaabaLon = 39.8262;

/// Calculate Qibla direction (bearing) from a given position
double calculateQiblaDirection(double lat, double lon) {
  final latRad = _degToRad(lat);
  final lonRad = _degToRad(lon);
  final kaabaLatRad = _degToRad(_kaabaLat);
  final kaabaLonRad = _degToRad(_kaabaLon);

  final dLon = kaabaLonRad - lonRad;

  final y = sin(dLon) * cos(kaabaLatRad);
  final x = cos(latRad) * sin(kaabaLatRad) -
      sin(latRad) * cos(kaabaLatRad) * cos(dLon);

  final bearing = atan2(y, x);
  return (_radToDeg(bearing) + 360) % 360;
}

/// Calculate distance to Ka'bah using Haversine formula (in km)
double calculateDistanceToKaaba(double lat, double lon) {
  const R = 6371.0; // Earth radius in km

  final dLat = _degToRad(_kaabaLat - lat);
  final dLon = _degToRad(_kaabaLon - lon);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat)) * cos(_degToRad(_kaabaLat)) *
      sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _degToRad(double deg) => deg * pi / 180;
double _radToDeg(double rad) => rad * 180 / pi;