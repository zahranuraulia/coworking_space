import 'package:flutter/material.dart';

// Import layar-layar aplikasi
import 'screens/auth/login_screen.dart';
import 'screens/auth/member_register_screen.dart'; 
import 'screens/auth/admin_register_screen.dart';  
import 'screens/member/member_navbar_screen.dart'; // Import navbar
import 'screens/admin/admin_dashboard_screen.dart';  

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coworking Space',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0F172A),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      routes: {
        // Auth Routes
        '/login': (context) => const LoginScreen(),
        '/register-member': (context) => const MemberRegisterScreen(),
        '/register-admin': (context) => const AdminRegisterScreen(),

        // Dashboard & Navigation Routes
        '/member-dashboard': (context) => const MemberNavbar(), // Menggunakan MemberNavbar
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}