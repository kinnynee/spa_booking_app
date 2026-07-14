// Thư viện Material cung cấp ListView, TextField, icon và layout trang chủ.
import 'package:flutter/material.dart';
// Provider dùng để đọc AuthProvider và CatalogProvider.
import 'package:provider/provider.dart';

// Import asset, style, widget dùng chung, dữ liệu mẫu, model và provider.
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/info_row.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/service_card.dart';
import '../../data/mock_services.dart';
import '../../data/mock_spa_data.dart';
import '../../models/spa_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';

// Màn hình trang chủ: chào user, tìm kiếm/lọc dịch vụ và hiển thị thông tin spa.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onOpenService,
    this.loadRemote = true,
  });

  // Callback mở chi tiết khi người dùng chọn dịch vụ.
  final ValueChanged<SpaService> onOpenService;
  // Cờ phục vụ test: false thì bỏ qua loadCatalog sau frame đầu.
  final bool loadRemote;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// State lưu keyword tìm kiếm và category đang chọn trên trang chủ.
class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = allServicesCategory;
  String _keyword = '';

  @override
  // Sau frame đầu, yêu cầu CatalogProvider nạp danh mục/dịch vụ.
  void initState() {
    super.initState();
    if (!widget.loadRemote) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<CatalogProvider>().loadCatalog();
    });
  }

  @override
  // Hủy controller tìm kiếm khi rời màn.
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    final catalog = context
        .watch<CatalogProvider>(); //lấy và rebuild khi thay đổi
    final user = context.watch<AuthProvider>().currentUser;
    final greetingName = user.fullName.trim().isEmpty
        ? 'Guest'
        : user.fullName.trim();
    final categoryNames = catalog.categoryNames;
    final activeCategory = categoryNames.contains(_selectedCategory)
        ? _selectedCategory
        : allServicesCategory;
    final allServices = catalog.services;

    if (catalog.errorMessage != null && allServices.isEmpty) {
      return _CatalogErrorState(
        message: catalog.errorMessage!,
        onRetry: () =>
            context.read<CatalogProvider>().loadCatalog(refresh: true),
      );
    }
    if ((catalog.isLoading || !catalog.hasLoaded) && allServices.isEmpty) {
      return const _CatalogLoadingState();
    }
    if (catalog.hasLoaded && allServices.isEmpty) {
      return const _EmptyCatalogState();
    }

    final popularServices = allServices
        .where((service) => service.isPopular)
        .toList();
    final showcasedServices = popularServices.isEmpty
        ? allServices.take(3).toList()
        : popularServices;
    final filteredServices = catalog.filterServices(
      category: activeCategory,
      keyword: _keyword,
    );
    final hasActiveFilter =
        activeCategory != allServicesCategory || _keyword.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      children: [
        if (catalog.isLoading) ...[
          const LinearProgressIndicator(minHeight: 3),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào, $greetingName',
                    style: AppTextStyles.title.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hôm nay bạn muốn thư giãn như thế nào?',
                    style: AppTextStyles.muted,
                  ),
                ],
              ),
            ),
            const _BlankProfileAvatar(size: 48),
          ],
        ),
        const SizedBox(height: 20),
        _SearchField(
          controller: _searchController,
          onChanged: (value) => setState(() => _keyword = value),
          onClear: _clearSearch,
        ),
        const SizedBox(height: 20),
        const _PromoBanner(),
        const SizedBox(height: 22),
        _CategorySelector(
          categories: categoryNames,
          selectedCategory: activeCategory,
          onCategoryChanged: (category) {
            setState(() => _selectedCategory = category);
          },
        ),
        const SizedBox(height: 24),
        if (hasActiveFilter) ...[
          SectionTitle(
            title: '${filteredServices.length} kết quả phù hợp',
            action: 'Xóa lọc',
            onActionTap: _resetFilters,
          ),
          const SizedBox(height: 12),
          _ServiceResults(
            services: filteredServices,
            onOpenService: widget.onOpenService,
          ),
        ] else ...[
          _SpaStats(serviceCount: allServices.length),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Dịch vụ nổi bật'),
          const SizedBox(height: 12),
          SizedBox(
            height: 286,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: showcasedServices.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final service = showcasedServices[index];
                return ServiceCard(
                  service: service,
                  compact: true,
                  onTap: () => widget.onOpenService(service),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SectionTitle(
            title: 'Gợi ý hôm nay',
            action: 'Xem tất cả',
            onActionTap: () =>
                setState(() => _selectedCategory = allServicesCategory),
          ),
          const SizedBox(height: 12),
          ...allServices
              .take(3)
              .map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ServiceCard(
                    service: service,
                    onTap: () => widget.onOpenService(service),
                  ),
                ),
              ),
        ],
        const SizedBox(height: 10),
        const _SpaInfoCard(),
      ],
    );
  }

  // Xóa keyword tìm kiếm nhưng giữ nguyên category đang chọn.
  void _clearSearch() {
    _searchController.clear();
    setState(() => _keyword = '');
  }

  // Đưa trang chủ về trạng thái không search và category Tất cả.
  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _keyword = '';
      _selectedCategory = allServicesCategory;
    });
  }
}

