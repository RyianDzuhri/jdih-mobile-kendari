class ProdukHukum {
  final int id;
  final String judul;
  final String nomorPeraturan;
  final String tahunTerbit;
  final String jenis;
  final String status;
  final String bidangHukum;
  final String downloadUrl;
  final bool hasFile;

  // --- FIELD TAMBAHAN (FORMAT JDIHN) ---
  final String? tanggalPengundangan;
  final String? tempatTerbit;
  final String? penerbit;
  final String? sumber;
  final String? subjek;
  final String? bahasa;
  final String? teuBadan; 
  final String? lokasi;   
  final String? abstrak;

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
    this.tanggalPengundangan,
    this.tempatTerbit,
    this.penerbit,
    this.sumber,
    this.subjek,
    this.bahasa,
    this.teuBadan,
    this.lokasi,
    this.abstrak,
  });

  factory ProdukHukum.fromJson(Map<String, dynamic> json) {
    
    // --- LOGIKA PERBAIKAN URL ---
    String rawUrl = json['urlDownload']?.toString() ?? json['download_url']?.toString() ?? '';
    
    // Cek apakah URL berisi '/storage/' TAPI TIDAK berisi '/storage/dokumen/'
    if (rawUrl.isNotEmpty && rawUrl.contains('/storage/') && !rawUrl.contains('/storage/dokumen/')) {
      // Sisipkan '/dokumen' setelah '/storage'
      rawUrl = rawUrl.replaceFirst('/storage/', '/storage/dokumen/');
    }
    // ----------------------------

    return ProdukHukum(
      id: int.tryParse(json['idData']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      judul: json['judul']?.toString() ?? 'Tanpa Judul',
      nomorPeraturan: json['noPeraturan']?.toString() ?? json['nomor_peraturan']?.toString() ?? '-',
      tahunTerbit: json['tahun_pengundangan']?.toString() ?? json['tahun_terbit']?.toString() ?? '-',
      jenis: json['jenis']?.toString() ?? json['jenis_peraturan']?.toString() ?? 'Umum',
      status: json['status']?.toString() ?? 'Berlaku',
      bidangHukum: json['bidangHukum']?.toString() ?? json['bidang_hukum']?.toString() ?? '-',

      // GUNAKAN URL YANG SUDAH DIPERBAIKI
      downloadUrl: rawUrl,

      // Cek File
      hasFile: (rawUrl.isNotEmpty) || (json['has_file'] == true || json['has_file'] == 1),

      // Mapping Detail
      tanggalPengundangan: json['tanggal_pengundangan']?.toString(),
      tempatTerbit: json['tempatTerbit']?.toString() ?? json['tempat_penetapan']?.toString(),
      penerbit: json['penerbit']?.toString(),
      sumber: json['sumber']?.toString(),
      subjek: json['subjek']?.toString(),
      bahasa: json['bahasa']?.toString(),
      teuBadan: json['teuBadan']?.toString(),
      lokasi: json['lokasi']?.toString(),
      abstrak: json['abstrak']?.toString(),
    );
  }
}