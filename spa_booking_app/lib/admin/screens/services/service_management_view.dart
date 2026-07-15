import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_spa_service_provider.dart';
import '../../../core/constants/app_assets.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../models/admin_spa_service.dart';
import 'edit_service_screen.dart';

class AdminSpaServicesView extends StatefulWidget {
  const AdminSpaServicesView({super.key});

  @override
  State<AdminSpaServicesView> createState() => _AdminSpaServicesViewState();
}

class _AdminSpaServicesViewState extends State<AdminSpaServicesView> {
  final TextEditingController _searchController = TextEditingController();
  int _filterIndex = 0;
  String _searchQuery = '';

  static const _filters = ['Tất cả', 'Đang hoạt động', 'Tạm ẩn'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AdminSpaServiceProvider>().loadServices();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AdminSpaService> _filtered(List<AdminSpaService> services) {
    var result = services;
    if (_filterIndex == 1) {
      result = result.where((service) => service.isActive).toList();
    } else if (_filterIndex == 2) {
      result = result.where((service) => !service.isActive).toList();
    }

    final keyword = _searchQuery.trim().toLowerCase();
    if (keyword.isNotEmpty) {
      result = result
          .where(
            (service) =>
                service.name.toLowerCase().contains(keyword) ||
                service.categoryName.toLowerCase().contains(keyword) ||
                service.description.toLowerCase().contains(keyword),
          )
          .toList();
    }
    return result;
  }

  Future<void> _openEditor({AdminSpaService? service}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditServiceScreen(service: service)),
    );
    if (!mounted || saved != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          service == null ? 'Đã thêm dịch vụ mới.' : 'Đã cập nhật dịch vụ.',
        ),
        backgroundColor: AdminColors.statusCompleted,
      ),
    );
  }

  Future<void> _changeStatus(AdminSpaService service, bool isActive) async {
    final provider = context.read<AdminSpaServiceProvider>();
    final saved = await provider.updateService(service, isActive: isActive);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? isActive
                    ? 'Đã bật dịch vụ.'
                    : 'Đã tạm ẩn dịch vụ.'
              : provider.errorMessage ?? 'Không thể cập nhật dịch vụ.',
        ),
        backgroundColor: saved
            ? AdminColors.statusCompleted
            : AdminColors.statusCancelled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminSpaServiceProvider>();
    final services = _filtered(provider.services);

    return RefreshIndicator(
      onRefresh: () => provider.loadServices(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: AdminTextStyles.bodyMd,
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
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => _FilterChip(
                label: _filters[index],
                isSelected: _filterIndex == index,
                onTap: () => setState(() => _filterIndex = index),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (provider.isLoading && !provider.hasLoaded)
            const Padding(
              padding: EdgeInsets.only(top: 120),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.errorMessage != null && provider.services.isEmpty)
            _ServiceMessage(
              icon: Icons.wifi_off_rounded,
              title: 'Chưa tải được dịch vụ',
              message: provider.errorMessage!,
              actionLabel: 'Thử lại',
              onAction: () => provider.loadServices(refresh: true),
            )
          else if (services.isEmpty)
            const _ServiceMessage(
              icon: Icons.spa_outlined,
              title: 'Chưa có dịch vụ phù hợp',
              message: 'Nhấn nút + để thêm dịch vụ mới.',
            )
          else
            ...services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ServiceCard(
                  service: service,
                  saving: provider.isSaving,
                  onTap: () => _openEditor(service: service),
                  onStatusChanged: (value) => _changeStatus(service, value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primary : AdminColors.surfaceWhite,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: AdminTextStyles.bodyMd.copyWith(
            color: isSelected ? Colors.white : AdminColors.onSurfaceVariant,
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
    required this.saving,
    required this.onTap,
    required this.onStatusChanged,
  });

  final AdminSpaService service;
  final bool saving;
  final VoidCallback onTap;
  final ValueChanged<bool> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminColors.surfaceWhite,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: AdminColors.ambientShadow,
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceImage(url: service.imageUrl, fallbackAsset: AppAssets.serviceImageFor(name: service.name, categorySlug: service.categoryName)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(service.name, style: AdminTextStyles.titleLg),
                        ),
                        _StatusPill(isActive: service.isActive),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${service.categoryName} • ${service.durationMinutes} phút',
                      style: AdminTextStyles.bodySm.copyWith(
                        color: AdminColors.outline,
                      ),
                    ),
                    if (service.description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        service.description,
                        style: AdminTextStyles.bodyMd.copyWith(
                          color: AdminColors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(_formatMoney(service.price), style: AdminTextStyles.price),
                        const Spacer(),
                        Text(
                          service.isActive ? 'Đang hiển thị' : 'Tạm ẩn',
                          style: AdminTextStyles.bodySm.copyWith(
                            color: AdminColors.outline,
                          ),
                        ),
                        Switch(
                          value: service.isActive,
                          onChanged: saving ? null : onStatusChanged,
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
      ),
    );
  }
}

class _ServiceImage extends StatelessWidget {
  const _ServiceImage({required this.url, required this.fallbackAsset});

  final String url;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final hasImage = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (!hasImage) {
      return _imageFallback();
    }
    return SizedBox(
      height: 132,
      width: double.infinity,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imageFallback(),
      ),
    );
  }

  Widget _imageFallback() {
    return SizedBox(
      height: 132,
      width: double.infinity,
      child: Image.asset(
        fallbackAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AdminColors.secondaryFixed,
          child: const Icon(Icons.spa_rounded, size: 48, color: AdminColors.primary),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AdminColors.statusCompleted
        : AdminColors.statusPending;
    final background = isActive
        ? AdminColors.statusCompletedBg
        : AdminColors.statusPendingBg;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isActive ? 'Hoạt động' : 'Tạm ẩn',
        style: AdminTextStyles.labelSm.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ServiceMessage extends StatelessWidget {
  const _ServiceMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 96),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AdminColors.outline),
          const SizedBox(height: 12),
          Text(title, style: AdminTextStyles.titleMd),
          const SizedBox(height: 6),
          Text(
            message,
            style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

String _formatMoney(int amount) {
  final value = NumberFormat.decimalPattern('vi_VN')
      .format(amount)
      .replaceAll(',', '.');
  return '$value đ';
}
