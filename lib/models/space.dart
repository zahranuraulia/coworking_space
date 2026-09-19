class Space {
  final int id;
  final String namaSpace;
  final String tipe;
  final int kapasitas;
  final double hargaPerJam;
  final String? foto;
  final String? fotoUrl;
  final String? deskripsi;
  final String? lokasi;

  Space({
    required this.id,
    required this.namaSpace,
    required this.tipe,
    required this.kapasitas,
    required this.hargaPerJam,
    this.foto,
    this.fotoUrl,
    this.deskripsi,
    this.lokasi,
  });

  String get displayTipe {
    switch (tipe.toLowerCase()) {
      case 'desk':
        return 'Personal Desk';
      case 'meeting_room':
        return 'Meeting Room';
      case 'private_office':
        return 'Private Office';
      default:
        return tipe;
    }
  }

  factory Space.fromJson(Map<String, dynamic> json) {
    int parsedKapasitas = 1;
    if (json['kapasitas'] != null) {
      if (json['kapasitas'] is int) {
        parsedKapasitas = json['kapasitas'] as int;
      } else {
        parsedKapasitas = int.tryParse(json['kapasitas'].toString()) ?? 1;
      }
    }

    double parsedHarga = 0.0;
    if (json['harga_per_jam'] != null) {
      if (json['harga_per_jam'] is num) {
        parsedHarga = (json['harga_per_jam'] as num).toDouble();
      } else {
        final cleaned = json['harga_per_jam'].toString().replaceAll(RegExp(r'[^\d.]'), '');
        parsedHarga = double.tryParse(cleaned) ?? 0.0;
      }
    }

    final String? ownerName = json['owner'] is Map<String, dynamic>
        ? json['owner']['nama_coworking'] as String?
        : null;

    return Space(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaSpace: (json['nama_space'] ?? json['name'] ?? 'Space').toString(),
      tipe: (json['tipe'] ?? json['tipe_space'] ?? 'desk').toString(),
      kapasitas: parsedKapasitas,
      hargaPerJam: parsedHarga,
      foto: json['foto']?.toString(),
      fotoUrl: json['foto_url']?.toString(),
      deskripsi: json['deskripsi']?.toString(),
      lokasi: ownerName ?? json['location']?.toString() ?? 'Coworking Space',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_space': namaSpace,
      'tipe': tipe,
      'kapasitas': kapasitas,
      'harga_per_jam': hargaPerJam,
      'foto': foto,
      'foto_url': fotoUrl,
      'deskripsi': deskripsi,
    };
  }
}
