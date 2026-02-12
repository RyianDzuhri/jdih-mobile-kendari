class TipeDokumen {
  final int id;
  final String nama;
  final String singkatan;

  TipeDokumen({
    required this.id,
    required this.nama,
    required this.singkatan,
  });

  factory TipeDokumen.fromJson(Map<String, dynamic> json) {
    return TipeDokumen(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      
      nama: json['nama']?.toString() ?? 'Tanpa Nama',
      singkatan: json['singkatan']?.toString() ?? '-',
    );
  }
}