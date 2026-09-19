class ETicket {
  final String ticketNumber;
  final String bookingCode;
  final String status;
  final String namaMember;
  final String? instansi;
  final String? telpMember;
  final String namaCoworking;
  final String? telpCoworking;
  final String namaSpace;
  final String tipeSpace;
  final double hargaPerJam;
  final String tanggalReservasi;
  final String jamMulai;
  final String jamSelesai;
  final String durasi;
  final double tarifKotor;
  final String? diskonPromo;
  final double potonganDiskon;
  final double totalBayar;
  final String qrCodePayload;

  ETicket({
    required this.ticketNumber,
    required this.bookingCode,
    required this.status,
    required this.namaMember,
    this.instansi,
    this.telpMember,
    required this.namaCoworking,
    this.telpCoworking,
    required this.namaSpace,
    required this.tipeSpace,
    required this.hargaPerJam,
    required this.tanggalReservasi,
    required this.jamMulai,
    required this.jamSelesai,
    required this.durasi,
    required this.tarifKotor,
    this.diskonPromo,
    required this.potonganDiskon,
    required this.totalBayar,
    required this.qrCodePayload,
  });

  factory ETicket.fromJson(Map<String, dynamic> json) {
    final member = (json['member'] is Map<String, dynamic>)
        ? json['member'] as Map<String, dynamic>
        : <String, dynamic>{};

    final coworking = (json['coworking_space'] is Map<String, dynamic>)
        ? json['coworking_space'] as Map<String, dynamic>
        : (json['coworking'] is Map<String, dynamic>
            ? json['coworking'] as Map<String, dynamic>
            : <String, dynamic>{});

    final space = (json['space'] is Map<String, dynamic>)
        ? json['space'] as Map<String, dynamic>
        : <String, dynamic>{};

    final jadwal = (json['jadwal'] is Map<String, dynamic>)
        ? json['jadwal'] as Map<String, dynamic>
        : (json['schedule'] is Map<String, dynamic>
            ? json['schedule'] as Map<String, dynamic>
            : <String, dynamic>{});

    final rincian = (json['rincian_pembayaran'] is Map<String, dynamic>)
        ? json['rincian_pembayaran'] as Map<String, dynamic>
        : (json['rincian'] is Map<String, dynamic>
            ? json['rincian'] as Map<String, dynamic>
            : <String, dynamic>{});

    return ETicket(
      ticketNumber: (json['e_ticket_number'] ?? json['ticket_number'] ?? '-').toString(),
      bookingCode: (json['kode_booking'] ?? json['booking_code'] ?? '-').toString(),
      status: (json['status_reservasi'] ?? json['status'] ?? 'disetujui').toString(),
      namaMember: (member['nama'] ?? member['nama_member'] ?? '-').toString(),
      instansi: member['instansi']?.toString(),
      telpMember: (member['telp'] ?? member['telepon'])?.toString(),
      namaCoworking: (coworking['nama'] ?? coworking['nama_coworking'] ?? 'Coworking Space').toString(),
      telpCoworking: (coworking['telepon'] ?? coworking['telp'])?.toString(),
      namaSpace: (space['nama'] ?? space['nama_space'] ?? 'Space').toString(),
      tipeSpace: (space['tipe'] ?? space['tipe_space'] ?? 'Personal Desk').toString(),
      hargaPerJam: _toDouble(space['harga_per_jam']),
      tanggalReservasi: (jadwal['tanggal'] ?? jadwal['tanggal_reservasi'] ?? '-').toString(),
      jamMulai: (jadwal['jam_mulai'] ?? '-').toString(),
      jamSelesai: (jadwal['jam_selesai'] ?? '-').toString(),
      durasi: (jadwal['durasi'] ?? '${jadwal['durasi_jam'] ?? 1} Jam').toString(),
      tarifKotor: _toDouble(rincian['tarif_kotor'] ?? rincian['subtotal']),
      diskonPromo: rincian['diskon_promo']?.toString(),
      potonganDiskon: _toDouble(rincian['potongan'] ?? rincian['potongan_diskon']),
      totalBayar: _toDouble(rincian['total_dibayar'] ?? rincian['total_bayar']),
      qrCodePayload: (json['qr_code_payload'] ?? json['qr_code_data'] ?? json['kode_booking'] ?? 'TICKET').toString(),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    final digits = val.toString().replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(digits) ?? 0.0;
  }
}
