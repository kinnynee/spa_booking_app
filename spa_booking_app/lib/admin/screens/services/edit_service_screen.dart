// ignore_for_file: unused_element, unused_element_parameter
import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../models/admin_spa_service.dart';
import 'service_editor.dart';

class EditServiceScreen extends StatelessWidget {
  const EditServiceScreen({super.key, this.serviceId, this.service});
  final String? serviceId;
  final AdminSpaService? service;

  @override
  Widget build(BuildContext context) {
    return AdminServiceEditor(service: service);
    /*
    final isEdit = serviceId != null;

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
        title: Text(
          isEdit ? 'Chỉnh sửa dịch vụ' : 'Thêm dịch vụ mới',
          style: AdminTextStyles.titleLg,
        ),
        centerTitle: true,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AdminColors.statusCancelled,
              ),
              onPressed: () {},
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Ảnh
          Center(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AdminColors.primary,
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 48,
                          color: AdminColors.primary,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tải ảnh lên',
                          style: TextStyle(
                            color: AdminColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Thông tin cơ bản
          Text('THÔNG TIN CƠ BẢN', style: AdminTextStyles.labelLg),
          const SizedBox(height: 12),
          _CustomTextField(label: 'Tên dịch vụ', hint: 'Nhập tên dịch vụ'),
          const SizedBox(height: 16),
          _CustomTextField(
            label: 'Danh mục',
            hint: 'Chọn danh mục',
            suffixIcon: Icons.arrow_drop_down_rounded,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _CustomTextField(label: 'Giá (VNĐ)', hint: '0'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CustomTextField(label: 'Thời lượng (Phút)', hint: '60'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Mô tả
          Text('MÔ TẢ DỊCH VỤ', style: AdminTextStyles.labelLg),
          const SizedBox(height: 12),
          _CustomTextField(
            label: 'Mô tả ngắn',
            hint: 'Hiển thị ngoài danh sách',
          ),
          const SizedBox(height: 16),
          _CustomTextField(
            label: 'Mô tả chi tiết',
            hint: 'Nhập mô tả chi tiết...',
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          // Cài đặt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AdminColors.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AdminColors.ambientShadow,
            ),
            child: Row(
              children: [
                Text('Trạng thái hoạt động', style: AdminTextStyles.titleMd),
                const Spacer(),
                Switch(
                  value: true,
                  onChanged: (v) {},
                  activeThumbColor: AdminColors.primary,
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
              'Lưu dịch vụ',
              style: AdminTextStyles.titleMd.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
    */
  }
}

class _CustomTextField extends StatelessWidget {
  const _CustomTextField({
    required this.label,
    required this.hint,
    this.suffixIcon,
    this.maxLines = 1,
  });
  final String label;
  final String hint;
  final IconData? suffixIcon;
  final int maxLines;

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
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AdminTextStyles.bodyMd.copyWith(
              color: AdminColors.outline,
            ),
            filled: true,
            fillColor: AdminColors.surfaceWhite,
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AdminColors.outline)
                : null,
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
