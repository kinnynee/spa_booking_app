// Thư viện Material cung cấp Row, Text và InkWell cho tiêu đề.
import 'package:flutter/material.dart';

// Import màu và text style thống nhất của app.
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

// StatelessWidget vì tiêu đề chỉ phụ thuộc dữ liệu truyền vào constructor.
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
  });

  // Tiêu đề chính của section.
  final String title;
  // Chữ hành động bên phải; null thì không hiển thị.
  final String? action;
  // Callback khi bấm action; nullable vì action có thể không có.
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
        if (action != null)
          InkWell(
            onTap: onActionTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                action!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
