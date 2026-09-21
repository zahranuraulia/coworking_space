import '../core/utils/image_helper.dart';

class Member {
  final int id;
  final String namaMember;
  final String? instansi;
  final String? alamat;
  final String? telp;
  final String? foto;
  final String? fotoUrl;

  Member({
    required this.id,
    required this.namaMember,
    this.instansi,
    this.alamat,
    this.telp,
    this.foto,
    this.fotoUrl,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    final rawFoto = json['foto']?.toString();
    final rawFotoUrl = json['foto_url']?.toString();
    final resolvedUrl = ImageHelper.normalizeUrl(rawFotoUrl ?? rawFoto, folder: 'members');

    return Member(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      namaMember: (json['nama_member'] ?? '').toString(),
      instansi: json['instansi']?.toString(),
      alamat: json['alamat']?.toString(),
      telp: json['telp']?.toString(),
      foto: rawFoto,
      fotoUrl: resolvedUrl,
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
