import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/prayer_time_model.dart';

class PrayerTimeRepository {
  static const _baseUrl = 'https://api.aladhan.com/v1';

  /// Fetch today's prayer times using coordinates
  /// method=20 = Kementerian Agama RI
  Future<PrayerTime> fetchToday({
    required double latitude,
    required double longitude,
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    final url = Uri.parse(
      '$_baseUrl/timings/$dateStr?latitude=$latitude&longitude=$longitude&method=20',
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil jadwal shalat');
    }

    final json = jsonDecode(res.body);
    return PrayerTime.fromAladhanJson(json['data']);
  }

  /// Fetch monthly prayer calendar
  Future<List<PrayerTime>> fetchMonthly({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=20',
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil kalender shalat');
    }

    final json = jsonDecode(res.body);
    final List dataList = json['data'] ?? [];

    return dataList.map((e) => PrayerTime.fromAladhanJson(e)).toList();
  }
}
