// Thư viện Material cung cấp TextStyle.
import 'package:flutter/material.dart';

// Import bảng màu để text style bám đúng màu thương hiệu.
import 'app_colors.dart';

// Tập trung các kiểu chữ phổ biến để màn hình và widget dùng nhất quán.
class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle title = TextStyle(
    color: AppColors.textDark,
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.textDark,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.textDark,
    fontSize: 14,
    height: 1.4,
  );

  static const TextStyle muted = TextStyle(
    color: AppColors.textLight,
    fontSize: 14,
    height: 1.4,
  );
}
