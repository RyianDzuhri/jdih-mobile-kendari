class ProdukHukum {
  final int id;
  final String judul;
  final String nomorPeraturan;
  final String tahunTerbit;
  final String jenis;
  final String status;
  final String bidangHukum;
  final String downloadUrl; // INI KUNCINYA
  final bool hasFile;

  // Field Tambahan
  final String? tanggalPengundangan;
  final String? tempatTerbit;
  final String? penerbit;
  final String? sumber;
  final String? subjek;
  final String? bahasa;
  final String? teuBadan;
  final String? lokasi;
  final String? abstrak;
  final String? tanggalPenetapan;
  final String? penandatanganan;
  final int? dilihat;
  final int? diunduh;

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
    this.tanggalPenetapan,
    this.penandatanganan,
    this.dilihat,
    this.diunduh,
  });

  factory ProdukHukum.fromJson(Map<String, dynamic> json) {
    // 1. AMBIL URL MENTAH DARI MANAPUN IA BERADA
    String rawUrl = '';
    
    // Cek di key 'fileDownload' (biasanya nama file doang di API 1)
    if (json['fileDownload'] != null && json['fileDownload'].toString().contains('.pdf')) {
       rawUrl = json['fileDownload'].toString();
    }
    // Cek di key 'urlDownload'
    else if (json['urlDownload'] != null) {
      rawUrl = json['urlDownload'].toString();
    }
    // Cek di key 'file_information' -> 'file_url' (API 2)
    else if (json['file_information'] != null && json['file_information']['file_url'] != null) {
      rawUrl = json['file_information']['file_url'].toString();
    }

    // 2. LOGIKA REKONSTRUKSI URL (AMBIL NAMA FILE -> TEMPEL KE BASE URL)
    String finalUrl = '';
    if (rawUrl.isNotEmpty) {
      // Ambil bagian terakhir setelah garis miring (nama file)
      // Contoh: "http://.../storage/namafile.pdf" -> "namafile.pdf"
      String filename = rawUrl.split('/').last;

      // Pastikan nama file mengandung .pdf (untuk keamanan)
      if (filename.toLowerCase().contains('.pdf')) {
        // BANGUN ULANG URL SESUAI STRUKTUR YANG ANDA TEMUKAN
        finalUrl = 'https://jdih.kendarikota.go.id/storage/dokumen/$filename';
      } else {
        // Jika tidak ada .pdf, mungkin URL belum lengkap, pakai apa adanya
        finalUrl = rawUrl;
      }
    }

    return ProdukHukum(
      id: int.tryParse(json['idData']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      judul: json['judul']?.toString() ?? 'Tanpa Judul',
      nomorPeraturan: json['noPeraturan']?.toString() ?? json['nomor_peraturan']?.toString() ?? '-',
      tahunTerbit: json['tahun_pengundangan']?.toString() ?? json['tahun_terbit']?.toString() ?? '-',
      jenis: json['jenis']?.toString() ?? (json['tipe_dokumen'] is Map ? json['tipe_dokumen']['nama'] : null) ?? json['jenis_peraturan']?.toString() ?? 'Umum',
      status: json['status']?.toString() ?? 'Berlaku',
      bidangHukum: json['bidangHukum']?.toString() ?? json['bidang_hukum']?.toString() ?? '-',
      
      // URL HASIL OLAHAN
      downloadUrl: finalUrl,
      hasFile: finalUrl.isNotEmpty,

      // Metadata
      tanggalPengundangan: json['tanggal_pengundangan']?.toString(),
      tempatTerbit: json['tempatTerbit']?.toString() ?? json['tempat_penetapan']?.toString(),
      penerbit: json['penerbit']?.toString(),
      sumber: json['sumber']?.toString(),
      subjek: json['subjek']?.toString(),
      bahasa: json['bahasa']?.toString(),
      teuBadan: json['teuBadan']?.toString(),
      lokasi: json['lokasi']?.toString(),
      abstrak: json['abstrak']?.toString(),
      tanggalPenetapan: json['tanggal_penetapan']?.toString(),
      penandatanganan: json['penandatanganan']?.toString(),
      dilihat: json['statistik'] != null ? int.tryParse(json['statistik']['dilihat'].toString()) : 0,
      diunduh: json['statistik'] != null ? int.tryParse(json['statistik']['diunduh'].toString()) : 0,
    );
  }

  // LOGIKA UPDATE DATA (MERGE)
  ProdukHukum updateDenganDataBaru(ProdukHukum dataBaru) {
    return ProdukHukum(
      id: id,
      judul: judul,
      nomorPeraturan: nomorPeraturan,
      tahunTerbit: tahunTerbit,
      jenis: jenis,
      status: status,
      bidangHukum: bidangHukum,
      
      // Prioritaskan URL yang valid (panjang)
      downloadUrl: (dataBaru.downloadUrl.length > 10) ? dataBaru.downloadUrl : downloadUrl,
      hasFile: dataBaru.hasFile || hasFile,

      tanggalPengundangan: tanggalPengundangan,
      tempatTerbit: tempatTerbit ?? dataBaru.tempatTerbit,
      penerbit: penerbit ?? dataBaru.penerbit,
      sumber: sumber,
      subjek: subjek,
      bahasa: bahasa,
      teuBadan: teuBadan,
      lokasi: lokasi,
      abstrak: (abstrak == null || abstrak!.isEmpty) ? dataBaru.abstrak : abstrak,
      tanggalPenetapan: dataBaru.tanggalPenetapan,
      penandatanganan: dataBaru.penandatanganan,
      dilihat: dataBaru.dilihat,
      diunduh: dataBaru.diunduh,
    );
  }
}