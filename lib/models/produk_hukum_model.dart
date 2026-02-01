class ProdukHukum {
  final int id;
  final String judul;
  final String nomorPeraturan; // Wajib ada
  final String tahunTerbit;
  final String jenis;          // Digunakan untuk Filter
  final String status;
  final String bidangHukum;    // Wajib ada
  final String downloadUrl;
  final bool hasFile;

  ProdukHukum({
    required this.id,
    required this.judul,
    required this.nomorPeraturan,
    required this.tahunTerbit,
    required this.jenis,
    required this.status,
    required this.bidangHukum,
    required this.downloadUrl,
    required this.hasFile,
  });

  factory ProdukHukum.fromJson(Map<String, dynamic> json) {
    return ProdukHukum(
      // Aman: Terima int atau String, ubah jadi int. Kalau gagal jadi 0.
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      
      // Aman: Terima null, ubah jadi string kosong atau strip
      judul: json['judul']?.toString() ?? 'Tanpa Judul',
      nomorPeraturan: json['nomor_peraturan']?.toString() ?? '-',
      tahunTerbit: json['tahun_terbit']?.toString() ?? '-',
      jenis: json['jenis']?.toString() ?? 'Umum',
      status: json['status']?.toString() ?? 'Berlaku',
      bidangHukum: json['bidang_hukum']?.toString() ?? '-',
      
      // Khusus URL: Pastikan string kosong jika null
      downloadUrl: json['download_url']?.toString() ?? '',
      
      // Cek boolean dengan aman (terima true/false atau 1/0)
      hasFile: json['has_file'] == true || json['has_file'] == 1,
    );
  }
}