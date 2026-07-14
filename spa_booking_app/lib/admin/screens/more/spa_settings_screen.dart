import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';

class SpaSettingsScreen extends StatelessWidget {
  const SpaSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AdminColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Cài đặt Spa', style: AdminTextStyles.titleLg),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Thông tin tiệm
          Row(
            children: [
              const Icon(Icons.storefront_rounded, color: AdminColors.primary),
              const SizedBox(width: 8),
              Text('THÔNG TIN TIỆM', style: AdminTextStyles.labelLg),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsTextField(label: 'Tên Spa', initialValue: 'Lavender Spa'),
          const SizedBox(height: 16),
          _SettingsTextField(
            label: 'Địa chỉ',
            initialValue: '123 Đường ABC, Quận 1, TP.HCM',
          ),
          const SizedBox(height: 16),
          _SettingsTextField(label: 'Hotline', initialValue: '0123 456 789'),
          const SizedBox(height: 16),
          _SettingsTextField(
            label: 'Email',
            initialValue: 'contact@lavenderspa.vn',
          ),
          const SizedBox(height: 32),

          // Giờ hoạt động
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: AdminColors.primary),
              const SizedBox(width: 8),
              Text('GIỜ HOẠT ĐỘNG', style: AdminTextStyles.labelLg),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AdminColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AdminColors.ambientShadow,
            ),
            child: Column(
              children: [
                _OperatingHourRow(
                  day: 'Thứ 2',
                  time: '09:00 - 21:00',
                  isActive: true,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _OperatingHourRow(
                  day: 'Thứ 3',
                  time: '09:00 - 21:00',
                  isActive: true,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _OperatingHourRow(
                  day: 'Thứ 4',
                  time: '09:00 - 21:00',
                  isActive: true,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _OperatingHourRow(
                  day: 'Thứ 5',
                  time: '09:00 - 21:00',
                  isActive: true,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _OperatingHourRow(
                  day: 'Thứ 6',
                  time: '09:00 - 21:00',
                  isActive: true,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _OperatingHourRow(
                  day: 'Thứ 7',
                  time: '09:00 - 21:00',
                  isActive: true,
                  isWeekend: true,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _OperatingHourRow(
                  day: 'Chủ Nhật',
                  time: '09:00 - 21:00',
                  isActive: false,
                  isWeekend: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Chính sách đặt lịch
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AdminColors.primary),
              const SizedBox(width: 8),
              Text('CHÍNH SÁCH ĐẶT LỊCH', style: AdminTextStyles.labelLg),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AdminColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AdminColors.ambientShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Cho phép hủy lịch trước (giờ)',
                    style: AdminTextStyles.titleMd,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: TextEditingController(text: '2'),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Submit
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AdminColors.primary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            child: Text(
              'Lưu thay đổi',
              style: AdminTextStyles.titleMd.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  const _SettingsTextField({required this.label, required this.initialValue});
  final String label;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AdminTextStyles.bodyMd.copyWith(
            color: AdminColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: initialValue),
          decoration: InputDecoration(
            filled: true,
            fillColor: AdminColors.surfaceWhite,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AdminColors.surfaceContainerHigh,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AdminColors.surfaceContainerHigh,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AdminColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _OperatingHourRow extends StatelessWidget {
  const _OperatingHourRow({
    required this.day,
    required this.time,
    required this.isActive,
    this.isWeekend = false,
  });
  final String day;
  final String time;
  final bool isActive;
  final bool isWeekend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: AdminTextStyles.bodyLg.copyWith(
                color: isWeekend ? AdminColors.primary : AdminColors.onSurface,
                fontWeight: isWeekend ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              time,
              style: AdminTextStyles.bodyMd.copyWith(
                color: isActive ? AdminColors.onSurface : AdminColors.outline,
                decoration: isActive
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (v) {},
            activeThumbColor: AdminColors.primary,
          ),
        ],
      ),
    );
  }
}
