import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/quran_ayat_model.dart';
import '../model/quran_surah_model.dart';

class QuranRepository {
  static const _baseUrl = 'https://equran.id/api/v2';

  /// Fetch list of all 114 surahs
  Future<List<QuranSurah>> fetchAllSurah() async {
    final response = await http.get(Uri.parse('$_baseUrl/surat'));

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat daftar surah');
    }

    final data = json.decode(response.body);
    final List surahList = data['data'] ?? [];
    return surahList.map((e) => QuranSurah.fromJson(e)).toList();
  }

  /// Fetch ayat for a specific surah
  Future<List<QuranAyat>> fetchSurat(int nomorSurat) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/surat/$nomorSurat'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat surah $nomorSurat');
    }

    final data = json.decode(response.body);
    final List ayat = data['data']['ayat'] ?? [];
    return ayat.map((e) => QuranAyat.fromJson(e)).toList();
  }

  /// Fetch ayat for a specific juz (1-30)
  Future<List<QuranAyat>> fetchJuz(int nomorJuz) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/juz/$nomorJuz'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat Juz $nomorJuz');
    }

    final data = json.decode(response.body);
    final List ayat = data['data']['ayat'] ?? [];
    return ayat.map((e) => QuranAyat.fromJson(e)).toList();
  }
}