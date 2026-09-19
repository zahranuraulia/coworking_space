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
    final rawPersen = json['persentase_diskon'] ?? json['persentase'] ?? 0;
    double persen = 0.0;
    if (rawPersen is num) {
      persen = rawPersen.toDouble();
    } else {
      persen = double.tryParse(rawPersen.toString()) ?? 0.0;
    }

    final rawAktif = json['is_active'] ?? json['aktif'] ?? true;
    final bool isActive = rawAktif == true || rawAktif == 1 || rawAktif == '1';

    return Discount(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaDiskon: (json['nama_diskon'] ?? json['kode_diskon'] ?? '').toString(),
      persentase: persen,
      tanggalAwal: (json['tanggal_awal'] ?? json['tanggal_mulai'] ?? '').toString(),
      tanggalAkhir: (json['tanggal_akhir'] ?? json['tanggal_selesai'] ?? '').toString(),
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
