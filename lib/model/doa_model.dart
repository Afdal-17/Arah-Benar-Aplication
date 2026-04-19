class Doa {
  final int id;
  final String judul;
  final String arab;
  final String latin;
  final String arti;

  Doa({
    required this.id,
    required this.judul,
    required this.arab,
    required this.latin,
    required this.arti,
  });

  factory Doa.fromJson(Map<String, dynamic> json) {
    return Doa(
      id: int.tryParse(json['id'].toString()) ?? 0,
      judul: (json['doa'] ?? '').toString(),
      arab: (json['ayat'] ?? '').toString(),
      latin: (json['latin'] ?? '').toString(),
      arti: (json['artinya'] ?? '').toString(),
    );
  }
}