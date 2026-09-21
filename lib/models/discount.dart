class Discount {
  final int id;
  final String namaDiskon;
  final double persentase;
  final String tanggalAwal;
  final String tanggalAkhir;
  final bool aktif;

  Discount({
    required this.id,
    required this.namaDiskon,
    required this.persentase,
    required this.tanggalAwal,
    required this.tanggalAkhir,
    required this.aktif,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> source = json;
    if (json['diskon'] is Map<String, dynamic>) {
      source = json['diskon'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic>) {
      final inner = json['data'] as Map<String, dynamic>;
      if (inner['diskon'] is Map<String, dynamic>) {
        source = inner['diskon'] as Map<String, dynamic>;
      } else {
        source = inner;
      }
    }

    final rawPersen = source['persentase_diskon'] ?? source['persentase'] ?? 0;
    double persen = 0.0;
    if (rawPersen is num) {
      persen = rawPersen.toDouble();
    } else {
      persen = double.tryParse(rawPersen.toString()) ?? 0.0;
    }

    final rawAktif = source['is_active'] ?? source['aktif'] ?? true;
    final bool isActive = rawAktif == true || rawAktif == 1 || rawAktif == '1';

    return Discount(
      id: source['id'] is int
          ? source['id'] as int
          : int.tryParse(source['id']?.toString() ?? '0') ?? 0,
      namaDiskon: (source['nama_diskon'] ?? source['kode_diskon'] ?? '').toString(),
      persentase: persen,
      tanggalAwal: (source['tanggal_awal'] ?? source['tanggal_mulai'] ?? '').toString(),
      tanggalAkhir: (source['tanggal_akhir'] ?? source['tanggal_selesai'] ?? '').toString(),
      aktif: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_diskon': namaDiskon,
      'persentase_diskon': persentase,
      'tanggal_awal': tanggalAwal,
      'tanggal_akhir': tanggalAkhir,
      'is_active': aktif,
    };
  }
}
