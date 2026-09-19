class User {
  final int id;
  final String username;
  final String role;
  final int makerId;
  final MemberInfo? member;
  final SpaceOwnerInfo? spaceOwner;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.makerId,
    this.member,
    this.spaceOwner,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    return User(
      id: toInt(json['id']),
      username: (json['username'] ?? '').toString(),
      role: (json['role'] ?? 'member').toString(),
      makerId: toInt(json['maker_id']),
      member: json['member'] is Map<String, dynamic>
          ? MemberInfo.fromJson(json['member'] as Map<String, dynamic>)
          : null,
      spaceOwner: json['space_owner'] is Map<String, dynamic>
          ? SpaceOwnerInfo.fromJson(json['space_owner'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isMember => role == 'member';
  bool get isAdmin => role == 'admin_space' || role == 'admin';
}

class MemberInfo {
  final int id;
  final String namaMember;
  final String? instansi;
  final String? alamat;
  final String? telp;
  final String? foto;

  MemberInfo({
    required this.id,
    required this.namaMember,
    this.instansi,
    this.alamat,
    this.telp,
    this.foto,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaMember: (json['nama_member'] ?? json['nama'] ?? '').toString(),
      instansi: json['instansi']?.toString(),
      alamat: json['alamat']?.toString(),
      telp: (json['telp'] ?? json['telepon'])?.toString(),
      foto: json['foto']?.toString(),
    );
  }
}

class SpaceOwnerInfo {
  final int id;
  final String? namaCoworking;
  final String? namaPemilik;
  final String? telp;

  SpaceOwnerInfo({
    required this.id,
    this.namaCoworking,
    this.namaPemilik,
    this.telp,
  });

  factory SpaceOwnerInfo.fromJson(Map<String, dynamic> json) {
    return SpaceOwnerInfo(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaCoworking: (json['nama_coworking'] ?? json['nama_space'])?.toString(),
      namaPemilik: (json['nama_pemilik'] ?? json['nama'])?.toString(),
      telp: (json['telp'] ?? json['telepon'])?.toString(),
    );
  }
}
