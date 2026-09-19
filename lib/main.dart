import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/admin/admin_navbar_screen.dart';
import 'screens/admin/discounts/admin_discount_screen.dart';
import 'screens/admin/members/admin_member_screen.dart';
import 'screens/admin/profile/admin_profile_screen.dart';
import 'screens/admin/reports/admin_revenue_report_screen.dart';
import 'screens/admin/spaces/admin_space_list_screen.dart';
import 'screens/auth/admin_register_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/member_register_screen.dart';
import 'screens/member/member_navbar_screen.dart';
import 'screens/member/my_booking_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coworking Space',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        // Auth Routes
        '/login': (context) => const LoginScreen(),
        '/register-member': (context) => const MemberRegisterScreen(),
        '/register-admin': (context) => const AdminRegisterScreen(),

        // Member Routes
        '/member-dashboard': (context) => const MemberNavbar(),
        '/my-bookings': (context) => const MyBookingScreen(),

        // Admin Routes
        '/admin-dashboard': (context) => const AdminNavbarScreen(),
        '/admin-spaces': (context) => const AdminSpaceListScreen(),
        '/admin-members': (context) => const AdminMemberScreen(),
        '/admin-discounts': (context) => const AdminDiscountScreen(),
        '/admin-reports': (context) => const AdminRevenueReportScreen(),
        '/admin-profile': (context) => const AdminProfileScreen(),
      },
    );
  }
}
