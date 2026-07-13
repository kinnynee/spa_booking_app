import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../core/widgets/admin_app_bar.dart';
import '../../models/admin_mock_data.dart';
import 'edit_service_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<String, bool> _activeById = {
    for (final service in mockAdminServices) service.id: service.isActive,
  };

  int _filterIndex = 0;
  String _query = '';

  final List<String> _filters = const ['Tất cả', 'Đang hoạt động', 'Tạm ẩn'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminService> get _filteredServices {
    final normalizedQuery = _query.trim().toLowerCase();

    return mockAdminServices.where((service) {
      final active = _isActive(service);
      final matchesFilter = switch (_filterIndex) {
        1 => active,
        2 => !active,
        _ => true,
      };

      final matchesQuery =
          normalizedQuery.isEmpty ||
          service.name.toLowerCase().contains(normalizedQuery) ||
          service.category.toLowerCase().contains(normalizedQuery) ||
          service.description.toLowerCase().contains(normalizedQuery);

      return matchesFilter && matchesQuery;
    }).toList();
  }

  bool _isActive(AdminService service) =>
      _activeById[service.id] ?? service.isActive;

  void _openEditor([AdminService? service]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditServiceScreen(serviceId: service?.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = _filteredServices;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: const AdminAppBar(title: 'Dịch vụ', showMenuIcon: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: _SearchField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return _FilterChip(
                  label: _filters[index],
                  selected: index == _filterIndex,
                  onTap: () => setState(() => _filterIndex = index),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: services.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return _ServiceCard(
                        service: service,
                        isActive: _isActive(service),
                        onToggle: (value) {
                          setState(() => _activeById[service.id] = value);
                        },
                        onEdit: () => _openEditor(service),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AdminTextStyles.bodyMd,
      decoration: InputDecoration(
        hintText: 'Tìm dịch vụ, danh mục...',
        hintStyle: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AdminColors.outline,
        ),
        filled: true,
        fillColor: AdminColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(99),
          borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AdminColors.primary
              : AdminColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: AdminTextStyles.bodyMd.copyWith(
            color: selected ? Colors.white : AdminColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.isActive,
    required this.onToggle,
    required this.onEdit,
  });

  final AdminService service;
  final bool isActive;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AdminColors.ambientShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 164,
            width: double.infinity,
            child: Image.network(
              service.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AdminColors.secondaryFixed,
                child: const Icon(
                  Icons.spa_rounded,
                  size: 46,
                  color: AdminColors.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: AdminTextStyles.titleMd,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DurationBadge(minutes: service.durationMinutes),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: AdminTextStyles.bodyMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      formatAdminMoney(service.price),
                      style: AdminTextStyles.price,
                    ),
                    const Spacer(),
                    _StatusSwitch(active: isActive, onChanged: onToggle),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AdminColors.outline,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Sửa dịch vụ'),
                        ),
                        PopupMenuItem(value: 'hide', child: Text('Ẩn dịch vụ')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AdminColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 14,
            color: AdminColors.outline,
          ),
          const SizedBox(width: 4),
          Text('$minutes phút', style: AdminTextStyles.labelSm),
        ],
      ),
    );
  }
}

class _StatusSwitch extends StatelessWidget {
  const _StatusSwitch({required this.active, required this.onChanged});

  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          active ? 'Hoạt động' : 'Tạm ẩn',
          style: AdminTextStyles.labelSm.copyWith(
            color: active ? AdminColors.statusCompleted : AdminColors.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Switch(
          value: active,
          activeThumbColor: AdminColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.spa_outlined,
              size: 58,
              color: AdminColors.primary.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 12),
            Text('Không tìm thấy dịch vụ', style: AdminTextStyles.titleMd),
            const SizedBox(height: 4),
            Text(
              'Thử đổi từ khóa hoặc bộ lọc để xem thêm dịch vụ.',
              style: AdminTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
