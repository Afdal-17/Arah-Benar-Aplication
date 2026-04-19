import 'package:flutter/material.dart';
import '../model/quran_ayat_model.dart';
import '../model/quran_surah_model.dart';
import '../repository/quran_repository.dart';

class QuranViewModel extends ChangeNotifier {
  final QuranRepository repository;

  QuranViewModel(this.repository);

  bool isLoading = false;
  String? error;

  List<QuranSurah> surahList = [];
  List<QuranAyat> ayat = [];

  /// Fetch all 114 surahs
  Future<void> fetchAllSurah() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      surahList = await repository.fetchAllSurah();
    } catch (e) {
      error = e.toString();
      debugPrint('Error fetch surah list: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  /// Fetch ayat for a specific surah
  Future<void> fetchSurat(int nomorSurat) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      ayat = await repository.fetchSurat(nomorSurat);
    } catch (e) {
      error = e.toString();
      debugPrint('Error fetch surah $nomorSurat: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  /// Fetch ayat for a specific juz
  Future<void> fetchJuz(int nomorJuz) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      ayat = await repository.fetchJuz(nomorJuz);
    } catch (e) {
      error = e.toString();
      debugPrint('Error fetch juz $nomorJuz: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}