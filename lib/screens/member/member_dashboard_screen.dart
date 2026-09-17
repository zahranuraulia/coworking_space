import 'package:coworkingspace/screens/member/booking_screen.dart';
import 'package:flutter/material.dart';

class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua',
    'Personal Desk',
    'Private Office',
    'Meeting Room',
  ];

  final List<Map<String, dynamic>> _spaces = [
    {
      'id': 1,
      'name': 'Personal Desk',
      'location': 'Coworking Space A - Lantai 2',
      'price': 'Rp 25.000',
      'unit': 'Tersedia 22 Unit',
      'capacity': '1 Orang',
      'badge': 'Populer',
      'badge_color': const Color(0xFF1E293B),
      'image': 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=500',
      'facilities': ['WiFi Cepat', 'Stopkontak', 'Free Coffee'],
    },
    {
      'id': 2,
      'name': 'Private Office',
      'location': 'Coworking Space A - Lantai 3',
      'price': 'Rp 150.000',
      'unit': 'Tersedia 3 Unit',
      'capacity': '4–6 Orang',
      'badge': 'Favorit',
      'badge_color': const Color(0xFFF97316),
      'image': 'https://images.unsplash.com/photo-1497215728101-856f4ea42174?w=500',
      'facilities': ['Privasi Penuh', 'Smart TV', 'AC Dingin'],
    },
    {
      'id': 3,
      'name': 'Meeting Room',
      'location': 'Coworking Space B - Ruang 102',
      'price': 'Rp 100.000',
      'unit': 'Tersedia 5 Unit',
      'capacity': '8–10 Orang',
      'badge': 'Lantai 2',
      'badge_color': const Color(0xFF1E293B),
      'image': 'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=500',
      'facilities': ['Proyektor 4K', 'Whiteboard', 'Audio Conf'],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Logika filter berdasarkan Kategori & Pencarian
  List<Map<String, dynamic>> get _filteredSpaces {
    return _spaces.where((space) {
      final selectedCategory = _categories[_selectedCategoryIndex];
      final matchesCategory = selectedCategory == 'Semua' || space['name'] == selectedCategory;
      final matchesSearch = space['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          space['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredSpaces;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LOKASI KAMU',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: const [
                              Text(
                                'Jakarta Selatan',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_none_outlined,
                          size: 20,
                          color: Color(0xFF0F172A),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF97316),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar & Filter Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: const InputDecoration(
                                hintText: 'Cari space atau lokasi...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Color(0xFF0F172A),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Category Horizontal Scroll List
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ketersediaan Space',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${filteredList.length} Ditemukan',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // List Space Items
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text(
                        'Space tidak ditemukan',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _buildSpaceCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail with Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item['image'],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(
                          Icons.image,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: item['badge_color'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['badge'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Detail Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 12,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['location'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price
                    Row(
                      children: [
                        Text(
                          item['price'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF97316),
                          ),
                        ),
                        const Text(
                          ' /jam',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Chips (Unit & Capacity)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item['unit'].toString().contains('Tersedia 5')
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item['unit'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: item['unit'].toString().contains('Tersedia 5')
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 11,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                item['capacity'],
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Facilities & Book Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (item['facilities'] as List<String>).map((fac) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 4,
                          color: Color(0xFFCBD5E1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          fac,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(spaceData: item),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Pesan Space',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}