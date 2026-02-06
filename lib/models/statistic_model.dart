class StatisticModel {
  final int totalDokumen;
  final String lastUpdated;
  final List<StatistikItem> perTahun;
  final List<StatistikItem> perTipe;
  final List<StatistikItem> perStatus;

  StatisticModel({
    required this.totalDokumen,
    required this.lastUpdated,
    required this.perTahun,
    required this.perTipe,
    required this.perStatus,
  });

  factory StatisticModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk parsing list
    List<StatistikItem> parseList(String key, String labelKey) {
      final list = json[key] as List? ?? [];
      return list.map((item) => StatistikItem.fromJson(item, labelKey)).toList();
    }

    return StatisticModel(
      totalDokumen: int.tryParse(json['total_dokumen'].toString()) ?? 0,
      lastUpdated: json['last_updated']?.toString() ?? '-',
      perTahun: parseList('dokumen_per_tahun', 'tahun'),
      perTipe: parseList('dokumen_per_tipe', 'tipe'),
      perStatus: parseList('dokumen_per_status', 'status'),
    );
  }
}

class StatistikItem {
  final String label; // Bisa berisi Tahun, Tipe, atau Status
  final int total;

  StatistikItem({required this.label, required this.total});

  factory StatistikItem.fromJson(Map<String, dynamic> json, String labelKey) {
    return StatistikItem(
      label: json[labelKey]?.toString() ?? '-',
      total: int.tryParse(json['total'].toString()) ?? 0,
    );
  }
}