// Avatar mặc định khi chưa dùng ảnh đại diện thật của user.
class _BlankProfileAvatar extends StatelessWidget {
  const _BlankProfileAvatar({required this.size});

  final double size;

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        color: AppColors.primary,
        size: size * .52,
      ),
    );
  }
}

// Ô tìm kiếm dịch vụ trên trang chủ, có nút xóa nhanh khi có keyword.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Tìm dịch vụ spa',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Xóa tìm kiếm',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

// Danh sách chip category cuộn ngang.
class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            label: category,
            icon: _categoryIcon(category),
            selected: category == selectedCategory,
            onTap: () => onCategoryChanged(category),
          );
        },
      ),
    );
  }
}

// Kết quả dịch vụ sau khi người dùng search hoặc lọc category.
class _ServiceResults extends StatelessWidget {
  const _ServiceResults({required this.services, required this.onOpenService});

  final List<SpaService> services;
  final ValueChanged<SpaService> onOpenService;

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const _EmptyServiceState();
    }

    return Column(
      children: services
          .map(
            (service) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ServiceCard(
                service: service,
                onTap: () => onOpenService(service),
              ),
            ),
          )
          .toList(),
    );
  }
}

// Banner khuyến mãi trên trang chủ, fallback icon nếu asset lỗi.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadows.soft,
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 126,
        width: double.infinity,
        child: Image.asset(
          AppAssets.sales,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.secondary,
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_offer_rounded,
                color: AppColors.primary,
                size: 48,
              ),
            );
          },
        ),
      ),
    );
  }
}

// Cụm thống kê ngắn: số dịch vụ, đánh giá và giờ mở cửa.
class _SpaStats extends StatelessWidget {
  const _SpaStats({required this.serviceCount});

  final int serviceCount;

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(value: '$serviceCount+', label: 'Dịch vụ'),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _StatTile(value: '4.8', label: 'Đánh giá'),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: _StatTile(value: '8-21h', label: 'Mở cửa'),
        ),
      ],
    );
  }
}

// Một ô thống kê nhỏ trong cụm _SpaStats.
class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.muted.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Card thông tin cửa hàng lấy dữ liệu từ mock_spa_data.dart.
class _SpaInfoCard extends StatelessWidget {
  const _SpaInfoCard();

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lavenderSpa.name, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(lavenderSpa.description, style: AppTextStyles.muted),
          const SizedBox(height: 16),
          InfoRow(
            icon: Icons.place_outlined,
            label: 'Địa chỉ',
            value: lavenderSpa.address,
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.schedule,
            label: 'Giờ mở cửa',
            value: lavenderSpa.openingHours,
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.call_outlined,
            label: 'Hotline',
            value: lavenderSpa.phone,
          ),
        ],
      ),
    );
  }
}

// Loading toàn màn hình khi catalog backend chưa trả dữ liệu.
class _CatalogLoadingState extends StatelessWidget {
  const _CatalogLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// Màn hình lỗi khi không tải được catalog từ backend.
class _CatalogErrorState extends StatelessWidget {
  const _CatalogErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 58),
            const SizedBox(height: 12),
            const Text(
              'Không thể tải dịch vụ',
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.muted,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty state khi backend trả về danh sách dịch vụ rỗng.
class _EmptyCatalogState extends StatelessWidget {
  const _EmptyCatalogState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa_outlined, color: AppColors.primary, size: 58),
            SizedBox(height: 12),
            Text(
              'Không có dữ liệu dịch vụ',
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle,
            ),
            SizedBox(height: 8),
            Text(
              'Backend chưa có dịch vụ nào để hiển thị.',
              textAlign: TextAlign.center,
              style: AppTextStyles.muted,
            ),
          ],
        ),
      ),
    );
  }
}

// Empty state khi không có dịch vụ nào khớp điều kiện tìm kiếm/lọc.
class _EmptyServiceState extends StatelessWidget {
  const _EmptyServiceState();

  @override
  // build dựng phần giao diện của widget trong trang chủ.
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: const [
          Icon(Icons.search_off_rounded, color: AppColors.primary, size: 54),
          SizedBox(height: 12),
          Text('Không tìm thấy dịch vụ', style: AppTextStyles.sectionTitle),
          SizedBox(height: 6),
          Text(
            'Hãy thử từ khóa khác hoặc chọn lại danh mục.',
            textAlign: TextAlign.center,
            style: AppTextStyles.muted,
          ),
        ],
      ),
    );
  }
}

// Chuyển tên category thành icon tương ứng cho CategoryChip.
IconData _categoryIcon(String category) {
  switch (category) {
    case 'Massage':
    case 'Mát-xa':
      return Icons.self_improvement_rounded;
    case 'Chăm sóc da':
      return Icons.face_retouching_natural_rounded;
    case 'Gội đầu':
      return Icons.water_drop_outlined;
    case 'Trị liệu':
      return Icons.healing_rounded;
    case 'Dưỡng thể':
      return Icons.spa_rounded;
    case 'Nail':
      return Icons.brush_rounded;
    case 'Combo':
      return Icons.favorite_rounded;
    default:
      return Icons.grid_view_rounded;
  }
}
