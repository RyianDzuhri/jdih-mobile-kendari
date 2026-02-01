import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import '../models/produk_hukum_model.dart';
import '../models/tipe_dokumen_model.dart';

class JdihService {
  
  // HEADERS DENGAN API KEY
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', 
    'X-API-Key': 'jdih_mobile_key_rahasia', 
  };

  // 1. Ambil Tipe Dokumen (PERBAIKAN LOGIKA PARSING)
  Future<List<TipeDokumen>> getTipeDokumen() async {
    try {
      print("Mengambil Tipe Dokumen...");
      final response = await http.get(
        Uri.parse(ApiConfig.documentTypes),
        headers: _headers,
      );
      
      print("Status Tipe Dokumen: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Decode sebagai dynamic dulu karena kita belum tahu bentuknya List atau Map
        final dynamic jsonResponse = json.decode(response.body);
        
        List<dynamic> data = [];

        // CEK 1: Apakah responsenya langsung List? [{}, {}]
        if (jsonResponse is List) {
           data = jsonResponse;
        } 
        // CEK 2: Apakah responsenya Map dengan key 'data'? { "data": [] }
        else if (jsonResponse is Map && jsonResponse.containsKey('data')) {
           data = jsonResponse['data'] ?? [];
        }

        print("Berhasil dapat ${data.length} kategori."); // Debugging
        
        return data.map((e) => TipeDokumen.fromJson(e)).toList();
      } else {
        print("Gagal ambil tipe dokumen. Code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error koneksi tipe dokumen: $e");
      return [];
    }
  }

  // 2. Ambil Semua Produk Hukum (Tetap Sama)
  Future<List<ProdukHukum>> getAllProdukHukum() async {
    try {
      print("Mengambil Semua Produk Hukum...");
      final response = await http.get(
        Uri.parse(ApiConfig.allDocuments),
        headers: _headers,
      );

      print("Status Produk Hukum: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        
        return data.map((e) {
            try {
              return ProdukHukum.fromJson(e);
            } catch (_) {
              return ProdukHukum(
                id: 0, 
                judul: "Format Salah", 
                tahunTerbit: "-", 
                jenis: "-", 
                status: "-", 
                downloadUrl: "", 
                hasFile: false,
                nomorPeraturan: "-",
                bidangHukum: "-"
              );
            }
        }).where((e) => e.id != 0).toList();
      } else {
        throw Exception("Gagal Akses Data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error koneksi produk hukum: $e");
      rethrow;
    }
  }
}