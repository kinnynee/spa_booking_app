import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';

/// TODO – KIÊN: Màn hình Tổng quan (Dashboard)
///
/// Dựa theo file thiết kế: stitch_zen_luxury_spa_booking_app/t_ng_quan_admin/screen.png
///
/// Các thành phần cần làm:
///   1. Header: avatar admin + tên + icon chuông
///   2. Grid 2x2: stat card (Lịch hẹn hôm nay, Doanh thu, Khách mới, Dịch vụ)
///   3. Card biểu đồ bar: "Xu hướng doanh thu" – 7 ngày qua (T2–CN)
///   4. Section "Lịch hẹn sắp tới": list card có color bar (cam/xanh) + phòng
///   5. Section "Dịch vụ phổ biến": horizontal scroll cards + ảnh
///   6. FAB "+" tím góc dưới phải
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grid_view_rounded, size: 64, color: AdminColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('Dashboard – Kiên làm', style: AdminTextStyles.headlineMd),
              const SizedBox(height: 8),
              Text(
                'Xem file thiết kế:\nt_ng_quan_admin/screen.png',
                style: AdminTextStyles.bodyMd,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
