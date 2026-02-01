import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/produk_hukum_model.dart';
import '../../models/tipe_dokumen_model.dart';
import '../../services/jdih_service.dart';
import '../widgets/produk_card.dart';

class DocumentListScreen extends StatefulWidget {
  final String categoryFilter; // Filter dari Menu Utama (PRODUK_HUKUM, ARTIKEL, dll)
  final String pageTitle;
  final String? searchQuery;   // Kata kunci bawaan dari Home (opsional)

  const DocumentListScreen({
    super.key,
    this.categoryFilter = "ALL",
    required this.pageTitle,
    this.searchQuery,
  });

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final JdihService _service = JdihService();
  final TextEditingController _searchController = TextEditingController();
  
  // Data Master
  List<ProdukHukum> _allDocs = [];      // Data Mentah (Semua)
  List<ProdukHukum> _filteredDocs = []; // Data yang Tampil
  List<TipeDokumen> _categories = [];   // Filter Chips
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  // State Filter Aktif
  int _selectedChipId = 0; // 0 = Semua

  @override
  void initState() {
    super.initState();
    // Jika ada kata kunci dari Home, masukkan ke Controller
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
    _fetchAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    try {
      final results = await Future.wait([
        _service.getAllProdukHukum(),
        _service.getTipeDokumen(),
      ]);

      final docs = results[0] as List<ProdukHukum>;
      final types = results[1] as List<TipeDokumen>;

      if (mounted) {
        setState(() {
          _allDocs = docs;
          // Tambah opsi 'Semua' manual
          _categories = [TipeDokumen(id: 0, nama: "Semua", singkatan: "ALL"), ...types];
          
          // Jalankan Filter Pertama Kali
          _runCombinedFilter(); 
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat data. Periksa koneksi internet.";
          _isLoading = false;
        });
      }
    }
  }

  // --- LOGIKA FILTER UTAMA (GABUNGAN) ---
  // Fungsi ini menggabungkan 3 filter sekaligus:
  // 1. Kategori dari Menu Utama (misal: cuma Artikel)
  // 2. Chip yang dipilih (misal: Perda)
  // 3. Teks Pencarian (Search Bar)
  void _runCombinedFilter() {
    List<ProdukHukum> tempDocs = _allDocs;

    // 1. Filter Menu Utama (Scope Halaman)
    if (widget.categoryFilter == "PRODUK_HUKUM") {
       tempDocs = tempDocs.where((doc) {
          final jenis = doc.jenis.toUpperCase();
          return !jenis.contains("ARTIKEL") && !jenis.contains("MONOGRAFI");
       }).toList();
    } else if (widget.categoryFilter == "ARTIKEL") {
       tempDocs = tempDocs.where((doc) => doc.jenis.toUpperCase().contains("ARTIKEL")).toList();
    } else if (widget.categoryFilter == "MONOGRAFI") {
       tempDocs = tempDocs.where((doc) => doc.jenis.toUpperCase().contains("MONOGRAFI")).toList();
    } else if (widget.categoryFilter == "PUTUSAN") {
       tempDocs = tempDocs.where((doc) => doc.jenis.toUpperCase().contains("PUTUSAN")).toList();
    }

    // 2. Filter Chip (Jenis Dokumen)
    if (_selectedChipId != 0) {
      // Cari nama kategori berdasarkan ID yang dipilih
      final selectedCat = _categories.firstWhere((c) => c.id == _selectedChipId);
      tempDocs = tempDocs.where((doc) {
        return doc.jenis.toLowerCase().contains(selectedCat.nama.toLowerCase());
      }).toList();
    }

    // 3. Filter Search Bar (Judul / Nomor)
    String query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      tempDocs = tempDocs.where((doc) {
        return doc.judul.toLowerCase().contains(query) || 
               doc.nomorPeraturan.toLowerCase().contains(query);
      }).toList();
    }

    // Update Tampilan
    setState(() {
      _filteredDocs = tempDocs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1a237e), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.pageTitle,
          style: GoogleFonts.poppins(color: const Color(0xFF1a237e), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    // --- 1. SEARCH BAR DALAM PAGE ---
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                      color: Colors.white,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          // Panggil filter setiap kali ketik
                          onChanged: (value) => _runCombinedFilter(), 
                          decoration: InputDecoration(
                            hintText: "Cari nomor atau judul...",
                            hintStyle: GoogleFonts.lato(fontSize: 14, color: Colors.grey),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            // Tombol Clear (X) kalau ada teks
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      _runCombinedFilter(); // Reset filter search
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),

                    // --- 2. FILTER CHIPS (Scroll Horizontal) ---
                    Container(
                      height: 55,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.black12)),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedChipId == cat.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(cat.nama),
                              selected: isSelected,
                              showCheckmark: false,
                              selectedColor: const Color(0xFF1a237e),
                              backgroundColor: Colors.white,
                              disabledColor: Colors.grey[200],
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                              ),
                              labelStyle: GoogleFonts.lato(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedChipId = cat.id;
                                });
                                _runCombinedFilter(); // Jalankan filter gabungan
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // --- 3. LIST DATA ---
                    Expanded(
                      child: _filteredDocs.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _filteredDocs.length,
                              itemBuilder: (context, index) {
                                return ProdukCard(produk: _filteredDocs[index]);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView( // Biar aman di layar kecil
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 70, color: Colors.grey[300]),
            const SizedBox(height: 15),
            Text(
              "Tidak ada dokumen ditemukan",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            if (_searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "Kata kunci: \"${_searchController.text}\"",
                  style: GoogleFonts.lato(color: Colors.grey[400]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}