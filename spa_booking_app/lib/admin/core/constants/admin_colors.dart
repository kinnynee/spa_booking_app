import 'package:flutter/material.dart';

/// Bảng màu Admin – Lavender Spa (từ DESIGN.md)
class AdminColors {
  AdminColors._();

  // Primary
  static const Color primary = Color(0xFF6A46B2);
  static const Color primaryContainer = Color(0xFF8460CD);
  static const Color onPrimary = Colors.white;

  // Secondary
  static const Color secondary = Color(0xFF684CB0);
  static const Color secondaryContainer = Color(0xFFB195FF);
  static const Color secondaryFixed = Color(0xFFE9DDFF);

  // Background & Surface
  static const Color background = Color(0xFFFAF9FE);
  static const Color surface = Color(0xFFFAF9FE);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F8);
  static const Color surfaceContainer = Color(0xFFEEEDF2);
  static const Color surfaceContainerHigh = Color(0xFFE8E7EC);

  // Text
  static const Color onSurface = Color(0xFF1A1C1F);       // dark text
  static const Color onSurfaceVariant = Color(0xFF4A4452); // medium text
  static const Color outline = Color(0xFF7B7483);           // light text

  // Status colors
  static const Color statusPending = Color(0xFFFF8C00);    // cam - Chờ xác nhận
  static const Color statusConfirmed = Color(0xFF6A46B2);  // tím - Đã xác nhận
  static const Color statusCompleted = Color(0xFF2E7D32);  // xanh lá - Hoàn tất
  static const Color statusCancelled = Color(0xFFBA1A1A);  // đỏ - Đã hủy

  // Soft tones cho status badge background
  static const Color statusPendingBg = Color(0xFFFFF3E0);
  static const Color statusConfirmedBg = Color(0xFFEDE7F6);
  static const Color statusCompletedBg = Color(0xFFE8F5E9);
  static const Color statusCancelledBg = Color(0xFFFFDAD6);

  // Shadow
  static List<BoxShadow> get ambientShadow => [
        const BoxShadow(
          color: Color(0x148E6AD8),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        const BoxShadow(
          color: Color(0x1F8E6AD8),
          blurRadius: 30,
          offset: Offset(0, 8),
        ),
      ];
}
