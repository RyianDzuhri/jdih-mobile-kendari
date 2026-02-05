import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/produk_hukum_model.dart';
import '../models/tipe_dokumen_model.dart';

class JdihService {
  
  // HEADERS (PASTIKAN KEY INI BENAR)
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', 
    'X-API-Key': 'jdih_mobile_key_rahasia', 
  };

  // ... (Fungsi getTipeDokumen & getAllProdukHukum TETAP SAMA seperti kode lama Anda) ...
  // copy-paste saja bagian getTipeDokumen & getAllProdukHukum dari kode lama Anda

  Future<List<TipeDokumen>> getTipeDokumen() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.documentTypes), headers: _headers);
      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        List<dynamic> data = [];
        if (jsonResponse is List) { data = jsonResponse; } 
        else if (jsonResponse is Map && jsonResponse.containsKey('data')) { data = jsonResponse['data'] ?? []; }
        return data.map((e) => TipeDokumen.fromJson(e)).toList();
      }
      return [];
    } catch (e) { return []; }
  }

  Future<List<ProdukHukum>> getAllProdukHukum() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.allDocuments), headers: _headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((e) => ProdukHukum.fromJson(e)).where((e) => e.id != 0).toList();
      } else {
        throw Exception("Gagal Akses Data: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- FUNGSI BARU: DOUBLE API (JDIHN + INTERNAL) ---
  Future<ProdukHukum> getDetailLengkap(int id) async {
    try {
      final String urlApi1 = 'http://jdih.kendarikota.go.id/api/jdih/jdihn-format/documents/$id';
      final String urlApi2 = 'http://jdih.kendarikota.go.id/api/jdih/documents/$id';

      print("Mulai Request Double API untuk ID: $id");

      // Panggil Paralel (Future.wait)
      final results = await Future.wait([
        http.get(Uri.parse(urlApi1), headers: _headers), // API 1
        http.get(Uri.parse(urlApi2), headers: _headers), // API 2
      ]);

      final res1 = results[0];
      final res2 = results[1];

      ProdukHukum? dataUtama; // Hasil dari API 1
      ProdukHukum? dataTambahan; // Hasil dari API 2

      // Proses API 1 (JDIHN)
      if (res1.statusCode == 200) {
        try {
          dataUtama = ProdukHukum.fromJson(json.decode(res1.body));
        } catch (e) { print("Error parse API 1: $e"); }
      }

      // Proses API 2 (Internal - Penandatangan, dll)
      if (res2.statusCode == 200) {
        try {
          dataTambahan = ProdukHukum.fromJson(json.decode(res2.body));
        } catch (e) { print("Error parse API 2: $e"); }
      }

      // LOGIKA PENGGABUNGAN
      if (dataUtama != null && dataTambahan != null) {
        // Gabungkan: Data Utama diupdate dengan Data Tambahan
        print("✅ Sukses Gabung Data");
        return dataUtama.updateDenganDataBaru(dataTambahan);
      } else if (dataUtama != null) {
        return dataUtama;
      } else if (dataTambahan != null) {
        return dataTambahan;
      } else {
        throw Exception("Gagal mengambil data dari kedua API (Cek Koneksi/ID)");
      }

    } catch (e) {
      print("Error Service Detail: $e");
      rethrow;
    }
  }
}