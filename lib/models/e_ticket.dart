class ETicket {
  final String bookingCode;
  final String status;
  final String statusLabel;
  final String namaMember;
  final String? instansi;
  final String? telpMember;
  final String? alamatMember;
  final String namaCoworking;
  final String? namaPenanggungJawab;
  final String? telpCoworking;
  final String namaSpace;
  final String tipeSpace;
  final String kapasitas;
  final double hargaPerJam;
  final String tanggalReservasi;
  final String jamMulai;
  final int durasiJam;
  final double subtotal;
  final double potonganDiskon;
  final double totalBayar;
  final String qrCodeData;

  ETicket({
    required this.bookingCode,
    required this.status,
    required this.statusLabel,
    required this.namaMember,
    this.instansi,
    this.telpMember,
    this.alamatMember,
    required this.namaCoworking,
    this.namaPenanggungJawab,
    this.telpCoworking,
    required this.namaSpace,
    required this.tipeSpace,
    required this.kapasitas,
    required this.hargaPerJam,
    required this.tanggalReservasi,
    required this.jamMulai,
    required this.durasiJam,
    required this.subtotal,
    required this.potonganDiskon,
    required this.totalBayar,
    required this.qrCodeData,
  });

  factory ETicket.fromJson(Map<String, dynamic> json) {
    return ETicket(
      bookingCode: json['booking_code'] as String,
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      namaMember: json['member']['nama_member'] as String,
      instansi: json['member']['instansi'] as String?,
      telpMember: json['member']['telp'] as String?,
      alamatMember: json['member']['alamat'] as String?,
      namaCoworking: json['coworking']['nama_coworking'] as String,
      namaPenanggungJawab:
          json['coworking']['penanggung_jawab'] as String?,
      telpCoworking: json['coworking']['telp'] as String?,
      namaSpace: json['space']['nama_space'] as String,
      tipeSpace: json['space']['tipe_space'] as String,
      kapasitas: json['space']['kapasitas'] as String,
      hargaPerJam: (json['space']['harga_per_jam'] as num).toDouble(),
      tanggalReservasi: json['schedule']['tanggal_reservasi'] as String,
      jamMulai: json['schedule']['jam_mulai'] as String,
      durasiJam: json['schedule']['durasi_jam'] as int,
      subtotal: (json['rincian']['subtotal'] as num).toDouble(),
      potonganDiskon:
          (json['rincian']['potongan_diskon'] as num).toDouble(),
      totalBayar: (json['rincian']['total_bayar'] as num).toDouble(),
      qrCodeData: json['qr_code_data'] as String,
    );
  }
}