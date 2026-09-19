import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/discount.dart';
import '../../../services/discount_service.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/dashed_divider.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/status_badge.dart';
import '../../../widgets/stitch_app_bar.dart';

class AdminDiscountScreen extends StatefulWidget {
  const AdminDiscountScreen({super.key});

  @override
  State<AdminDiscountScreen> createState() => _AdminDiscountScreenState();
}

class _AdminDiscountScreenState extends State<AdminDiscountScreen> {
  final DiscountService _discountService = DiscountService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<Discount> _allDiscounts = [];
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'Aktif', 'Segera Berakhir', 'Nonaktif'];

  @override
  void initState() {
    super.initState();
    _fetchDiscounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDiscounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _discountService.getAdminDiscounts();
      if (!mounted) return;
      setState(() {
        _allDiscounts = list;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Discount> get _filteredDiscounts {
    final query = _searchController.text.trim().toLowerCase();
    return _allDiscounts.where((d) {
      if (query.isNotEmpty && !d.namaDiskon.toLowerCase().contains(query)) {
        return false;
      }
      if (_selectedFilter == 'Aktif') return d.aktif;
      if (_selectedFilter == 'Nonaktif') return !d.aktif;
      return true;
    }).toList();
  }

  Future<void> _showDiscountDialog({Discount? discount}) async {
    final isEdit = discount != null;
    final formKey = GlobalKey<FormState>();

    final kodeCtrl = TextEditingController(text: discount?.namaDiskon ?? '');
    final persenCtrl = TextEditingController(
      text: discount != null ? discount.persentase.toInt().toString() : '',
    );

    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    if (discount != null) {
      try {
        startDate = DateTime.parse(discount.tanggalAwal);
        endDate = DateTime.parse(discount.tanggalAkhir);
      } catch (_) {}
    }

    bool isSaving = false;
    final dateFormat = DateFormat('yyyy-MM-dd');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEdit ? 'Edit Kode Promo' : 'Tambah Promo Baru',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      AppTextField(
                        label: 'Kode Promo Diskon *',
                        hintText: 'Contoh: WEEKEND20',
                        controller: kodeCtrl,
                        prefixIcon: Icons.confirmation_number_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Kode promo wajib diisi' : null,
                      ),
                      const SizedBox(height: 10),

                      AppTextField(
                        label: 'Persentase Diskon (1 - 100%) *',
                        hintText: 'Contoh: 20',
                        controller: persenCtrl,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.percent_outlined,
                        validator: (v) {
                          final num = double.tryParse(v?.trim() ?? '');
                          if (num == null || num <= 0 || num > 100) {
                            return 'Persentase harus antara 1 sampai 100';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Tanggal Awal & Akhir
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Awal',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: modalCtx,
                                      initialDate: startDate,
                                      firstDate: DateTime(2025),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setModalState(() => startDate = picked);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(dateFormat.format(startDate), style: const TextStyle(fontSize: 11)),
                                        const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Akhir',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: modalCtx,
                                      initialDate: endDate,
                                      firstDate: startDate,
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setModalState(() => endDate = picked);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(dateFormat.format(endDate), style: const TextStyle(fontSize: 11)),
                                        const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      AppButton(
                        text: isEdit ? 'SIMPAN PERUBAHAN' : 'BUAT KODE PROMO',
                        isLoading: isSaving,
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setModalState(() => isSaving = true);

                                final formattedStart = '${dateFormat.format(startDate)}T00:00:00.000Z';
                                final formattedEnd = '${dateFormat.format(endDate)}T23:59:59.000Z';
                                final p = double.parse(persenCtrl.text.trim());

                                try {
                                  if (!isEdit) {
                                    await _discountService.createDiscount(
                                      namaDiskon: kodeCtrl.text.trim().toUpperCase(),
                                      persentaseDiskon: p,
                                      tanggalAwal: formattedStart,
                                      tanggalAkhir: formattedEnd,
                                    );
                                  } else {
                                    await _discountService.updateDiscount(
                                      discount.id,
                                      namaDiskon: kodeCtrl.text.trim().toUpperCase(),
                                      persentaseDiskon: p,
                                      tanggalAwal: formattedStart,
                                      tanggalAkhir: formattedEnd,
                                    );
                                  }

                                  if (!modalCtx.mounted) return;
                                  Navigator.pop(modalCtx);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        !isEdit ? 'Promo berhasil dibuat' : 'Promo berhasil diperbarui',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  _fetchDiscounts();
                                } catch (e) {
                                  setModalState(() => isSaving = false);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.error),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleDelete(Discount discount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Promo?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Text(
          'Hapus kode voucher "${discount.namaDiskon}"? Pengguna tidak dapat lagi menggunakan kode ini saat checkout.',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _discountService.deleteDiscount(discount.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode promo berhasil dihapus'), backgroundColor: AppColors.success),
        );
        _fetchDiscounts();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _formatDate(String isoString) {
    try {
      final d = DateTime.parse(isoString);
      return '${d.day} ${_monthName(d.month)} ${d.year}';
    } catch (_) {
      return isoString;
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: StitchAppBar(
        title: 'Kelola Diskon & Promo',
        subtitle: 'B.6 Admin Pengelola Space',
        actions: [
          // Black "+ Tambah" button matching Stitch Screen 6 TopBar
          InkWell(
            onTap: () => _showDiscountDialog(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Tambah', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchDiscounts,
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Cari kupon promo...',
                      hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 14),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
              ),

              // Filter Tabs
              SizedBox(
                height: 32,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) {
                    final f = _filters[idx];
                    final isSel = _selectedFilter == f;
                    return InkWell(
                      onTap: () => setState(() => _selectedFilter = f),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Info Row: Menampilkan X kode promo + Urutkan (Stitch Screen 6 Exact)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menampilkan ${_filteredDiscounts.length} kode promo',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.tune, size: 12, color: AppColors.blue600),
                        SizedBox(width: 3),
                        Text(
                          'Urutkan',
                          style: TextStyle(fontSize: 11, color: AppColors.blue600, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Discounts List
              Expanded(
                child: _isLoading
                    ? const LoadingWidget(message: 'Memuat data promo...')
                    : _errorMessage != null
                        ? EmptyStateWidget(
                            icon: Icons.error_outline,
                            title: 'Gagal Memuat Promo',
                            message: _errorMessage!,
                            actionLabel: 'Coba Lagi',
                            onAction: _fetchDiscounts,
                          )
                        : _filteredDiscounts.isEmpty
                            ? EmptyStateWidget(
                                icon: Icons.confirmation_number_outlined,
                                title: 'Belum Ada Promo',
                                message: 'Tidak ada kode promo yang cocok.',
                                actionLabel: 'Buat Promo Baru',
                                onAction: () => _showDiscountDialog(),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                itemCount: _filteredDiscounts.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final d = _filteredDiscounts[index];
                                  return _buildCouponCard(d);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponCard(Discount discount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Coupon Badge + Copy Button + Status Badge (Stitch Screen 6 Exact)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.blue200, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.confirmation_number_outlined, size: 12, color: AppColors.blue600),
                          const SizedBox(width: 4),
                          Text(
                            discount.namaDiskon,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: discount.namaDiskon));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Kode promo "${discount.namaDiskon}" disalin!'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.copy, size: 14, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
                StatusBadge(status: discount.aktif ? 'aktif' : 'dibatalkan'),
              ],
            ),
            const SizedBox(height: 10),

            // Diskon percentage & Subtitle (Stitch Screen 6 Exact)
            Text(
              'Diskon ${discount.persentase.toInt()}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: const [
                Icon(Icons.shopping_bag_outlined, size: 12, color: AppColors.textMuted),
                SizedBox(width: 4),
                Text(
                  'Min. Transaksi: Rp 50.000',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Dashed Line Divider (Stitch Screen 6 Exact)
            const DashedDivider(height: 1, color: Color(0xFFE2E8F0)),

            const SizedBox(height: 10),

            // Footer Row: Period & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDate(discount.tanggalAwal)} - ${_formatDate(discount.tanggalAkhir)}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _showDiscountDialog(discount: discount),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _handleDelete(discount),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: const Icon(Icons.delete_outline, size: 16, color: AppColors.rose600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
