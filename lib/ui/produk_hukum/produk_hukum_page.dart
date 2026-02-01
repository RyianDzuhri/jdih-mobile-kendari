import 'package:flutter/material.dart';
import '../../models/produk_hukum_model.dart';
import '../../models/tipe_dokumen_model.dart';
import '../../services/jdih_service.dart';
import '../widgets/produk_card.dart';

class ProdukHukumPage extends StatefulWidget {
  const ProdukHukumPage({super.key});

  @override
  State<ProdukHukumPage> createState() => _ProdukHukumPageState();
}

class _ProdukHukumPageState extends State<ProdukHukumPage> {
  final JdihService _service = JdihService();

  // Variabel Penampung Data
  List<ProdukHukum> _allDocuments = [];      // Data asli (semua)
  List<ProdukHukum> _filteredDocuments = []; // Data yang tampil di layar
  List<TipeDokumen> _categories = [];        // List tombol filter
  
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Filter Aktif (Default 0 = Semua)
  int _selectedKategoriId = 0; 

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fungsi ambil data dari Server
  Future<void> _fetchData() async {
    try {
      // Kita panggil dua API sekaligus (Paralel) biar cepat
      final results = await Future.wait([
        _service.getTipeDokumen(),
        _service.getAllProdukHukum(),
      ]);

      // Hasil response API
      final types = results[0] as List<TipeDokumen>;
      final docs = results[1] as List<ProdukHukum>;

      // Tambahkan opsi "SEMUA" secara manual di urutan pertama
      final allType = TipeDokumen(id: 0, nama: "Semua", singkatan: "ALL");
      
      setState(() {
        _categories = [allType, ...types]; // Gabung "Semua" + data API
        _allDocuments = docs;
        _filteredDocuments = docs; // Awal buka, tampilkan semua
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Logika Filter Data
  void _filterData(int typeId, String typeName) {
    setState(() {
      _selectedKategoriId = typeId;

      if (typeId == 0) {
        // Jika pilih "Semua", kembalikan ke list asli
        _filteredDocuments = _allDocuments;
      } else {
        // Filter berdasarkan kecocokan Nama Jenis
        // (Pastikan nama di TipeDokumen SAMA dengan field 'jenis' di ProdukHukum)
        _filteredDocuments = _allDocuments
            .where((doc) => doc.jenis.toLowerCase().contains(typeName.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produk Hukum"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text("Error: $_errorMessage"))
              : Column(
                  children: [
                    // 1. BAGIAN FILTER (Horizontal Scroll)
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedKategoriId == cat.id;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat.nama),
                              selected: isSelected,
                              selectedColor: Colors.blue,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              onSelected: (bool selected) {
                                if (selected) {
                                  _filterData(cat.id, cat.nama);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // 2. BAGIAN LIST DOKUMEN
                    Expanded(
                      child: _filteredDocuments.isEmpty
                          ? const Center(child: Text("Tidak ada dokumen ditemukan"))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredDocuments.length,
                              itemBuilder: (context, index) {
                                return ProdukCard(produk: _filteredDocuments[index]);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}