import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';

/// TODO – KIÊN: Màn hình Hồ sơ Khách hàng (Chi tiết)
///
/// Dựa theo file thiết kế: stitch_zen_luxury_spa_booking_app/chi_ti_t_kh_ch_h_ng/screen.png
///
/// Các thành phần cần làm:
///   1. AppBar: nút back + "Hồ sơ khách hàng" + nút ⋮
///   2. Avatar tròn lớn có nút edit nhỏ góc
///   3. Tên khách + badge "Khách thân thiết"
///   4. Row 3 stat: Tổng lịch / Tổng chi / Yêu thích
///   5. TabBar: Lịch sử / Ghi chú / Ưu đãi
///   6. TabView "Lịch sử": list lịch theo tháng, mỗi lịch có color bar + dịch vụ + giá + trạng thái
///   7. FAB "Tạo lịch hẹn cho khách" dưới cùng
class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_rounded, size: 64, color: AdminColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text('Chi tiết KH – Kiên làm', style: AdminTextStyles.headlineMd),
            ],
          ),
        ),
      ),
    );
  }
}
