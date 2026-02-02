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
  final String? teuBadan; // Tajuk Entri Utama Badan
  final String? lokasi;   // Lokasi Fisik Buku/Arsip
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
    // Constructor Tambahan
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
    return ProdukHukum(
      // LOGIKA ID: Cek 'idData' (Format Baru) dulu, kalau tidak ada cek 'id' (Format Lama)
      id: int.tryParse(json['idData']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,

      judul: json['judul']?.toString() ?? 'Tanpa Judul',
      
      // Mapping Nomor Peraturan (Format Baru: noPeraturan)
      nomorPeraturan: json['noPeraturan']?.toString() ?? json['nomor_peraturan']?.toString() ?? '-',
      
      // Mapping Tahun (Format Baru: tahun_pengundangan)
      tahunTerbit: json['tahun_pengundangan']?.toString() ?? json['tahun_terbit']?.toString() ?? '-',
      
      // Mapping Jenis (Format Baru: jenis)
      jenis: json['jenis']?.toString() ?? json['jenis_peraturan']?.toString() ?? 'Umum',
      
      status: json['status']?.toString() ?? 'Berlaku',
      
      // Bidang Hukum
      bidangHukum: json['bidangHukum']?.toString() ?? json['bidang_hukum']?.toString() ?? '-',

      // LOGIKA URL: Cek 'urlDownload' (Format Baru) dulu
      downloadUrl: json['urlDownload']?.toString() ?? json['download_url']?.toString() ?? '',

      // LOGIKA FILE: Cek keberadaan URL
      hasFile: (json['urlDownload'] != null && json['urlDownload'] != "") || 
               (json['has_file'] == true || json['has_file'] == 1),

      // --- MAPPING DETAIL JDIHN ---
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