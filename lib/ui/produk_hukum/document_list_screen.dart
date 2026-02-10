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
  
  // WARNA TEMA (Sesuai Home)
  final Color _primaryDark = const Color(0xFF111827); 
  final Color _accentOrange = const Color(0xFFF97316); 

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
      backgroundColor: const Color(0xFFF3F4F6), // Background abu-abu sangat muda (mirip web)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.pageTitle, 
          style: GoogleFonts.poppins(color: _primaryDark, fontWeight: FontWeight.bold, fontSize: 16)
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryDark))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    // SEARCH BAR (Putih Bersih)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      color: Colors.white,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _runCombinedFilter(),
                        decoration: InputDecoration(
                          hintText: "Cari judul dokumen...",
                          hintStyle: GoogleFonts.lato(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search, color: _primaryDark), // Ikon Biru Gelap
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB), // Abu-abu sangat tipis
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _accentOrange.withOpacity(0.5), width: 1)),
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
                            final isSelected = _selectedChipId == cat.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(cat.nama),
                                selected: isSelected,
                                onSelected: (_) { setState(() => _selectedChipId = cat.id); _runCombinedFilter(); },
                                backgroundColor: Colors.white,
                                // Warna Terpilih: Oranye Tipis
                                selectedColor: _accentOrange.withOpacity(0.1),
                                checkmarkColor: _accentOrange,
                                labelStyle: TextStyle(
                                  color: isSelected ? _accentOrange : Colors.grey[700],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? _accentOrange : Colors.grey.shade300
                                  )
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else 
                      // 2. TAMPILKAN INFO FILTER AKTIF (TAGS)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(top: BorderSide(color: Colors.grey.shade100))
                        ),
                        child: SingleChildScrollView(
                           scrollDirection: Axis.horizontal,
                           child: Row(
                             crossAxisAlignment: CrossAxisAlignment.center,
                             children: [
                               Icon(Icons.filter_list_rounded, size: 16, color: _primaryDark),
                               const SizedBox(width: 8),
                               Text("Filter Aktif:", style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: _primaryDark)),
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
                                  Icon(Icons.folder_off_outlined, size: 60, color: Colors.grey[300]),
                                  const SizedBox(height: 15),
                                  Text("Tidak ada dokumen ditemukan", style: GoogleFonts.lato(color: Colors.grey[600], fontSize: 16)),
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

  // WIDGET KECIL UNTUK LABEL FILTER (ORANYE STYLE)
  Widget _buildActiveFilterTag(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _accentOrange.withOpacity(0.1), // Oranye muda
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentOrange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Batasi panjang teks label agar tidak terlalu lebar
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(color: _accentOrange, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.close, size: 12, color: _accentOrange), // Ikon Close kecil (hiasan)
        ],
      ),
    );
  }
}