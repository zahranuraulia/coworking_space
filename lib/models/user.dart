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
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
      makerId: json['maker_id'] as int,
      member: json['member'] != null
          ? MemberInfo.fromJson(
              json['member'] as Map<String, dynamic>,
            )
          : null,
      spaceOwner: json['space_owner'] != null
          ? SpaceOwnerInfo.fromJson(
              json['space_owner'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  bool get isMember => role == 'member';

  bool get isAdmin => role == 'admin_space';
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
      id: json['id'] as int,
      namaMember: json['nama_member'] as String,
      instansi: json['instansi'] as String?,
      alamat: json['alamat'] as String?,
      telp: json['telp'] as String?,
      foto: json['foto'] as String?,
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
      id: json['id'] as int,
      namaCoworking: json['nama_coworking'] as String?,
      namaPemilik: json['nama_pemilik'] as String?,
      telp: json['telp'] as String?,
    );
  }
}