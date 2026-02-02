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
    'X-API-Key': 'jdih_mobile_key_rahasia', // Pastikan key ini sesuai dengan backend
  };

  // 1. Ambil Tipe Dokumen
  Future<List<TipeDokumen>> getTipeDokumen() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.documentTypes), headers: _headers);
      
      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);
        List<dynamic> data = [];

        if (jsonResponse is List) {
           data = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse.containsKey('data')) {
           data = jsonResponse['data'] ?? [];
        }
        
        return data.map((e) => TipeDokumen.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error koneksi tipe dokumen: $e");
      return [];
    }
  }

  // 2. Ambil Semua Produk Hukum (List Awal)
  Future<List<ProdukHukum>> getAllProdukHukum() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.allDocuments), headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        
        // Filter id 0 untuk menghindari data error
        return data.map((e) => ProdukHukum.fromJson(e)).where((e) => e.id != 0).toList();
      } else {
        throw Exception("Gagal Akses Data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error koneksi produk hukum: $e");
      rethrow;
    }
  }

  // 3. AMBIL DETAIL PRODUK HUKUM (FORMAT JDIHN BARU)
  Future<ProdukHukum> getDetailProdukHukum(int id) async {
    try {
      // URL Khusus Format JDIHN
      // http://jdih.kendarikota.go.id/api/jdih/jdihn-format/documents/795
      final String url = 'http://jdih.kendarikota.go.id/api/jdih/jdihn-format/documents/$id';
      
      print("Mengambil Detail ID: $id dari $url");

      final response = await http.get(
        Uri.parse(url),
        // headers: _headers, // Uncomment jika API Detail juga butuh header
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Langsung parse karena response JSON-nya langsung object (bukan list/data wrapper)
        // Sesuai contoh: { "idData": "795", ... }
        return ProdukHukum.fromJson(jsonResponse);
      } else {
        throw Exception('Gagal memuat detail: ${response.statusCode}');
      }
    } catch (e) {
      print("Error detail jdihn: $e");
      rethrow;
    }
  }
}