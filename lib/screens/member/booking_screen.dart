import 'package:flutter/material.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/discount.dart';
import '../../models/space.dart';
import '../../services/discount_service.dart';
import '../../services/reservation_service.dart';
import '../../services/space_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/stitch_app_bar.dart';

class BookingScreen extends StatefulWidget {
  final Space? space;
  final Map<String, dynamic>? spaceData;

  const BookingScreen({
    super.key,
    this.space,
    this.spaceData,
  }) : assert(space != null || spaceData != null, 'Space or spaceData must be provided');

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final Space _space;
  final ReservationService _reservationService = ReservationService();
  final DiscountService _discountService = DiscountService();
  final SpaceService _spaceService = SpaceService();

  final TextEditingController _promoController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _durationHours = 2;
  bool _isLoading = false;
  bool _isCheckingPromo = false;

  bool _isCheckingAvailability = false;
  bool _isSlotAvailable = true;
  String? _availabilityStatusText;
  List<Map<String, dynamic>> _bookedSlotsForSelectedDate = [];
  int _availabilityRequestId = 0;

  List<Discount> _activeDiscounts = [];
  Discount? _appliedDiscount;
  String? _promoFeedback;
  String? _verifiedPromoCode;
  int _promoRequestId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.space != null) {
      _space = widget.space!;
    } else {
      _space = Space.fromJson(widget.spaceData!);
    }

    final now = DateTime.now();
    if (now.hour >= 9 && now.hour < 21) {
      _selectedTime = TimeOfDay(hour: now.hour + 1, minute: 0);
    }

    _promoController.addListener(_onPromoEdited);
    _loadActiveDiscounts();
    _checkAvailabilityRealtime();
  }

  @override
  void dispose() {
    _promoController.removeListener(_onPromoEdited);
    _promoController.dispose();
    super.dispose();
  }

  String _promoText = '';

  void _onPromoEdited() {
    final text = _promoController.text;
    if (text == _promoText) return;
    _promoText = text;
    setState(() {
      _promoRequestId++;
      _appliedDiscount = null;
      _verifiedPromoCode = null;
      _promoFeedback = null;
      _isCheckingPromo = false;
    });
  }

  Future<void> _loadActiveDiscounts() async {
    try {
      final list = await _discountService.getActiveDiscounts();
      if (!mounted) return;
      setState(() => _activeDiscounts = list);
    } catch (_) {}
  }

  double get _subtotal => _space.hargaPerJam * _durationHours;
  double get _discountAmount {
    if (_appliedDiscount == null) return 0.0;
    return _subtotal * (_appliedDiscount!.persentase / 100.0);
  }
  double get _totalPrice => (_subtotal - _discountAmount).clamp(0.0, double.infinity);

  Future<void> _applyPromoCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    final requestId = ++_promoRequestId;

    if (cleanCode.isEmpty) {
      setState(() {
        _appliedDiscount = null;
        _verifiedPromoCode = null;
        _promoFeedback = null;
        _isCheckingPromo = false;
      });
      return;
    }

    setState(() => _isCheckingPromo = true);
    try {
      final discount = await _discountService.checkDiscount(cleanCode);
      if (!mounted || requestId != _promoRequestId) return;
      setState(() {
        _appliedDiscount = discount;
        _verifiedPromoCode = discount.namaDiskon.toUpperCase();
        _promoText = discount.namaDiskon;
        _promoController.text = discount.namaDiskon;
        _promoFeedback = 'Diskon ${discount.persentase.toInt()}% berhasil diterapkan!';
        _isCheckingPromo = false;
      });
    } on ApiException catch (e) {
      if (!mounted || requestId != _promoRequestId) return;
      setState(() {
        _appliedDiscount = null;
        _verifiedPromoCode = null;
        _promoFeedback = e.message;
        _isCheckingPromo = false;
      });
    } catch (e) {
      if (!mounted || requestId != _promoRequestId) return;
      setState(() {
        _appliedDiscount = null;
        _verifiedPromoCode = null;
        _promoFeedback = 'Kode promo tidak valid atau telah kedaluwarsa';
        _isCheckingPromo = false;
      });
    }
  }

  Future<void> _checkAvailabilityRealtime() async {
    final requestId = ++_availabilityRequestId;
    setState(() => _isCheckingAvailability = true);

    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final startMinutes = _selectedTime.hour * 60 + _selectedTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    final formattedDate =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    final formattedTime =
        "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

    if (isToday && startMinutes <= nowMinutes) {
      if (!mounted || requestId != _availabilityRequestId) return;
      setState(() {
        _isSlotAvailable = false;
        _availabilityStatusText = 'Jam mulai sudah lewat untuk hari ini. Silakan pilih jam mendatang.';
        _isCheckingAvailability = false;
      });
      return;
    }

    try {
      final daySchedule = await _spaceService.checkAvailability(
        idSpace: _space.id,
        tanggal: formattedDate,
      );

      final List<Map<String, dynamic>> bookedSlots = [];
      final details = (daySchedule['detail_reservasi'] as List<dynamic>?) ?? [];
      for (final d in details) {
        if (d is Map<String, dynamic> && d['reservasi'] is Map<String, dynamic>) {
          final r = d['reservasi'] as Map<String, dynamic>;
          final status = (r['status'] ?? '').toString();
          if (status != 'dibatalkan') {
            final rawTgl = (r['tanggal_reservasi'] ?? '').toString();
            if (rawTgl.startsWith(formattedDate)) {
              final jam = (r['jam_mulai'] ?? '').toString();
              final dur = r['durasi_jam'] is int
                  ? r['durasi_jam'] as int
                  : int.tryParse(r['durasi_jam']?.toString() ?? '1') ?? 1;
              final startHour = int.tryParse(jam.split(':').first) ?? 0;
              final endHour = startHour + dur;
              final endStr = "${endHour.toString().padLeft(2, '0')}:00";
              bookedSlots.add({
                'jam_mulai': jam,
                'jam_selesai': endStr,
                'durasi': dur,
              });
            }
          }
        }
      }

      final slotResult = await _spaceService.checkAvailability(
        idSpace: _space.id,
        tanggal: formattedDate,
        jamMulai: formattedTime,
        durasiJam: _durationHours,
      );

      if (!mounted || requestId != _availabilityRequestId) return;

      final bool isAvail = slotResult['is_available'] == true || slotResult['available'] == true;
      final conflicts = (slotResult['conflicts'] as List<dynamic>?) ?? [];

      final endMinutes = startMinutes + (_durationHours * 60);
      final endHourStr =
          "${(endMinutes ~/ 60).toString().padLeft(2, '0')}:${(endMinutes % 60).toString().padLeft(2, '0')}";

      if (!isAvail || conflicts.isNotEmpty) {
        String conflictInfo = 'Jam $formattedTime - $endHourStr sudah dibooking oleh orang lain.';
        if (conflicts.isNotEmpty && conflicts.first is Map<String, dynamic>) {
          final c = conflicts.first as Map<String, dynamic>;
          final cJam = c['jam_mulai']?.toString() ?? formattedTime;
          final cDur = c['durasi_jam'] ?? _durationHours;
          conflictInfo = 'Jam $cJam ($cDur Jam) sudah dibooking oleh orang lain.';
        }

        setState(() {
          _isSlotAvailable = false;
          _availabilityStatusText = '$conflictInfo Silakan pilih jam atau tanggal lain.';
          _bookedSlotsForSelectedDate = bookedSlots;
          _isCheckingAvailability = false;
        });
      } else {
        setState(() {
          _isSlotAvailable = true;
          _availabilityStatusText =
              'Jam $formattedTime - $endHourStr ($_durationHours Jam) tersedia untuk dipesan.';
          _bookedSlotsForSelectedDate = bookedSlots;
          _isCheckingAvailability = false;
        });
      }
    } catch (_) {
      if (!mounted || requestId != _availabilityRequestId) return;
      setState(() {
        _isCheckingAvailability = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _checkAvailabilityRealtime();
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
      _checkAvailabilityRealtime();
    }
  }

  Future<void> _handleBooking() async {
    if (_isLoading || _isCheckingPromo) return;

    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (isToday) {
      final startMinutes = _selectedTime.hour * 60 + _selectedTime.minute;
      final nowMinutes = now.hour * 60 + now.minute;
      if (startMinutes <= nowMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jam mulai tidak boleh di waktu yang sudah lewat.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (_space.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Space tidak valid. Silakan pilih kembali space.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_isSlotAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_availabilityStatusText ?? 'Jadwal jam ini sudah dibooking. Silakan pilih jam lain.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formattedDate =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final formattedTime =
          "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}";

      // Verify availability
      try {
        final avail = await _spaceService.checkAvailability(
          idSpace: _space.id,
          tanggal: formattedDate,
          jamMulai: formattedTime,
          durasiJam: _durationHours,
        );
        if (avail['available'] == false || avail['is_available'] == false) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Jadwal bentrok. Ruangan sudah dipesan pada jam tersebut.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      } catch (_) {
        // If availability check fails or backend has mock rule, proceed
      }

      // Sync promo code if user typed something but hasn't pressed Terapkan
      final typedCode = _promoController.text.trim().toUpperCase();
      if (typedCode.isNotEmpty) {
        if (_appliedDiscount == null || _verifiedPromoCode != typedCode) {
          try {
            final d = await _discountService.checkDiscount(typedCode);
            _appliedDiscount = d;
            _verifiedPromoCode = d.namaDiskon.toUpperCase();
          } catch (e) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            final message = e is ApiException
                ? e.message
                : 'Kode promo "$typedCode" tidak valid atau telah kedaluwarsa.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
        }
      } else {
        _appliedDiscount = null;
        _verifiedPromoCode = null;
      }

      final verifiedDiscount = (_appliedDiscount != null &&
              _verifiedPromoCode != null &&
              _appliedDiscount!.namaDiskon.toUpperCase() == _verifiedPromoCode)
          ? _appliedDiscount
          : null;

      await _reservationService.createReservation(
        idSpace: _space.id,
        tanggalReservasi: formattedDate,
        jamMulai: formattedTime,
        durasiJam: _durationHours,
        idDiskon: verifiedDiscount?.id,
        kodePromo: verifiedDiscount?.namaDiskon,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservasi berhasil dibuat! Silakan tunggu konfirmasi admin.'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat reservasi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const StitchAppBar(
        title: 'Reservasi Space',
        subtitle: 'Pilih Jadwal & Konfirmasi',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Space Summary Card (Stitch Design)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 0.9),
                        boxShadow: const [
                          BoxShadow(color: Color(0x040F172A), blurRadius: 6, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 70,
                              height: 70,
                              color: const Color(0xFFEFF6FF),
                              child: _space.fotoUrl != null && _space.fotoUrl!.isNotEmpty
                                  ? Image.network(
                                      _space.fotoUrl!,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => const Icon(
                                        Icons.work_outline,
                                        color: AppColors.accentBlue,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.work_outline,
                                      color: AppColors.accentBlue,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _space.namaSpace,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _space.lokasi ?? _space.displayTipe,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${CurrencyFormatter.formatRupiah(_space.hargaPerJam)} / jam',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pilih Tanggal
                    const Text(
                      'Pilih Tanggal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 0.9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_outlined,
                              color: AppColors.accentBlue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_bookedSlotsForSelectedDate.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.schedule, size: 14, color: Color(0xFFD97706)),
                                SizedBox(width: 6),
                                Text(
                                  'Jadwal yang sudah terisi pada tanggal ini:',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: _bookedSlotsForSelectedDate.map((slot) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.rose50,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: AppColors.rose200, width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(color: AppColors.rose600, shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${slot['jam_mulai']} - ${slot['jam_selesai']} (${slot['durasi']} Jam)',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.rose700),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Jam Mulai & Durasi
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jam Mulai',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _selectTime(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_isSlotAvailable ? const Color(0xFFFFF1F2) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: !_isSlotAvailable ? AppColors.rose500 : AppColors.border,
                                      width: !_isSlotAvailable ? 1.2 : 0.9,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedTime.format(context),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: !_isSlotAvailable ? AppColors.rose700 : AppColors.textPrimary,
                                        ),
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        color: !_isSlotAvailable ? AppColors.rose600 : AppColors.accentBlue,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Durasi (Jam)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border, width: 0.9),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18),
                                      onPressed: _durationHours > 1
                                          ? () {
                                              setState(() => _durationHours--);
                                              _checkAvailabilityRealtime();
                                            }
                                          : null,
                                    ),
                                    Text(
                                      '$_durationHours Jam',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: _durationHours < 24
                                          ? () {
                                              setState(() => _durationHours++);
                                              _checkAvailabilityRealtime();
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Proactive Live Availability Status Banner (Stitch Design)
                    if (_isCheckingAvailability)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border, width: 0.8),
                        ),
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Memeriksa ketersediaan jam...',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    else if (!_isSlotAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.rose50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.rose200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.cancel_outlined, size: 16, color: AppColors.rose600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _availabilityStatusText ??
                                    'Jam tersebut sudah dibooking oleh orang lain. Silakan pilih jam lain.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.rose700,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.emerald50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.emerald200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: AppColors.emerald700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _availabilityStatusText ?? 'Jam tersedia untuk dipesan.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.emerald700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 18),

                    // Pilih Diskon Dropdown & Manual Input (Stitch Wireframe 4)
                    const Text(
                      'Pilih Diskon (Opsional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_activeDiscounts.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            isExpanded: true,
                            hint: const Text('Pilih voucher diskon aktif...', style: TextStyle(fontSize: 13)),
                            value: _appliedDiscount?.id,
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Tanpa Diskon', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ),
                              ..._activeDiscounts.map((d) {
                                return DropdownMenuItem<int?>(
                                  value: d.id,
                                  child: Text(
                                    '${d.namaDiskon} - ${d.persentase.toInt()}%',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                );
                              }),
                            ],
                            onChanged: (selectedId) {
                              setState(() {
                                _promoRequestId++;
                                _isCheckingPromo = false;
                                if (selectedId != null) {
                                  final match = _activeDiscounts.cast<Discount?>().firstWhere(
                                        (d) => d?.id == selectedId,
                                        orElse: () => null,
                                      );
                                  _appliedDiscount = match;
                                  _verifiedPromoCode = match?.namaDiskon.toUpperCase();
                                  _promoText = match?.namaDiskon ?? '';
                                  _promoController.text = match?.namaDiskon ?? '';
                                  _promoFeedback = match != null
                                      ? 'Diskon ${match.persentase.toInt()}% berhasil dipilih'
                                      : null;
                                } else {
                                  _appliedDiscount = null;
                                  _verifiedPromoCode = null;
                                  _promoText = '';
                                  _promoController.clear();
                                  _promoFeedback = null;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Manual Promo Code Input with "Terapkan" Button
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: TextField(
                              controller: _promoController,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(
                                hintText: 'Ketik kode kupon (opsional)',
                                prefixIcon: Icon(Icons.confirmation_number_outlined, size: 20),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(88, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _isCheckingPromo ? null : () => _applyPromoCode(_promoController.text),
                          child: _isCheckingPromo
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Terapkan', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    if (_promoFeedback != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _promoFeedback!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _appliedDiscount != null ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Rincian Pembayaran Card (Stitch Wireframe 4)
                    const Text(
                      'Rincian Pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 0.9),
                        boxShadow: const [
                          BoxShadow(color: Color(0x040F172A), blurRadius: 6, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal ($_durationHours jam)',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              Text(
                                CurrencyFormatter.formatRupiah(_subtotal),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          if (_appliedDiscount != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Diskon ${_appliedDiscount!.persentase.toInt()}% (${_appliedDiscount!.namaDiskon})',
                                  style: const TextStyle(color: AppColors.success, fontSize: 13),
                                ),
                                Text(
                                  '- ${CurrencyFormatter.formatRupiah(_discountAmount)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Biaya Layanan & Fasilitas',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                              Text(
                                'Gratis',
                                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Bayar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatRupiah(_totalPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Confirmation Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: AppButton(
                text: !_isSlotAvailable
                    ? 'Jam Sudah Terisi (Pilih Jam Lain)'
                    : 'Konfirmasi Reservasi',
                isLoading: _isLoading,
                onPressed: (_isLoading || _isCheckingPromo || _isCheckingAvailability || !_isSlotAvailable)
                    ? null
                    : _handleBooking,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
