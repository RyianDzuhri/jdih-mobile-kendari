class ProdukHukum {
  final int id;
  final String judul;
  final String nomorPeraturan;
  final String tahunTerbit;
  final String jenis;
  final String status;
  final String bidangHukum;
  
  // URL FILE UTAMA (Dokumen Peraturan)
  final String downloadUrl; 
  final bool hasFile;

  // URL FILE ABSTRAK (Jika ada)
  final String? abstrakUrl;

  // Metadata
  final String? tanggalPengundangan;
  final String? tempatTerbit;
  final String? penerbit;
  final String? sumber;
  final String? subjek;
  final String? bahasa;
  final String? teuBadan;
  final String? lokasi;
  final String? abstrak; // Isi teks ringkasan (atau nama file raw)
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
    this.abstrakUrl,
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
    // ---------------------------------------------------------
    // 1. LOGIKA URL DOKUMEN UTAMA
    // ---------------------------------------------------------
    String rawUrl = '';
    
    if (json['fileDownload'] != null && json['fileDownload'].toString().contains('.pdf')) {
       rawUrl = json['fileDownload'].toString();
    } else if (json['urlDownload'] != null) {
      rawUrl = json['urlDownload'].toString();
    } else if (json['file_information'] != null && json['file_information']['file_url'] != null) {
      rawUrl = json['file_information']['file_url'].toString();
    }

    String finalUrl = '';
    if (rawUrl.isNotEmpty) {
      String filename = rawUrl.split('/').last;
      if (filename.toLowerCase().contains('.pdf')) {
        finalUrl = 'https://jdih.kendarikota.go.id/storage/dokumen/$filename';
      } else {
        finalUrl = rawUrl;
      }
    }

    // ---------------------------------------------------------
    // 2. LOGIKA URL FILE ABSTRAK (PERBAIKAN FOLDER)
    // ---------------------------------------------------------
    String? finalAbstrakUrl;
    
    // Ambil isi mentah dari field 'abstrak'
    String contentAbstrak = json['abstrak']?.toString() ?? '';

    // LOGIKA: Jika field 'abstrak' mengandung '.pdf', maka itu adalah FILE.
    if (contentAbstrak.toLowerCase().contains('.pdf')) {
       // Bersihkan nama file (jika ada path)
       String filenameAbstrak = contentAbstrak.split('/').last;
       
       // PERBAIKAN: Folder diganti jadi /storage/dokumen/
       finalAbstrakUrl = 'https://jdih.kendarikota.go.id/storage/dokumen/$filenameAbstrak';
    } 
    // Cek juga field 'fileAbstrak' untuk jaga-jaga
    else if (json['fileAbstrak'] != null && json['fileAbstrak'].toString().contains('.pdf')) {
       String fName = json['fileAbstrak'].toString().split('/').last;
       
       // PERBAIKAN: Folder diganti jadi /storage/dokumen/
       finalAbstrakUrl = 'https://jdih.kendarikota.go.id/storage/dokumen/$fName';
    }

    return ProdukHukum(
      id: int.tryParse(json['idData']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      judul: json['judul']?.toString() ?? 'Tanpa Judul',
      nomorPeraturan: json['noPeraturan']?.toString() ?? json['nomor_peraturan']?.toString() ?? '-',
      tahunTerbit: json['tahun_pengundangan']?.toString() ?? json['tahun_terbit']?.toString() ?? '-',
      jenis: json['jenis']?.toString() ?? (json['tipe_dokumen'] is Map ? json['tipe_dokumen']['nama'] : null) ?? json['jenis_peraturan']?.toString() ?? 'Umum',
      status: json['status']?.toString() ?? 'Berlaku',
      bidangHukum: json['bidangHukum']?.toString() ?? json['bidang_hukum']?.toString() ?? '-',
      
      downloadUrl: finalUrl,
      hasFile: finalUrl.isNotEmpty,
      
      // URL ABSTRAK YANG SUDAH JADI (FOLDER DOKUMEN)
      abstrakUrl: finalAbstrakUrl, 

      tanggalPengundangan: json['tanggal_pengundangan']?.toString(),
      tempatTerbit: json['tempatTerbit']?.toString() ?? json['tempat_penetapan']?.toString(),
      penerbit: json['penerbit']?.toString(),
      sumber: json['sumber']?.toString(),
      subjek: json['subjek']?.toString(),
      bahasa: json['bahasa']?.toString(),
      teuBadan: json['teuBadan']?.toString(),
      lokasi: json['lokasi']?.toString(),
      
      // Field 'abstrak' tetap diisi apa adanya untuk ditampilkan di UI 
      abstrak: contentAbstrak, 
      
      tanggalPenetapan: json['tanggal_penetapan']?.toString(),
      penandatanganan: json['penandatanganan']?.toString(),
      dilihat: json['statistik'] != null ? int.tryParse(json['statistik']['dilihat'].toString()) : 0,
      diunduh: json['statistik'] != null ? int.tryParse(json['statistik']['diunduh'].toString()) : 0,
    );
  }

  ProdukHukum updateDenganDataBaru(ProdukHukum dataBaru) {
    return ProdukHukum(
      id: id,
      judul: judul,
      nomorPeraturan: nomorPeraturan,
      tahunTerbit: tahunTerbit,
      jenis: jenis,
      status: status,
      bidangHukum: bidangHukum,
      downloadUrl: (dataBaru.downloadUrl.length > 10) ? dataBaru.downloadUrl : downloadUrl,
      hasFile: dataBaru.hasFile || hasFile,
      
      // Update Abstrak Url
      abstrakUrl: (dataBaru.abstrakUrl != null) ? dataBaru.abstrakUrl : abstrakUrl,

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