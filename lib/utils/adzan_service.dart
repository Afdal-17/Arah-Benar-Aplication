import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../model/prayer_time_model.dart';

class AdzanService {
  static final AdzanService _instance = AdzanService._internal();
  factory AdzanService() => _instance;
  AdzanService._internal();

  final AudioPlayer _player = AudioPlayer();
  Timer? _timer;
  PrayerTime? _todayPrayer;
  final Set<String> _playedTimes = {};
  VoidCallback? onAdzanTriggered;

  /// Adzan audio URLs
  static const Map<String, String> adzanUrls = {
    'Makkah': 'https://www.islamcan.com/audio/adhan/azan1.mp3',
    'Madinah': 'https://www.islamcan.com/audio/adhan/azan4.mp3',
    'Mishary': 'https://www.islamcan.com/audio/adhan/azan3.mp3',
  };

  String _selectedMuadzin = 'Makkah';

  String get selectedMuadzin => _selectedMuadzin;

  set selectedMuadzin(String value) {
    if (adzanUrls.containsKey(value)) {
      _selectedMuadzin = value;
    }
  }

  bool get isPlaying => _player.playing;

  /// Set today's prayer times and start monitoring
  void setPrayerTimes(PrayerTime prayer) {
    _todayPrayer = prayer;
    _playedTimes.clear();
    _startMonitoring();
  }

  /// Start periodic timer to check prayer times
  void _startMonitoring() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkPrayerTime();
    });
    // Also check immediately
    _checkPrayerTime();
  }

  void _checkPrayerTime() {
    if (_todayPrayer == null) return;

    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (final entry in _todayPrayer!.wajibPrayers) {
      final prayerName = entry.key;
      final prayerTime = entry.value;

      if (prayerTime == currentTime && !_playedTimes.contains(prayerName)) {
        _playedTimes.add(prayerName);
        playAdzan();
        onAdzanTriggered?.call();
        debugPrint('🕌 Adzan $prayerName diputar pada $currentTime');
        break;
      }
    }
  }

  /// Play adzan audio
  Future<void> playAdzan({String? muadzin}) async {
    try {
      final url = adzanUrls[muadzin ?? _selectedMuadzin] ?? adzanUrls['Makkah']!;
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing adzan: $e');
    }
  }

  /// Stop adzan
  Future<void> stop() async {
    await _player.stop();
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _player.dispose();
  }

  /// Get next prayer info
  MapEntry<String, String>? getNextPrayer() {
    if (_todayPrayer == null) return null;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    for (final entry in _todayPrayer!.wajibPrayers) {
      final parts = entry.value.split(':');
      if (parts.length == 2) {
        final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        if (prayerMinutes > currentMinutes) {
          return entry;
        }
      }
    }
    return null; // All prayers have passed
  }

  /// Get countdown string to next prayer
  String getCountdown() {
    final next = getNextPrayer();
    if (next == null) return 'Semua shalat hari ini selesai';

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final parts = next.value.split(':');
    final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final diff = prayerMinutes - currentMinutes;

    final hours = diff ~/ 60;
    final minutes = diff % 60;

    if (hours > 0) {
      return '${next.key} dalam ${hours}j ${minutes}m';
    }
    return '${next.key} dalam ${minutes} menit';
  }
}
