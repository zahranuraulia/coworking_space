class AdminProfile {
  final int id;
  final String namaCoworking;
  final String namaPemilik;
  final String telp;

  AdminProfile({
    required this.id,
    required this.namaCoworking,
    required this.namaPemilik,
    required this.telp,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaCoworking: (json['nama_coworking'] ?? '').toString(),
      namaPemilik: (json['nama_pemilik'] ?? '').toString(),
      telp: (json['telp'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_coworking': namaCoworking,
      'nama_pemilik': namaPemilik,
      'telp': telp,
    };
  }
}
