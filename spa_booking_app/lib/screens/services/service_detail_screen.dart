// File này xây dựng màn hình chi tiết dịch vụ.
// Dữ liệu đầu vào là một SpaService được truyền từ HomeScreen hoặc ServicesScreen.
// Màn hình dùng SliverAppBar cho ảnh lớn, phần nội dung cho mô tả/lợi ích/quy trình,
// và bottomNavigationBar để hiển thị giá + nút chuyển sang màn đặt lịch.
// Thư viện Material cung cấp SliverAppBar, navigation và widget layout chi tiết.
import 'package:flutter/material.dart';

// Import màu, kiểu chữ, widget dùng chung, model và màn booking.
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_title.dart';
import '../../models/spa_service.dart';
import '../../providers/booking_provider.dart';
import '../booking/booking_screen.dart';

// StatelessWidget vì toàn bộ thông tin chi tiết đã có sẵn trong biến service, không cần state nội bộ.
class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.service});

  // Đối tượng chứa toàn bộ thông tin dịch vụ cần hiển thị.
  final SpaService service;

  @override
  Widget build(BuildContext context) {
    // Scaffold tạo khung màn hình gồm body cuộn và thanh đặt lịch cố định phía dưới.
    return Scaffold(
      // CustomScrollView cho phép dùng SliverAppBar co giãn cùng nội dung cuộn.
      body: CustomScrollView(
        slivers: [
          // SliverAppBar hiển thị ảnh dịch vụ lớn ở đầu màn hình.
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroImage(service: service),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 112),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: AppTextStyles.title.copyWith(fontSize: 28),
                        ),
                      ),
                      _RatingBadge(rating: service.rating),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(service.description, style: AppTextStyles.muted),
                  const SizedBox(height: 20),
                  _QuickInfo(service: service),
                  const SizedBox(height: 26),
                  const SectionTitle(title: 'Lợi ích nổi bật'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: service.benefits.map((benefit) {
                      return _BenefitItem(text: benefit);
                    }).toList(),
                  ),
                  const SizedBox(height: 26),
                  const SectionTitle(title: 'Quy trình thực hiện'),
                  const SizedBox(height: 12),
                  ...service.process.asMap().entries.map((entry) {
                    return _ProcessItem(
                      index: entry.key + 1,
                      text: entry.value,
                    );
                  }),
                  const SizedBox(height: 10),
                  const _NoticeBox(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Thanh dưới cùng luôn hiển thị tổng tiền và nút đặt lịch.
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: const BoxDecoration(
          color: AppColors.card,
          boxShadow: AppShadows.soft,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng tiền', style: AppTextStyles.muted),
                    const SizedBox(height: 2),
                    Text(
                      formatMoney(service.price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 178,
                child: PrimaryButton(
                  label: 'Đặt lịch ngay',
                  icon: Icons.calendar_month_outlined,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BookingScreen(service: service),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget hiển thị ảnh lớn, overlay gradient và tên dịch vụ trên ảnh.
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.service});

  // Đối tượng chứa toàn bộ thông tin dịch vụ cần hiển thị.
  final SpaService service;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          service.image,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.secondary,
            child: const Icon(Icons.spa, color: AppColors.primary, size: 72),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xC72D2438)],
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  service.category,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                service.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Cụm thông tin nhanh gồm giá, thời lượng và loại dịch vụ.
class _QuickInfo extends StatelessWidget {
  const _QuickInfo({required this.service});

  // Đối tượng chứa toàn bộ thông tin dịch vụ cần hiển thị.
  final SpaService service;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoTile(
            icon: Icons.payments_outlined,
            label: 'Giá',
            value: formatMoney(service.price),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: Icons.schedule,
            label: 'Thời lượng',
            value: '${service.durationMinutes} phút',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _InfoTile(
            icon: Icons.local_offer_outlined,
            label: 'Loại',
            value: service.category,
          ),
        ),
      ],
    );
  }
}

// Một ô thông tin nhỏ trong cụm QuickInfo.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.muted.copyWith(fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// Badge hiển thị điểm đánh giá sao của dịch vụ.
class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// Item lợi ích: icon check + nội dung lợi ích của dịch vụ.
class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Item quy trình: số thứ tự + mô tả bước thực hiện.
class _ProcessItem extends StatelessWidget {
  const _ProcessItem({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Hộp lưu ý nhắc khách đến trước giờ hẹn.
class _NoticeBox extends StatelessWidget {
  const _NoticeBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: .24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vui lòng đến trước giờ hẹn 10 phút để nhân viên chuẩn bị phòng và tư vấn liệu trình phù hợp.',
              style: AppTextStyles.muted,
            ),
          ),
        ],
      ),
    );
  }
}
