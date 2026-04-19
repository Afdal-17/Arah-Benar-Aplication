class QuranAyat {
  final int nomorAyat;
  final String arab;
  final String latin;
  final String arti;
  final Map<String, String> audio;

  QuranAyat({
    required this.nomorAyat,
    required this.arab,
    required this.latin,
    required this.arti,
    required this.audio,
  });

  factory QuranAyat.fromJson(Map<String, dynamic> json) {
    final audioMap = <String, String>{};
    if (json['audio'] != null && json['audio'] is Map) {
      (json['audio'] as Map).forEach((key, value) {
        audioMap[key.toString()] = value.toString();
      });
    }

    return QuranAyat(
      nomorAyat: json['nomorAyat'] ?? 0,
      arab: json['teksArab'] ?? '',
      latin: json['teksLatin'] ?? '',
      arti: json['teksIndonesia'] ?? '',
      audio: audioMap,
    );
  }

  /// Get the first available audio URL
  String? get audioUrl {
    if (audio.isNotEmpty) {
      return audio.values.first;
    }
    return null;
  }
}