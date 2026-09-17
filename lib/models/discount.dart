class Discount {
  final int id;
  final String kodeDiskon;
  final String namaDiskon;
  final double persentase;
  final String tanggalMulai;
  final String tanggalSelesai;
  final bool aktif;

  Discount({
    required this.id,
    required this.kodeDiskon,
    required this.namaDiskon,
    required this.persentase,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.aktif,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'] as int,
      kodeDiskon: json['kode_diskon'] as String,
      namaDiskon: json['nama_diskon'] as String,
      persentase: (json['persentase'] as num).toDouble(),
      tanggalMulai: json['tanggal_mulai'] as String,
      tanggalSelesai: json['tanggal_selesai'] as String,
      aktif: json['aktif'] as bool,
    );
  }
}