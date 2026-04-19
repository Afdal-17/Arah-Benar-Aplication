import 'dart:convert';
import 'package:http/http.dart' as http;

class HaditsRepository {
  Future<List<dynamic>> fetchHadits() async {
    final response = await http.get(
      Uri.parse('https://api.hadith.gading.dev/books/muslim?range=1-20'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['hadiths'];
    } else {
      throw Exception('Gagal memuat hadits');
    }
  }
}