import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/produk_hukum_model.dart';
import '../../models/tipe_dokumen_model.dart';
import '../../services/jdih_service.dart';
import '../widgets/produk_card.dart';

class DocumentListScreen extends StatefulWidget {
  final String categoryFilter; 
  final String pageTitle;
  
  // PARAMETER FILTER SPESIFIK
  final String? searchQuery;   
  final String? filterNomor;   
  final String? filterTahun;   
  final String? filterJenis;   

  const DocumentListScreen({
    super.key,
    this.categoryFilter = "ALL",
    required this.pageTitle,
    this.searchQuery,
    this.filterNomor,
    this.filterTahun,
    this.filterJenis,
  });

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final JdihService _service = JdihService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ProdukHukum> _allDocs = [];      
  List<ProdukHukum> _filteredDocs = []; 
  List<TipeDokumen> _categories = [];   
  
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedChipId = 0; 

  // Cek apakah ini mode Filter Canggih (Advanced Search)?
  bool get _isAdvancedFilterActive {
    return (widget.filterNomor != null && widget.filterNomor!.isNotEmpty) ||
           (widget.filterTahun != null && widget.filterTahun != "Semua") ||
           (widget.filterJenis != null && widget.filterJenis != "Semua");
  }

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      final results = await Future.wait([
        _service.getAllProdukHukum(),
        _service.getTipeDokumen(),
      ]);

      if (mounted) {
        setState(() {
          _allDocs = results[0] as List<ProdukHukum>;
          // Tambah 'Semua' di awal
          _categories = [TipeDokumen(id: 0, nama: "Semua", singkatan: "ALL"), ...(results[1] as List<TipeDokumen>)];
          
          _runCombinedFilter(); 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMessage = "Gagal memuat data."; _isLoading = false; });
    }
  }

  // --- LOGIKA FILTER UTAMA ---
  void _runCombinedFilter() {
    List<ProdukHukum> tempDocs = _allDocs;

    // 1. Filter Menu Utama (Kategori Besar)
    if (widget.categoryFilter == "PRODUK_HUKUM") {
       tempDocs = tempDocs.where((doc) {
          final j = doc.jenis.toUpperCase();
          return !j.contains("ARTIKEL") && !j.contains("MONOGRAFI");
       }).toList();
    } else if (widget.categoryFilter != "ALL" && widget.categoryFilter.isNotEmpty) {
       tempDocs = tempDocs.where((doc) => doc.jenis.toUpperCase().contains(widget.categoryFilter.toUpperCase())).toList();
    }

    // 2. Filter Chip (Hanya jalan kalau BUKAN Advanced Filter)
    if (!_isAdvancedFilterActive && _selectedChipId != 0) {
      final selectedCat = _categories.firstWhere((c) => c.id == _selectedChipId);
      final filterName = selectedCat.nama.toUpperCase().trim();

      if (filterName == "PUTUSAN") {
         tempDocs = tempDocs.where((doc) {
            final jenis = doc.jenis.toUpperCase();
            return jenis.contains("PUTUSAN") && !jenis.contains("KEPUTUSAN") && !jenis.contains("MAHKAMAH");
         }).toList();
      } else if (filterName != "SEMUA") {
         tempDocs = tempDocs.where((doc) => doc.jenis.toUpperCase().contains(filterName)).toList();
      }
    }

    // 3. Filter Search Bar
    String query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      tempDocs = tempDocs.where((doc) {
        return doc.judul.toLowerCase().contains(query) || 
               doc.nomorPeraturan.toLowerCase().contains(query);
      }).toList();
    }

    // 4. Filter Nomor
    if (widget.filterNomor != null && widget.filterNomor!.isNotEmpty) {
      tempDocs = tempDocs.where((doc) => doc.nomorPeraturan.trim() == widget.filterNomor!.trim()).toList();
    }

    // 5. Filter Tahun
    if (widget.filterTahun != null && widget.filterTahun!.isNotEmpty && widget.filterTahun != "Semua") {
       tempDocs = tempDocs.where((doc) => doc.tahunTerbit == widget.filterTahun).toList();
    }

    // 6. Filter Jenis (Popup)
    if (widget.filterJenis != null && widget.filterJenis!.isNotEmpty && widget.filterJenis != "Semua") {
       final jenisPopup = widget.filterJenis!.toUpperCase();
       
       if (jenisPopup == "PUTUSAN") {
          tempDocs = tempDocs.where((doc) {
             final j = doc.jenis.toUpperCase();
             return j.contains("PUTUSAN") && !j.contains("KEPUTUSAN") && !j.contains("MAHKAMAH");
          }).toList();
       } else {
          tempDocs = tempDocs.where((doc) => doc.jenis.toUpperCase().contains(jenisPopup)).toList();
       }
    }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1a237e)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.pageTitle, style: GoogleFonts.poppins(color: const Color(0xFF1a237e), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                      color: Colors.white,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _runCombinedFilter(),
                        decoration: InputDecoration(
                          hintText: "Cari judul...",
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF0F2F5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    
                    // --- KONDISI TAMPILAN FILTER ---
                    if (!_isAdvancedFilterActive) 
                      // 1. TAMPILKAN KATEGORI CHIPS (NORMAL)
                      Container(
                        height: 50,
                        color: Colors.white,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(cat.nama),
                                selected: _selectedChipId == cat.id,
                                onSelected: (_) { setState(() => _selectedChipId = cat.id); _runCombinedFilter(); },
                                backgroundColor: Colors.white,
                                selectedColor: const Color(0xFF1a237e).withOpacity(0.1),
                                labelStyle: TextStyle(color: _selectedChipId == cat.id ? const Color(0xFF1a237e) : Colors.black87),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: _selectedChipId == cat.id ? Colors.transparent : Colors.grey.shade300)
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else 
                      // 2. TAMPILKAN INFO FILTER AKTIF (MODIFIKASI BARU)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        color: Colors.white,
                        child: SingleChildScrollView(
                           scrollDirection: Axis.horizontal,
                           child: Row(
                             children: [
                               Text("Filter Aktif:", style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                               const SizedBox(width: 10),
                               
                               // Chip Nomor
                               if (widget.filterNomor != null && widget.filterNomor!.isNotEmpty)
                                 _buildActiveFilterTag("Nomor: ${widget.filterNomor}"),

                               // Chip Tahun
                               if (widget.filterTahun != null && widget.filterTahun != "Semua")
                                 _buildActiveFilterTag("Tahun: ${widget.filterTahun}"),

                               // Chip Jenis
                               if (widget.filterJenis != null && widget.filterJenis != "Semua")
                                 _buildActiveFilterTag(widget.filterJenis!),
                             ],
                           ),
                        ),
                      ),
                    
                    // --- LIST DATA ---
                    Expanded(
                      child: _filteredDocs.isEmpty 
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
                                  const SizedBox(height: 10),
                                  Text("Tidak ada dokumen ditemukan", style: GoogleFonts.lato(color: Colors.grey[500])),
                                ],
                              ),
                            ) 
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _filteredDocs.length,
                              itemBuilder: (ctx, i) => ProdukCard(produk: _filteredDocs[i]),
                            ),
                    ),
                  ],
                ),
    );
  }

  // WIDGET KECIL UNTUK LABEL FILTER
  Widget _buildActiveFilterTag(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.blue.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.lato(color: Colors.blue.shade900, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}