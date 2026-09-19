import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Stitch NexusSpace)
  static const Color primary = Color(0xFF0F172A); // Midnight Navy (slate-900)
  static const Color primaryLight = Color(0xFF1E293B); // slate-800
  static const Color secondary = Color(0xFFF97316); // Vivid Tangerine
  static const Color tertiary = Color(0xFF1E3A8A); // Deep Blue
  static const Color accentBlue = Color(0xFF2563EB); // Royal Blue

  // Neutrals & Canvas Surfaces (Stitch Palette)
  static const Color canvas = Color(0xFFF8FAFC); // slate-50 background
  static const Color surface = Color(0xFFFFFFFF); // pure white
  static const Color border = Color(0xFFE2E8F0); // slate-200 border
  static const Color borderLight = Color(0xFFF1F5F9); // slate-100 border
  static const Color divider = Color(0xFFF1F5F9);

  // Slate System
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Semantic Status (Emerald - Approved)
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald700 = Color(0xFF047857);

  // Semantic Status (Blue - Active)
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);

  // Semantic Status (Amber - Pending)
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber700 = Color(0xFFB45309);

  // Semantic Status (Rose - Cancelled / Error)
  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose100 = Color(0xFFFEE2E2);
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose600 = Color(0xFFE11D48);
  static const Color rose700 = Color(0xFFBE123C);

  // Compatibility aliases
  static const Color statusPendingText = amber700;
  static const Color statusPendingBg = amber50;
  static const Color statusApprovedText = emerald700;
  static const Color statusApprovedBg = emerald50;
  static const Color statusActiveText = blue700;
  static const Color statusActiveBg = blue50;
  static const Color statusCompletedText = slate700;
  static const Color statusCompletedBg = slate100;
  static const Color statusCancelledText = rose700;
  static const Color statusCancelledBg = rose50;

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
}
