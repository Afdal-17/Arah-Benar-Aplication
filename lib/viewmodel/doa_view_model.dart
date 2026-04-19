import 'package:flutter/material.dart';
import '../model/doa_model.dart';
import '../repository/doa_repository.dart';

class DoaViewModel extends ChangeNotifier {
  final DoaRepository repository;

  DoaViewModel(this.repository);

  bool isLoading = false;
  String? error;
  List<Doa> doaList = [];

  Future<void> fetchDoa() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      doaList = await repository.fetchDoa();
      debugPrint('Jumlah doa: ${doaList.length}');
    } catch (e) {
      error = e.toString();
      debugPrint('Error fetch doa: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}