class BeritaModel {
  final int id;
  final String judul;
  final String? slug;
  final String? isi; // Konten berita
  final String? image; // Path gambar
  final String createdAt;

  BeritaModel({
    required this.id,
    required this.judul,
    this.slug,
    this.isi,
    this.image,
    required this.createdAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'],
      judul: json['judul'] ?? 'Berita Tanpa Judul',
      slug: json['slug'],
      isi: json['isi'], // Nanti kita perlu bersihkan tag HTML-nya di UI
      image: json['image'],
      createdAt: json['created_at'] ?? '',
    );
  }
}