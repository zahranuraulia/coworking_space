class Space {
  final int id;
  final String namaSpace;
  final String tipeSpace;
  final int kapasitas;
  final double hargaPerJam;
  final String? foto;
  final String? deskripsi;

  Space({
    required this.id,
    required this.namaSpace,
    required this.tipeSpace,
    required this.kapasitas,
    required this.hargaPerJam,
    this.foto,
    this.deskripsi,
  });

  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as int,
      namaSpace: json['nama_space'] as String,
      tipeSpace: json['tipe_space'] as String,
      kapasitas: json['kapasitas'] as int,
      hargaPerJam: (json['harga_per_jam'] as num).toDouble(),
      foto: json['foto'] as String?,
      deskripsi: json['deskripsi'] as String?,
    );
  }
}