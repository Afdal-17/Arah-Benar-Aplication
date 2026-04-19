import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../model/prayer_time_model.dart';
import '../repository/prayer_time_repository.dart';

class ShalatViewModel extends ChangeNotifier {
  final PrayerTimeRepository _repo;

  ShalatViewModel(this._repo);

  bool _isLoading = false;
  String? _error;
  PrayerTime? _todayPrayer;
  List<PrayerTime> _monthlyPrayers = [];
  double? _latitude;
  double? _longitude;

  bool get isLoading => _isLoading;
  String? get error => _error;
  PrayerTime? get todayPrayer => _todayPrayer;
  List<PrayerTime> get monthlyPrayers => _monthlyPrayers;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  /// Fetch today's prayer based on device location
  Future<void> fetchTodayPrayer() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _getPosition();
      _latitude = position.latitude;
      _longitude = position.longitude;

      _todayPrayer = await _repo.fetchToday(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetch prayer: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch monthly prayer calendar
  Future<void> fetchMonthlyPrayer({int? year, int? month}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final position = await _getPosition();
      _latitude = position.latitude;
      _longitude = position.longitude;

      final now = DateTime.now();
      _monthlyPrayers = await _repo.fetchMonthly(
        latitude: position.latitude,
        longitude: position.longitude,
        year: year ?? now.year,
        month: month ?? now.month,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetch monthly prayer: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS tidak aktif');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
