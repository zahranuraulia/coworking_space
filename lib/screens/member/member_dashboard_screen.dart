import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/space.dart';
import '../../services/space_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/space_card.dart';
import 'booking_screen.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  final SpaceService _spaceService = SpaceService();
  final TextEditingController _searchController = TextEditingController();

  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  List<Space> _allSpaces = [];

  final List<Map<String, String>> _categories = [
    {'label': 'Semua', 'type': ''},
    {'label': 'Personal Desk', 'type': 'desk'},
    {'label': 'Meeting Room', 'type': 'meeting_room'},
    {'label': 'Private Office', 'type': 'private_office'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchSpaces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSpaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final spaces = await _spaceService.getSpaces();
      if (!mounted) return;
      setState(() {
        _allSpaces = spaces;
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
    final selectedType = _categories[_selectedCategoryIndex]['type']!;
    return _allSpaces.where((space) {
      final matchesCategory = selectedType.isEmpty ||
          space.tipe.toLowerCase() == selectedType.toLowerCase();
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          space.namaSpace.toLowerCase().contains(q) ||
          (space.deskripsi?.toLowerCase().contains(q) ?? false) ||
          (space.lokasi?.toLowerCase().contains(q) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredSpaces;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.accentBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LOKASI TERSEDIA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: const [
                              Text(
                                'Malang & Sekitarnya',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.notifications_none_outlined,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Cari ruangan atau fasilitas...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Category Horizontal Chips
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        _categories[index]['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ketersediaan Space',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (!_isLoading && _errorMessage == null)
                    Text(
                      '${filteredList.length} Ditemukan',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Space List View
            Expanded(
              child: _isLoading
                  ? const LoadingWidget(message: 'Memuat katalog space...')
                  : _errorMessage != null
                      ? EmptyStateWidget(
                          icon: Icons.error_outline,
                          title: 'Gagal Memuat Data',
                          message: _errorMessage!,
                          actionLabel: 'Coba Lagi',
                          onAction: _fetchSpaces,
                        )
                      : filteredList.isEmpty
                          ? EmptyStateWidget(
                              icon: Icons.meeting_room_outlined,
                              title: 'Space Tidak Ditemukan',
                              message:
                                  'Tidak ada ruangan yang cocok dengan filter atau kata kunci pencarian Anda.',
                              actionLabel: 'Reset Filter',
                              onAction: () {
                                _searchController.clear();
                                setState(() {
                                  _selectedCategoryIndex = 0;
                                  _searchQuery = '';
                                });
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchSpaces,
                              color: AppColors.primary,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 2, 16, 80),
                                itemCount: filteredList.length,
                                itemBuilder: (context, index) {
                                  final item = filteredList[index];
                                  return SpaceCard(
                                    space: item,
                                    onBook: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BookingScreen(space: item),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
