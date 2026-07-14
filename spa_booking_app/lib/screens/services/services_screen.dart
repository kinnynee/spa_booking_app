// File này xây dựng màn hình danh sách dịch vụ đầy đủ.
// Người dùng có thể tìm kiếm theo từ khóa, lọc theo danh mục và bấm vào card
// để mở màn hình chi tiết dịch vụ thông qua callback onOpenService.
// Thư viện Material cung cấp layout, input và icon cho màn dịch vụ.
import 'package:flutter/material.dart';
// Provider dùng để đọc CatalogProvider và rebuild khi catalog thay đổi.
import 'package:provider/provider.dart';

// Import màu, kiểu chữ và các widget dùng lại trong màn danh sách dịch vụ.
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/service_card.dart';
import '../../data/mock_services.dart';
import '../../models/spa_service.dart';
import '../../providers/catalog_provider.dart';

// StatefulWidget vì màn hình cần lưu keyword tìm kiếm và danh mục đang chọn.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({
    super.key,
    required this.onOpenService,
    this.loadRemote = true,
  });

  // Callback được gọi khi người dùng chọn một dịch vụ trong danh sách.
  final ValueChanged<SpaService> onOpenService;
  // Cờ hỗ trợ test: false thì không gọi loadCatalog sau frame đầu.
  final bool loadRemote;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

// State lưu trạng thái filter/search của màn Services.
class _ServicesScreenState extends State<ServicesScreen> {
  // Controller quản lý text trong ô tìm kiếm.
  final _searchController = TextEditingController();
  // Mặc định chọn danh mục 'Tất cả'.
  String _selectedCategory = allServicesCategory;
  // Từ khóa dùng để lọc tên/mô tả/tag dịch vụ.
  String _keyword = '';

  @override
  // Hàm chạy khi widget được tạo, dùng để yêu cầu provider nạp catalog.
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
  // Hủy controller khi thoát màn để tránh giữ tài nguyên không cần thiết.
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // watch giúp UI tự rebuild khi CatalogProvider thay đổi dữ liệu.
    final catalog = context.watch<CatalogProvider>();
    final categoryNames = catalog.categoryNames;
    final activeCategory = categoryNames.contains(_selectedCategory)
        ? _selectedCategory
        : allServicesCategory;
    // Lọc danh sách dịch vụ dựa trên category đang chọn và keyword.
    final services = catalog.filterServices(
      category: activeCategory,
      keyword: _keyword,
    );

    if (catalog.errorMessage != null && catalog.services.isEmpty) {
      return _CatalogErrorState(
        message: catalog.errorMessage!,
        onRetry: () =>
            context.read<CatalogProvider>().loadCatalog(refresh: true),
      );
    }
    if ((catalog.isLoading || !catalog.hasLoaded) && catalog.services.isEmpty) {
      return const _CatalogLoadingState();
    }
    if (catalog.hasLoaded && catalog.services.isEmpty) {
      return const _EmptyCatalogState();
    }

    return Column(
      children: [
        if (catalog.isLoading) const LinearProgressIndicator(minHeight: 3),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dịch vụ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tìm liệu trình phù hợp và đặt lịch ngay trong vài bước.',
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _keyword = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm dịch vụ',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _keyword.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Xóa tìm kiếm',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryNames.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = categoryNames[index];
                    return CategoryChip(
                      label: category,
                      icon: _categoryIcon(category),
                      selected: category == activeCategory,
                      onTap: () => setState(() => _selectedCategory = category),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              SectionTitle(
                title: '${services.length} dịch vụ phù hợp',
                action: _hasFilter(activeCategory) ? 'Xóa lọc' : null,
                onActionTap: _resetFilters,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: services.isEmpty
              ? const _EmptyServiceState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  itemCount: services.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ServiceCard(
                      service: service,
                      onTap: () => widget.onOpenService(service),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Kiểm tra người dùng có đang bật filter/search không.
  bool _hasFilter(String activeCategory) {
    return activeCategory != allServicesCategory || _keyword.isNotEmpty;
  }

  // Xóa keyword nhưng giữ nguyên category đang chọn.
  void _clearSearch() {
    _searchController.clear();
    setState(() => _keyword = '');
  }

  // Đưa màn hình về trạng thái không search, không lọc category.
  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _keyword = '';
      _selectedCategory = allServicesCategory;
    });
  }
}

// Loading toàn màn hình khi danh sách dịch vụ đang tải từ backend.
class _CatalogLoadingState extends StatelessWidget {
  const _CatalogLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// Màn hình lỗi khi backend không trả được danh sách dịch vụ.
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

// Empty state khi backend chưa có service nào.
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

// Widget hiển thị khi không có dịch vụ nào khớp điều kiện lọc.
class _EmptyServiceState extends StatelessWidget {
  const _EmptyServiceState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              SizedBox(height: 14),
              Text(
                'Không tìm thấy dịch vụ',
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionTitle,
              ),
              SizedBox(height: 8),
              Text(
                'Hãy thử từ khóa khác hoặc chọn lại danh mục.',
                textAlign: TextAlign.center,
                style: AppTextStyles.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Chuyển tên category thành icon để giao diện dễ nhìn hơn.
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
