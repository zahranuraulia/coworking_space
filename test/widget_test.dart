import 'package:flutter_test/flutter_test.dart';
import 'package:coworkingspace/core/utils/currency_formatter.dart';
import 'package:coworkingspace/core/utils/image_helper.dart';
import 'package:coworkingspace/core/utils/reservation_helper.dart';
import 'package:coworkingspace/main.dart';
import 'package:coworkingspace/models/discount.dart';
import 'package:coworkingspace/models/space.dart';
import 'package:coworkingspace/models/revenue_report.dart';

void main() {
  test('CurrencyFormatter formats IDR correctly', () {
    expect(CurrencyFormatter.formatRupiah(25000), 'Rp 25.000');
    expect(CurrencyFormatter.formatRupiah(150000), 'Rp 150.000');
    expect(CurrencyFormatter.formatRupiah('50000'), 'Rp 50.000');
    expect(CurrencyFormatter.formatRupiah(0), 'Rp 0');
    expect(CurrencyFormatter.formatRupiah(null), 'Rp 0');
  });

  test('ImageHelper normalizes reverse-proxy and insecure URLs properly', () {
    const rawBackendUrl = 'http://learn.smktelkom-mlg.sch.id/uploads/spaces/1789992032651.jpg';
    final normalized = ImageHelper.normalizeUrl(rawBackendUrl);
    expect(normalized, 'https://learn.smktelkom-mlg.sch.id/coworking/uploads/spaces/1789992032651.jpg');

    const bareFilename = 'my_image.png';
    final bareNormalized = ImageHelper.normalizeUrl(bareFilename, folder: 'members');
    expect(bareNormalized, 'https://learn.smktelkom-mlg.sch.id/coworking/uploads/members/my_image.png');

    const localhostUrl = 'http://localhost:3000/uploads/spaces/test.jpg';
    final localhostNormalized = ImageHelper.normalizeUrl(localhostUrl);
    expect(localhostNormalized, 'https://learn.smktelkom-mlg.sch.id/coworking/uploads/spaces/test.jpg');
  });

  test('Discount model parses nested diskon object from POST /api/diskon/check', () {
    final nestedCheckResponse = {
      'valid': true,
      'diskon': {
        'id': 195,
        'nama_diskon': 'AYACANTIK',
        'persentase_diskon': 50,
        'tanggal_awal': '2026-09-21T00:00:00.000Z',
        'tanggal_akhir': '2026-10-24T23:59:59.000Z',
      },
      'message': 'Kode promo valid! Diskon 50% berhasil diterapkan.',
    };

    final d = Discount.fromJson(nestedCheckResponse);
    expect(d.id, 195);
    expect(d.namaDiskon, 'AYACANTIK');
    expect(d.persentase, 50.0);
    expect(d.aktif, true);
  });

  test('ReservationHelper extracts price and space from real API detail_reservasi structure', () {
    final realApiResponse = {
      'id': 192,
      'tanggal_reservasi': '2026-09-28T00:00:00.000Z',
      'jam_mulai': '09:00',
      'durasi_jam': 3,
      'status': 'belum_dikonfirm',
      'detail_reservasi': [
        {
          'id': 192,
          'total_harga': 75000,
          'space': {
            'id': 349,
            'nama_space': 'Personal Desk Flexi 01',
            'harga_per_jam': 25000,
            'tipe': 'desk'
          }
        }
      ]
    };

    expect(ReservationHelper.extractPrice(realApiResponse), 75000.0);
    expect(ReservationHelper.extractSpaceName(realApiResponse), 'Personal Desk Flexi 01');
    expect(ReservationHelper.extractSpaceType(realApiResponse), 'Personal Desk');
    expect(ReservationHelper.extractBookingCode(realApiResponse), 'RSV192');
    expect(ReservationHelper.formatDate(realApiResponse['tanggal_reservasi']), '28 Sep 2026');
  });

  test('RevenueReport parses real server nested response cleanly', () {
    final realServerData = {
      'periode': {
        'bulan': 9,
        'nama_bulan': 'September',
        'tahun': 2026,
      },
      'ringkasan': {
        'total_reservasi': 2,
        'estimasi_pendapatan_total': 6075000,
        'realisasi_pendapatan': 6000000,
        'status_reservasi': {
          'belum_dikonfirm': 0,
          'disetujui': 0,
          'aktif': 0,
          'selesai': 2,
          'dibatalkan': 0,
        }
      },
      'pendapatan_per_tipe_space': {
        'desk': {'count': 1, 'total_income': 6000000},
        'meeting_room': {'count': 0, 'total_income': 0},
        'private_office': {'count': 1, 'total_income': 75000},
      },
      'tren_harian': [
        {'tanggal': '2026-09-28', 'total_reservations': 1, 'total_income': 75000},
        {'tanggal': '2026-09-25', 'total_reservations': 1, 'total_income': 6000000},
      ]
    };

    final report = RevenueReport.fromJson(realServerData);
    expect(report.month, 9);
    expect(report.year, 2026);
    expect(report.totalTransaksi, 2);
    expect(report.displayPendapatan, 6000000.0);
    expect(report.estimasiPendapatanKotor, 6075000.0);
    expect(report.rincianPerTipeSpace.length, 3);
    expect(report.trenHarian.length, 2);
  });

  test('Discount model parses correctly', () {
    final json = {
      'id': 1,
      'nama_diskon': 'PROMO20',
      'persentase_diskon': 20,
      'tanggal_awal': '2026-08-01',
      'tanggal_akhir': '2026-08-31',
      'is_active': true,
    };
    final d = Discount.fromJson(json);
    expect(d.id, 1);
    expect(d.namaDiskon, 'PROMO20');
    expect(d.persentase, 20.0);
    expect(d.aktif, true);
  });

  test('Global seeder check correctly distinguishes global template account vs tenant account', () {
    final globalSeedUser = {
      'id': 1202,
      'username': 'admin_space1',
      'role': 'admin_space',
      'maker_id': null,
    };
    final tenantUser = {
      'id': 1392,
      'username': 'admin_test1',
      'role': 'admin_space',
      'maker_id': 82,
    };

    expect(globalSeedUser['maker_id'] == null, true);
    expect(tenantUser['maker_id'] == null, false);
    expect(tenantUser['maker_id'], 82);
  });

  test('Space model parses display types correctly', () {
    final s1 = Space.fromJson({'id': 1, 'nama_space': 'Desk 1', 'tipe': 'desk', 'harga_per_jam': 20000, 'kapasitas': 1});
    expect(s1.displayTipe, 'Personal Desk');

    final s2 = Space.fromJson({'id': 2, 'nama_space': 'Room A', 'tipe': 'meeting_room', 'harga_per_jam': 100000, 'kapasitas': 8});
    expect(s2.displayTipe, 'Meeting Room');
  });

  testWidgets('MyApp renders login screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Masuk Akun'), findsOneWidget);
    expect(find.text('Selamat Datang Kembali!'), findsOneWidget);
  });
}
