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
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int,
      kodeBooking: json['kode_booking'] as String,
      idMember: json['id_member'] as int,
      idSpace: json['id_space'] as int,
      idDiskon: json['id_diskon'] as int?,
      tanggalReservasi: json['tanggal_reservasi'] as String,
      jamMulai: json['jam_mulai'] as String,
      jamSelesai: json['jam_selesai'] as String,
      durasiJam: json['durasi_jam'] as int,
      hargaPerJam: (json['harga_per_jam'] as num).toDouble(),
      totalHargaAwal:
          (json['total_harga_awal'] as num).toDouble(),
      potonganDiskon:
          (json['potongan_diskon'] as num).toDouble(),
      totalBayar: (json['total_bayar'] as num).toDouble(),
      status: json['status'] as String,
    );
  }
}