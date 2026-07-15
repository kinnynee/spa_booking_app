// Thư viện Material cung cấp Color và BoxShadow cho hệ màu giao diện.
import 'package:flutter/material.dart';

// Bảng màu dùng thống nhất trên toàn bộ ứng dụng.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF8E6AD8);
  static const Color secondary = Color(0xFFD8C8FF);
  static const Color background = Color(0xFFF8F4FF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D2438);
  static const Color textLight = Color(0xFF8A7A99);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFE53935);
  static const Color border = Color(0xFFE9DFFC);
  static const Color input = Color(0xFFF1EBFA);
}

// Các cấu hình shadow dùng lại cho card, banner và panel.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x178E6AD8), blurRadius: 20, offset: Offset(0, 10)),
  ];
}
