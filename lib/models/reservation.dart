import '../core/utils/reservation_helper.dart';

class Reservation {
  final int id;
  final String kodeBooking;
  final int idMember;
  final int idSpace;
  final int? idDiskon;
  final String tanggalReservasi;
  final String jamMulai;
  final String jamSelesai;
  final int durasiJam;
  final double hargaPerJam;
  final double totalHargaAwal;
  final double potonganDiskon;
  final double totalBayar;
  final String status;
  final String? spaceName;
  final String? spaceType;
  final String? memberNama;
  final String? memberTelp;

  Reservation({
    required this.id,
    required this.kodeBooking,
    required this.idMember,
    required this.idSpace,
    this.idDiskon,
    required this.tanggalReservasi,
    required this.jamMulai,
    required this.jamSelesai,
    required this.durasiJam,
    required this.hargaPerJam,
    required this.totalHargaAwal,
    required this.potonganDiskon,
    required this.totalBayar,
    required this.status,
    this.spaceName,
    this.spaceType,
    this.memberNama,
    this.memberTelp,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final space = ReservationHelper.extractSpace(json);
    final member = json['member'] is Map<String, dynamic> ? json['member'] as Map<String, dynamic> : null;

    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    }

    int toInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    final id = toInt(json['id']);
    final total = ReservationHelper.extractPrice(json);
    final spaceName = ReservationHelper.extractSpaceName(json);
    final spaceType = ReservationHelper.extractSpaceType(json);
    final bookingCode = ReservationHelper.extractBookingCode(json);

    return Reservation(
      id: id,
      kodeBooking: bookingCode,
      idMember: toInt(json['id_member']),
      idSpace: toInt(json['id_space'] ?? space['id']),
      idDiskon: json['id_diskon'] != null ? toInt(json['id_diskon']) : null,
      tanggalReservasi: (json['tanggal_reservasi'] ?? '-').toString(),
      jamMulai: (json['jam_mulai'] ?? '-').toString(),
      jamSelesai: (json['jam_selesai'] ?? '-').toString(),
      durasiJam: toInt(json['durasi_jam'], 1),
      hargaPerJam: toDouble(json['harga_per_jam'] ?? space['harga_per_jam']),
      totalHargaAwal: toDouble(json['total_harga_awal'] ?? total),
      potonganDiskon: toDouble(json['potongan_diskon']),
      totalBayar: total,
      status: (json['status'] ?? 'belum_dikonfirm').toString(),
      spaceName: spaceName,
      spaceType: spaceType,
      memberNama: member?['nama_member']?.toString() ?? member?['nama']?.toString(),
      memberTelp: member?['telp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode_booking': kodeBooking,
      'id_member': idMember,
      'id_space': idSpace,
      'id_diskon': idDiskon,
      'tanggal_reservasi': tanggalReservasi,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'durasi_jam': durasiJam,
      'harga_per_jam': hargaPerJam,
      'total_harga_awal': totalHargaAwal,
      'potongan_diskon': potonganDiskon,
      'total_bayar': totalBayar,
      'status': status,
    };
  }
}
