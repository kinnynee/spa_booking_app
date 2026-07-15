// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../core/widgets/admin_app_bar.dart';
import '../../models/admin_mock_data.dart';
import '../categories/categories_screen.dart';
import 'edit_service_screen.dart';
import 'service_management_view.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AdminAppBar(
        title: 'D\u1ecbch v\u1ee5',
        showMenuIcon: true,
        actions: [
          IconButton(
            tooltip: 'Danh \u1ee5c',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditServiceScreen()),
        ),
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: const AdminSpaServicesView(),
      /*
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm dịch vụ...',
                hintStyle: AdminTextStyles.bodyMd.copyWith(
                  color: AdminColors.outline,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AdminColors.outline,
                ),
                filled: true,
                fillColor: AdminColors.surfaceWhite,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(label: 'Tất cả', isSelected: true),
                const SizedBox(width: 8),
                _FilterChip(label: 'Đang hoạt động', isSelected: false),
                const SizedBox(width: 8),
                _FilterChip(label: 'Tạm ẩn', isSelected: false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              itemCount: mockAdminServices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, i) =>
                  _ServiceCard(service: mockAdminServices[i]),
            ),
          ),
        ],
      ),
      */
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected});
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AdminColors.primary
            : AdminColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AdminTextStyles.bodyMd.copyWith(
          color: isSelected ? Colors.white : AdminColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final AdminService service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditServiceScreen(serviceId: service.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AdminColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AdminColors.ambientShadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            // Image area
            Container(
              height: 120,
              color: AdminColors.primary.withValues(alpha: 0.1),
              child: const Center(
                child: Icon(
                  Icons.image_rounded,
                  size: 48,
                  color: AdminColors.primary,
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service.name,
                          style: AdminTextStyles.titleLg,
                        ),
                      ),
                      const Icon(
                        Icons.more_vert_rounded,
                        color: AdminColors.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Liệu trình thư giãn cơ bản, giúp giảm căng thẳng và mệt mỏi hiệu quả.',
                    style: AdminTextStyles.bodyMd.copyWith(
                      color: AdminColors.outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        formatAdminMoney(service.price),
                        style: AdminTextStyles.price,
                      ),
                      const Spacer(),
                      Switch(
                        value: true,
                        onChanged: (v) {},
                        activeThumbColor: AdminColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
