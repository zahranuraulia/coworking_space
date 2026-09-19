class Member {
  final int id;
  final String namaMember;
  final String? instansi;
  final String? alamat;
  final String? telp;
  final String? foto;

  Member({
    required this.id,
    required this.namaMember,
    this.instansi,
    this.alamat,
    this.telp,
    this.foto,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaMember: (json['nama_member'] ?? '').toString(),
      instansi: json['instansi']?.toString(),
      alamat: json['alamat']?.toString(),
      telp: json['telp']?.toString(),
      foto: json['foto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_member': namaMember,
      'instansi': instansi,
      'alamat': alamat,
      'telp': telp,
      'foto': foto,
    };
  }
}
