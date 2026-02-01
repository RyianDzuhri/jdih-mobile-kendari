import 'package:flutter/material.dart';
import '../../models/produk_hukum_model.dart';
import '../produk_hukum/detail_page.dart';

class ProdukCard extends StatelessWidget {
  final ProdukHukum produk;

  const ProdukCard({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(produk: produk)));
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Jenis & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        produk.jenis.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    Icon(
                      produk.status.toLowerCase() == 'berlaku' ? Icons.check_circle : Icons.info,
                      size: 16,
                      color: produk.status.toLowerCase() == 'berlaku' ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Judul
                Text(
                  produk.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 8),

                // Footer: Tahun & Info
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Tahun ${produk.tahunTerbit}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Spacer(),
                    Text(
                      "Lihat Detail >",
                      style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}