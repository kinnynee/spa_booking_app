// Thư viện Material cung cấp card layout, ảnh, icon và hiệu ứng tap.
import 'package:flutter/material.dart';

// Import model dịch vụ, hàm format tiền và màu giao diện.
import '../../models/spa_service.dart';
import '../../providers/booking_provider.dart';
import '../constants/app_colors.dart';

// StatelessWidget vì card chỉ nhận dữ liệu service và callback onTap từ bên ngoài.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.compact = false,
  });

  // Dữ liệu dịch vụ cần hiển thị trong card.
  final SpaService service;
  // Hàm được gọi khi người dùng bấm vào card.
  final VoidCallback onTap;
  // compact=true tạo card nhỏ nằm ngang; false tạo card đầy đủ.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // InkWell tạo hiệu ứng bấm và bắt sự kiện tap cho toàn bộ card.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: compact ? 244 : null,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border.withValues(alpha: .7)),
          boxShadow: AppShadows.soft,
        ),
        child: compact ? _buildCompactContent() : _buildFullContent(),
      ),
    );
  }

  // Layout card nhỏ: ảnh phía trên, thông tin phía dưới.
  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ServiceImage(service: service, height: 116),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryLabel(category: service.category),
              const SizedBox(height: 8),
              _ServiceTitle(service.name),
              const SizedBox(height: 8),
              _MetaLine(service: service),
            ],
          ),
        ),
      ],
    );
  }

  // Layout card đầy đủ: ảnh bên trái, thông tin bên phải.
  Widget _buildFullContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(22),
          ),
          child: _ServiceImage(
            service: service,
            height: 166,
            compactSide: true,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _CategoryLabel(category: service.category)),
                    _Rating(rating: service.rating),
                  ],
                ),
                const SizedBox(height: 8),
                _ServiceTitle(service.name),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                _MetaLine(service: service),
                const SizedBox(height: 12),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Xem chi tiết',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Widget riêng để xử lý ảnh dịch vụ, fallback khi ảnh lỗi và tag khuyến mãi.
class _ServiceImage extends StatelessWidget {
  const _ServiceImage({
    required this.service,
    required this.height,
    this.compactSide = false,
  });

  // Dữ liệu dịch vụ cần hiển thị trong card.
  final SpaService service;
  final double height;
  final bool compactSide;

  @override
  Widget build(BuildContext context) {
    final width = compactSide ? 126.0 : double.infinity;
    final image = service.image.trim().isEmpty
        ? _placeholder(width, height)
        : Image.network(
            service.image,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(width, height),
          );

    return Stack(
      children: [
        ClipRRect(
          borderRadius: compactSide
              ? BorderRadius.zero
              : const BorderRadius.vertical(top: Radius.circular(22)),
          child: image,
        ),
        if (service.tag.isNotEmpty)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                service.tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Placeholder hiển thị khi service.image rỗng hoặc Image.network tải lỗi.
  Widget _placeholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: AppColors.secondary.withValues(alpha: .36),
      child: const Center(
        child: Icon(Icons.spa, color: AppColors.primary, size: 44),
      ),
    );
  }
}

// Nhãn category nhỏ trên card dịch vụ.
class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: .34),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// Widget title giới hạn 2 dòng để card không bị vỡ layout.
class _ServiceTitle extends StatelessWidget {
  const _ServiceTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        height: 1.22,
      ),
    );
  }
}

// Dòng meta hiển thị giá và thời lượng dịch vụ.
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.service});

  // Dữ liệu dịch vụ cần hiển thị trong card.
  final SpaService service;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          formatMoney(service.price),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Icon(Icons.schedule, color: AppColors.textLight, size: 16),
        Text(
          '${service.durationMinutes} phút',
          style: const TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// Widget hiển thị rating dạng sao + số điểm.
class _Rating extends StatelessWidget {
  const _Rating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
          const SizedBox(width: 3),
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
