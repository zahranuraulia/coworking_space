import 'package:flutter/material.dart';
import 'member_dashboard_screen.dart';

class MemberNavbar extends StatefulWidget {
  const MemberNavbar({super.key});

  @override
  State<MemberNavbar> createState() => _MemberNavbarState();
}

class _MemberNavbarState extends State<MemberNavbar> {
  int _currentIndex = 0;

  // Daftar halaman yang dihubungkan ke tiap tab
  final List<Widget> _pages = [
    const MemberDashboardScreen(), // Tab 0: Beranda
    const Center(child: Text('Halaman Reservasi')), // Tab 1
    const Center(child: Text('Halaman Tiket')),     // Tab 2
    const Center(child: Text('Halaman Akun')),      // Tab 3
  ];

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
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0F172A),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Reservasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'Tiket',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}