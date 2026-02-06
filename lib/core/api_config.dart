class ApiConfig {
  // Base URL utama
  static const String baseUrl = "https://jdih.kendarikota.go.id";

  // Daftar Endpoints
  static const String allDocuments = "$baseUrl/api/jdih/all-documents";
  static const String documentTypes = "$baseUrl/api/jdih/document-types";
  static const String search = "$baseUrl/api/jdih/search";
  static const String detailDocument = "$baseUrl/api/jdih/documents"; // + /{id}
  static const String statistics = "$baseUrl/api/jdih/statistics";
  
  // Timeout (opsional, buat jaga-jaga kalau server lambat)
  static const int receiveTimeout = 15000; // 15 detik
  static const int connectionTimeout = 15000;
}