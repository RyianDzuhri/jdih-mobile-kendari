import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'document_list_screen.dart'; // Wajib ada agar bisa pindah halaman

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- DATA MENU UTAMA (Sesuai Desainmu) ---
    final List<Map<String, dynamic>> jenisDokumenList = [
      {"label": "Peraturan &\nKeputusan", "icon": Icons.gavel, "color": 0xFF1565C0, "code": "PRODUK_HUKUM"},
      {"label": "Monografi\nHukum", "icon": Icons.book, "color": 0xFF2E7D32, "code": "MONOGRAFI"},
      {"label": "Artikel /\nMajalah", "icon": Icons.article, "color": 0xFF6A1B9A, "code": "ARTIKEL"},
      {"label": "Putusan\nPengadilan", "icon": Icons.balance, "color": 0xFFC62828, "code": "PUTUSAN"},
    ];

    // --- DATA INFO HUKUM (DUMMY) ---
    final List<Map<String, dynamic>> infoHukumList = [
      {"label": "Propemperda", "code": "PRD"},
      {"label": "Propemperkada", "code": "PRK"},
      {"label": "Ranperda", "code": "RPD"},
      {"label": "Ranperwali", "code": "RPW"},
    ];

    // --- DATA BERITA (DUMMY) ---
    final List<Map<String, String>> beritaList = [
      {
        "judul": "Kota Kendari Raih Penghargaan JDIH Terbaik Tingkat Nasional",
        "tanggal": "27 Jan 2026",
        "kategori": "Prestasi"
      },
      {
        "judul": "DPRD Sahkan 3 Rancangan Peraturan Daerah Menjadi Perda",
        "tanggal": "25 Jan 2026",
        "kategori": "Legislasi"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Warna background abu muda elegan
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAGIAN 1: HEADER & SEARCH
            _buildHeaderSearch(),

            const SizedBox(height: 30),

            // BAGIAN 2: JENIS DOKUMEN (GRID MENU)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Jenis Dokumen", style: _titleStyle()),
            ),
            _buildJenisDokumenGrid(jenisDokumenList),

            const SizedBox(height: 25),

            // BAGIAN 3: INFORMASI HUKUM
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text("Informasi Hukum", style: _titleStyle()),
            ),
            _buildInfoHukumGrid(infoHukumList),

            const SizedBox(height: 25),

            // BAGIAN 4: DISABILITAS
            _buildDisabilitasCard(),

            const SizedBox(height: 25),

            // BAGIAN 5: BERITA
            _buildSectionHeader("Berita Terkini", onTap: () {}),
            _buildBeritaList(beritaList),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET LOGIKA NAVIGASI (GRID MENU) ---
  Widget _buildJenisDokumenGrid(List<Map<String, dynamic>> data) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        
        return InkWell(
          onTap: () {
            // --- PERBAIKAN LOGIKA NAVIGASI DI SINI ---
            // Kita kirim 'code' (PRODUK_HUKUM, dll) ke DocumentListScreen
            // Agar listnya terfilter otomatis sesuai tombol yang diklik
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentListScreen(
                  categoryFilter: item['code'], // Kirim kode filter
                  pageTitle: item['label'].replaceAll('\n', ' '), // Kirim Judul
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(item['color']).withOpacity(0.1), // Background icon transparan
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'], size: 28, color: Color(item['color'])),
                ),
                const SizedBox(height: 10),
                Text(
                  item['label'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER (DESIGN VISUAL) ---

  TextStyle _titleStyle() {
    return GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1a237e));
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _titleStyle()),
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Text("Lainnya", style: GoogleFonts.lato(fontSize: 12, color: const Color(0xFF1565C0), fontWeight: FontWeight.bold)),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFF1565C0))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderSearch() {
    return Stack(
      children: [
        Container(
          height: 200, // Sedikit dipertinggi agar lebih proporsional
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          decoration: const BoxDecoration(
            color: Color(0xFF1a237e), // Biru gelap JDIH
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("JDIH Kota Kendari", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Cari produk hukum daerah", style: GoogleFonts.lato(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 160, left: 20, right: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari peraturan...",
                    hintStyle: GoogleFonts.lato(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.tune, color: Color(0xFF1a237e), size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoHukumGrid(List<Map<String, dynamic>> data) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: data.map((item) {
          return Column(
            children: [
              Container(
                height: 55, width: 55, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  border: Border.all(color: const Color(0xFF1a237e).withOpacity(0.05)),
                ),
                child: Text(item['code'], style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: const Color(0xFF1a237e))),
              ),
              const SizedBox(height: 8),
              Text(item['label'], style: GoogleFonts.lato(fontSize: 11, color: Colors.grey[800]))
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisabilitasCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF880E4F), Color(0xFFAD1457)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF880E4F).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.accessible_forward, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Layanan Disabilitas", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Akses produk hukum ramah disabilitas", style: GoogleFonts.lato(color: Colors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildBeritaList(List<Map<String, String>> data) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80, height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey, size: 30),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                      child: Text(item['kategori']!, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Text(item['judul']!, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 5),
                        Text(item['tanggal']!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}