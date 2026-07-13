import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';

/// TODO – KIÊN: Màn hình Danh sách Khách hàng
///
/// Dựa theo file thiết kế: stitch_zen_luxury_spa_booking_app/qu_n_l_kh_ch_h_ng/screen.png
///
/// Các thành phần cần làm:
///   1. AppBar: tiêu đề "Khách hàng" + icon chuông
///   2. Search bar pill
///   3. Filter chips: Tất cả / Khách mới / Khách thân thiết
///   4. 2 stat card ngang: "Khách mới +24" (tím) và "Thành viên 158" (xám)
///   5. Tiêu đề "Danh sách khách hàng" + nút Sắp xếp
///   6. List card khách hàng: avatar + tên + phone + color bar VIP tag + lượt hẹn + tổng chi
///   7. FAB "+" tím
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_alt_rounded, size: 64, color: AdminColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('Khách hàng – Kiên làm', style: AdminTextStyles.headlineMd),
              const SizedBox(height: 8),
              Text(
                'Xem file thiết kế:\nqu_n_l_kh_ch_h_ng/screen.png',
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
