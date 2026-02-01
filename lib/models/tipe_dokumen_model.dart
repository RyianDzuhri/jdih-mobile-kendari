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
      // Aman: Terima int atau String angka, ubah jadi int
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      
      // Aman: Pastikan selalu String, kalau null jadi teks default
      nama: json['nama']?.toString() ?? 'Tanpa Nama',
      singkatan: json['singkatan']?.toString() ?? '-',
    );
  }
}