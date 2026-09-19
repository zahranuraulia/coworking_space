import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/space.dart';
import '../../../services/admin_service.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/stitch_app_bar.dart';
import 'admin_space_form_screen.dart';

class AdminSpaceListScreen extends StatefulWidget {
  const AdminSpaceListScreen({super.key});

  @override
  State<AdminSpaceListScreen> createState() => _AdminSpaceListScreenState();
}

class _AdminSpaceListScreenState extends State<AdminSpaceListScreen> {
  final AdminService _adminService = AdminService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Space> _allSpaces = [];
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua',
    'Personal Desk',
    'Private Office',
    'Meeting Room',
  ];

  @override
  void initState() {
    super.initState();
    _fetchSpaces();
  }

  Future<void> _fetchSpaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _adminService.getSpaces();
      if (!mounted) return;
      setState(() {
        _allSpaces = list;
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

  List<Space> get _filteredSpaces {
    if (_selectedFilter == 'Semua') return _allSpaces;
    return _allSpaces.where((s) {
      final t = s.displayTipe.toLowerCase();
      final sel = _selectedFilter.toLowerCase();
      return t.contains(sel) || s.tipe.toLowerCase().contains(sel);
    }).toList();
  }

  Future<void> _handleDelete(Space space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Space?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: Text(
          'Yakin ingin menghapus unit "${space.namaSpace}"? Data reservasi terkait dapat terpengaruh.',
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
        await _adminService.deleteSpace(space.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Space berhasil dihapus'), backgroundColor: AppColors.success),
        );
        _fetchSpaces();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: StitchAppBar(
        title: 'Kelola Space',
        subtitle: '${_allSpaces.length} Unit Terdaftar',
        actions: [
          // Black Tambah Button matching Stitch
          InkWell(
            onTap: () async {
              final added = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AdminSpaceFormScreen()),
              );
              if (added == true) _fetchSpaces();
            },
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
          onRefresh: _fetchSpaces,
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: SizedBox(
                  height: 32,
                  child: ListView.separated(
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
                            color: isSel ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isSel ? AppColors.primary : AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSel ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Spaces List
              Expanded(
                child: _isLoading
                    ? const LoadingWidget(message: 'Memuat data space...')
                    : _errorMessage != null
                        ? EmptyStateWidget(
                            icon: Icons.error_outline,
                            title: 'Gagal Memuat Space',
                            message: _errorMessage!,
                            actionLabel: 'Coba Lagi',
                            onAction: _fetchSpaces,
                          )
                        : _filteredSpaces.isEmpty
                            ? EmptyStateWidget(
                                icon: Icons.meeting_room_outlined,
                                title: 'Belum Ada Data Space',
                                message: 'Tidak ada ruangan atau meja kerja untuk filter ini.',
                                actionLabel: 'Tambah Space Baru',
                                onAction: () async {
                                  final added = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AdminSpaceFormScreen()),
                                  );
                                  if (added == true) _fetchSpaces();
                                },
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                itemCount: _filteredSpaces.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final s = _filteredSpaces[index];
                                  return _buildSpaceCard(s);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceCard(Space space) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image & Type Tag (Stitch Design)
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 130,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: space.fotoUrl != null && space.fotoUrl!.isNotEmpty
                      ? Image.network(
                          space.fotoUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.work_outline, size: 36, color: AppColors.textMuted),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.work_outline, size: 36, color: AppColors.textMuted),
                        ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    space.displayTipe,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        space.namaSpace,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${CurrencyFormatter.formatRupiah(space.hargaPerJam)} / jam',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Capacity & Status
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.emerald50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.emerald200, width: 0.8),
                      ),
                      child: Text(
                        'Tersedia (${space.kapasitas})',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.emerald700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.people_outline, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '${space.kapasitas} Orang',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (space.deskripsi != null && space.deskripsi!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    space.deskripsi!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 8),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminSpaceFormScreen(space: space),
                          ),
                        );
                        if (updated == true) _fetchSpaces();
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.edit_outlined, size: 14, color: AppColors.textSecondary),
                            SizedBox(width: 4),
                            Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _handleDelete(space),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.delete_outline, size: 14, color: AppColors.rose600),
                            SizedBox(width: 4),
                            Text('Hapus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.rose600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
