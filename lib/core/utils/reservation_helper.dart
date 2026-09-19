import 'package:intl/intl.dart';

class ReservationHelper {
  static double extractPrice(Map<String, dynamic> item) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      final digits = v.toString().replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(digits) ?? 0.0;
    }

    // 1. Check direct total_bayar
    if (item['total_bayar'] != null) {
      final val = toDouble(item['total_bayar']);
      if (val > 0) return val;
    }

    // 2. Check direct total_harga
    if (item['total_harga'] != null) {
      final val = toDouble(item['total_harga']);
      if (val > 0) return val;
    }

    // 3. Check price_breakdown
    if (item['price_breakdown'] is Map<String, dynamic>) {
      final pb = item['price_breakdown'] as Map<String, dynamic>;
      final val = toDouble(pb['total_harga'] ?? pb['subtotal']);
      if (val > 0) return val;
    }

    // 4. Check detail_reservasi list
    if (item['detail_reservasi'] is List && (item['detail_reservasi'] as List).isNotEmpty) {
      final firstDetail = (item['detail_reservasi'] as List).first;
      if (firstDetail is Map<String, dynamic>) {
        final val = toDouble(firstDetail['total_harga']);
        if (val > 0) return val;

        // Fallback: space harga_per_jam * durasi
        if (firstDetail['space'] is Map<String, dynamic>) {
          final sp = firstDetail['space'] as Map<String, dynamic>;
          final hourly = toDouble(sp['harga_per_jam']);
          final duration = toDouble(item['durasi_jam'] ?? 1);
          if (hourly > 0) return hourly * (duration > 0 ? duration : 1);
        }
      }
    }

    // 5. Check space in root
    if (item['space'] is Map<String, dynamic>) {
      final sp = item['space'] as Map<String, dynamic>;
      final hourly = toDouble(sp['harga_per_jam']);
      final duration = toDouble(item['durasi_jam'] ?? 1);
      if (hourly > 0) return hourly * (duration > 0 ? duration : 1);
    }

    return 0.0;
  }

  static Map<String, dynamic> extractSpace(Map<String, dynamic> item) {
    if (item['space'] is Map<String, dynamic>) {
      return item['space'] as Map<String, dynamic>;
    }
    if (item['detail_reservasi'] is List && (item['detail_reservasi'] as List).isNotEmpty) {
      final firstDetail = (item['detail_reservasi'] as List).first;
      if (firstDetail is Map<String, dynamic> && firstDetail['space'] is Map<String, dynamic>) {
        return firstDetail['space'] as Map<String, dynamic>;
      }
    }
    return {};
  }

  static String extractSpaceName(Map<String, dynamic> item) {
    if (item['space_name'] != null && item['space_name'].toString().isNotEmpty) {
      return item['space_name'].toString();
    }
    final sp = extractSpace(item);
    if (sp['nama_space'] != null && sp['nama_space'].toString().isNotEmpty) {
      return sp['nama_space'].toString();
    }
    if (sp['nama'] != null && sp['nama'].toString().isNotEmpty) {
      return sp['nama'].toString();
    }
    return 'Ruang Kerja';
  }

  static String extractSpaceType(Map<String, dynamic> item) {
    final sp = extractSpace(item);
    final tipe = (sp['tipe'] ?? sp['tipe_space'] ?? item['tipe'] ?? '').toString().toLowerCase();
    switch (tipe) {
      case 'desk':
        return 'Personal Desk';
      case 'meeting_room':
        return 'Meeting Room';
      case 'private_office':
        return 'Private Office';
      default:
        return tipe.isNotEmpty ? tipe : 'Personal Desk';
    }
  }

  static String extractBookingCode(Map<String, dynamic> item) {
    if (item['kode_booking'] != null && item['kode_booking'].toString().isNotEmpty) {
      return item['kode_booking'].toString();
    }
    if (item['booking_code'] != null && item['booking_code'].toString().isNotEmpty) {
      return item['booking_code'].toString();
    }
    if (item['id'] != null) {
      return 'RSV${item['id']}';
    }
    return '-';
  }

  static String formatDate(dynamic rawDate) {
    if (rawDate == null) return '-';
    final str = rawDate.toString().trim();
    if (str.isEmpty || str == '-') return '-';

    try {
      final dt = DateTime.parse(str).toLocal();
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      // If it contains "T", strip the time part
      if (str.contains('T')) {
        return str.split('T').first;
      }
      return str;
    }
  }
}
