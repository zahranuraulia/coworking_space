class RevenueReport {
  final int month;
  final int year;
  final int totalTransaksi;
  final int totalJamTerpakai;
  final double estimasiPendapatanKotor;
  final double totalPotonganDiskon;
  final double realisasiPendapatanBersih;
  final List<SpaceRevenueItem> rincianPerTipeSpace;
  final List<DailyTrendItem> trenHarian;

  RevenueReport({
    required this.month,
    required this.year,
    required this.totalTransaksi,
    required this.totalJamTerpakai,
    required this.estimasiPendapatanKotor,
    required this.totalPotonganDiskon,
    required this.realisasiPendapatanBersih,
    required this.rincianPerTipeSpace,
    this.trenHarian = const [],
  });

  double get displayPendapatan =>
      realisasiPendapatanBersih > 0 ? realisasiPendapatanBersih : estimasiPendapatanKotor;

  factory RevenueReport.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }

    int toInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    final periode = json['periode'] is Map<String, dynamic>
        ? json['periode'] as Map<String, dynamic>
        : null;
    final ringkasan = json['ringkasan'] is Map<String, dynamic>
        ? json['ringkasan'] as Map<String, dynamic>
        : null;

    final month = toInt(periode?['bulan'] ?? json['month']);
    final year = toInt(periode?['tahun'] ?? json['year']);
    final totalTransaksi = toInt(ringkasan?['total_reservasi'] ?? json['total_transaksi']);
    final estimasiKotor = toDouble(
      ringkasan?['estimasi_pendapatan_total'] ?? json['estimasi_pendapatan_kotor'],
    );
    final realisasiBersih = toDouble(
      ringkasan?['realisasi_pendapatan'] ?? json['realisasi_pendapatan_bersih'],
    );
    final totalJam = toInt(json['total_jam_terpakai']);
    final totalDiskon = toDouble(json['total_potongan_diskon']);

    final List<SpaceRevenueItem> rincian = [];

    // Parse format A: Map 'pendapatan_per_tipe_space'
    if (json['pendapatan_per_tipe_space'] is Map<String, dynamic>) {
      final map = json['pendapatan_per_tipe_space'] as Map<String, dynamic>;
      const labels = {
        'desk': 'Personal Desk',
        'private_office': 'Private Office',
        'meeting_room': 'Meeting Room',
      };

      for (final entry in labels.entries) {
        final val = map[entry.key];
        if (val is Map<String, dynamic>) {
          rincian.add(SpaceRevenueItem(
            tipe: entry.key,
            label: entry.value,
            totalBooking: toInt(val['count']),
            totalJam: toInt(val['total_jam'] ?? val['hours'] ?? 0),
            totalPendapatan: toDouble(val['total_income']),
          ));
        } else {
          rincian.add(SpaceRevenueItem(
            tipe: entry.key,
            label: entry.value,
            totalBooking: 0,
            totalJam: 0,
            totalPendapatan: 0.0,
          ));
        }
      }
    } else if (json['rincian_per_tipe_space'] is List) {
      final rawList = json['rincian_per_tipe_space'] as List<dynamic>;
      rincian.addAll(rawList.map((e) => SpaceRevenueItem.fromJson(e as Map<String, dynamic>)));
    }

    // Parse 'tren_harian'
    final List<DailyTrendItem> trenList = [];
    if (json['tren_harian'] is List) {
      final rawTrends = json['tren_harian'] as List<dynamic>;
      trenList.addAll(
        rawTrends.map((e) => DailyTrendItem.fromJson(e as Map<String, dynamic>)),
      );
    }

    return RevenueReport(
      month: month,
      year: year,
      totalTransaksi: totalTransaksi,
      totalJamTerpakai: totalJam,
      estimasiPendapatanKotor: estimasiKotor,
      totalPotonganDiskon: totalDiskon,
      realisasiPendapatanBersih: realisasiBersih,
      rincianPerTipeSpace: rincian,
      trenHarian: trenList,
    );
  }
}

class SpaceRevenueItem {
  final String tipe;
  final String label;
  final int totalBooking;
  final int totalJam;
  final double totalPendapatan;

  SpaceRevenueItem({
    required this.tipe,
    required this.label,
    required this.totalBooking,
    required this.totalJam,
    required this.totalPendapatan,
  });

  factory SpaceRevenueItem.fromJson(Map<String, dynamic> json) {
    return SpaceRevenueItem(
      tipe: (json['tipe'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      totalBooking: json['total_booking'] is int
          ? json['total_booking'] as int
          : int.tryParse(json['total_booking']?.toString() ?? '0') ?? 0,
      totalJam: json['total_jam'] is int
          ? json['total_jam'] as int
          : int.tryParse(json['total_jam']?.toString() ?? '0') ?? 0,
      totalPendapatan: json['total_pendapatan'] is num
          ? (json['total_pendapatan'] as num).toDouble()
          : double.tryParse(json['total_pendapatan']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class DailyTrendItem {
  final String tanggal;
  final int totalReservations;
  final double totalIncome;

  DailyTrendItem({
    required this.tanggal,
    required this.totalReservations,
    required this.totalIncome,
  });

  factory DailyTrendItem.fromJson(Map<String, dynamic> json) {
    return DailyTrendItem(
      tanggal: (json['tanggal'] ?? '').toString(),
      totalReservations: json['total_reservations'] is int
          ? json['total_reservations'] as int
          : int.tryParse(json['total_reservations']?.toString() ?? '0') ?? 0,
      totalIncome: json['total_income'] is num
          ? (json['total_income'] as num).toDouble()
          : double.tryParse(json['total_income']?.toString() ?? '0') ?? 0.0,
    );
  }
}
