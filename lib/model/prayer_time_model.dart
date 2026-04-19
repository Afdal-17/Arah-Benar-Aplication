class PrayerTime {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String imsak;
  final String dateReadable;
  final String hijriDate;

  PrayerTime({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.dateReadable,
    required this.hijriDate,
  });

  factory PrayerTime.fromAladhanJson(Map<String, dynamic> json) {
    final timings = json['timings'] as Map<String, dynamic>;
    final date = json['date'] as Map<String, dynamic>;
    final hijri = date['hijri'] as Map<String, dynamic>;

    String clean(String s) => s.replaceAll(RegExp(r'\s*\(.*\)'), '');

    final hijriDay = hijri['day'] ?? '';
    final hijriMonth = (hijri['month'] as Map?)?['en'] ?? '';
    final hijriYear = hijri['year'] ?? '';

    return PrayerTime(
      fajr: clean(timings['Fajr'] ?? ''),
      sunrise: clean(timings['Sunrise'] ?? ''),
      dhuhr: clean(timings['Dhuhr'] ?? ''),
      asr: clean(timings['Asr'] ?? ''),
      maghrib: clean(timings['Maghrib'] ?? ''),
      isha: clean(timings['Isha'] ?? ''),
      imsak: clean(timings['Imsak'] ?? ''),
      dateReadable: date['readable'] ?? '',
      hijriDate: '$hijriDay $hijriMonth $hijriYear H',
    );
  }

  /// Returns list of prayer name-time pairs
  List<MapEntry<String, String>> get prayerList => [
        MapEntry('Imsak', imsak),
        MapEntry('Subuh', fajr),
        MapEntry('Terbit', sunrise),
        MapEntry('Dzuhur', dhuhr),
        MapEntry('Ashar', asr),
        MapEntry('Maghrib', maghrib),
        MapEntry('Isya', isha),
      ];

  /// Returns only the 5 wajib prayer times
  List<MapEntry<String, String>> get wajibPrayers => [
        MapEntry('Subuh', fajr),
        MapEntry('Dzuhur', dhuhr),
        MapEntry('Ashar', asr),
        MapEntry('Maghrib', maghrib),
        MapEntry('Isya', isha),
      ];
}
