import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'admin_dashboard_screen.dart';
import 'discounts/admin_discount_screen.dart';
import 'members/admin_member_screen.dart';
import 'reservations/admin_reservations_screen.dart';
import 'spaces/admin_space_list_screen.dart';

class AdminNavbarScreen extends StatefulWidget {
  final int initialIndex;

  const AdminNavbarScreen({super.key, this.initialIndex = 0});

  @override
  State<AdminNavbarScreen> createState() => _AdminNavbarScreenState();
}

class _AdminNavbarScreenState extends State<AdminNavbarScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    AdminDashboardScreen(), // Tab 0: Dashboard Ringkasan
    AdminReservationsScreen(), // Tab 1: Kelola Reservasi & Tamu
    AdminSpaceListScreen(), // Tab 2: Kelola Ruangan / Space
    AdminDiscountScreen(), // Tab 3: Kelola Diskon & Promo
    AdminMemberScreen(), // Tab 4: Kelola Member
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Color(0x060F172A),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          iconSize: 20,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            height: 1.4,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10, height: 1.4),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Reservasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined),
              activeIcon: Icon(Icons.meeting_room),
              label: 'Space',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Diskon',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Member',
            ),
          ],
        ),
      ),
    );
  }
}
