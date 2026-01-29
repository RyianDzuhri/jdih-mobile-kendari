class DocumentModel {
  final int id;
  final String judul;
  final String nomorPeraturan;
  final String tahun;        // Diambil dari 'tahun_terbit'
  final String jenisDokumen; // Diambil dari 'jenis' atau 'jenis_peraturan'
  final String status;
  final String bidangHukum;
  final String? downloadUrl;
  final String? abstrak;     // Nullable (mungkin kosong di list, ada di detail)

  DocumentModel({
    required this.id,
    required this.judul,
    required this.nomorPeraturan,
    required this.tahun,
    required this.jenisDokumen,
    required this.status,
    required this.bidangHukum,
    this.downloadUrl,
    this.abstrak,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      // 1. ID: Pastikan selalu jadi Integer
      id: json['id'] is int 
          ? json['id'] 
          : int.tryParse(json['id'].toString()) ?? 0,

      // 2. JUDUL: Default text jika null
      judul: json['judul']?.toString() ?? 'Tanpa Judul',

      // 3. NOMOR: Default strip jika null
      nomorPeraturan: json['nomor_peraturan']?.toString() ?? '-',

      // 4. TAHUN: Prioritaskan 'tahun_terbit', lalu 'tahun'. Ubah ke String agar aman.
      tahun: (json['tahun_terbit'] ?? json['tahun'] ?? '-').toString(),

      // 5. JENIS: Prioritaskan 'jenis', lalu 'jenis_peraturan' (jaga-jaga nama field server berubah)
      jenisDokumen: (json['jenis'] ?? json['jenis_peraturan'] ?? 'Dokumen Hukum').toString(),

      // 6. STATUS & BIDANG HUKUM
      status: json['status']?.toString() ?? 'Berlaku',
      bidangHukum: json['bidang_hukum']?.toString() ?? '-',

      // 7. URL & ABSTRAK: Boleh null
      downloadUrl: json['download_url'],
      abstrak: json['abstrak']?.toString(), 
    );
  }
}