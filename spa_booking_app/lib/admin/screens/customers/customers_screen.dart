import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../core/widgets/admin_app_bar.dart';
import '../../models/admin_mock_data.dart';
import '../../../providers/admin_booking_provider.dart';
import 'customer_detail_screen.dart';

enum _CustomerSort { totalSpent, totalBookings, name }

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _filterIndex = 0;
  String _searchQuery = '';
  _CustomerSort _sort = _CustomerSort.totalSpent;

  final List<String> _filters = const [
    'Tất cả',
    'Khách mới',
    'Khách thân thiết',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AdminBookingProvider>().loadBookingFormOptions();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminCustomer> _visibleCustomers(List<AdminCustomer> source) {
    Iterable<AdminCustomer> list = source;

    if (_filterIndex == 1) {
      list = list.where((customer) => customer.tag == 'Mới');
    }

    if (_filterIndex == 2) {
      list = list.where(
        (customer) => customer.tag == 'VIP' || customer.tag == 'Thân thiết',
      );
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      final phoneQuery = query.replaceAll(' ', '');
      list = list.where((customer) {
        final phone = customer.phone.replaceAll(' ', '').toLowerCase();
        return customer.name.toLowerCase().contains(query) ||
            customer.tag.toLowerCase().contains(query) ||
            phone.contains(phoneQuery);
      });
    }

    final sorted = List<AdminCustomer>.of(list);
    switch (_sort) {
      case _CustomerSort.totalSpent:
        sorted.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
        break;
      case _CustomerSort.totalBookings:
        sorted.sort((a, b) => b.totalBookings.compareTo(a.totalBookings));
        break;
      case _CustomerSort.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return sorted;
  }

  String get _sortLabel {
    switch (_sort) {
      case _CustomerSort.totalSpent:
        return 'Chi tiêu';
      case _CustomerSort.totalBookings:
        return 'Lượt hẹn';
      case _CustomerSort.name:
        return 'Tên A-Z';
    }
  }

  void _showAddCustomerMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng thêm khách hàng sắp ra mắt.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBookingProvider>();
    final customers = _visibleCustomers(provider.customers);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: const AdminAppBar(title: 'Khách hàng', showMenuIcon: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerMessage,
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: AdminTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'Tìm tên khách hàng hoặc SĐT',
                hintStyle: AdminTextStyles.bodyMd.copyWith(
                  color: AdminColors.outline,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AdminColors.outline,
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Xóa tìm kiếm',
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close_rounded),
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
                  borderSide: const BorderSide(
                    color: AdminColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
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
                final selected = index == _filterIndex;
                return _FilterChip(
                  label: _filters[index],
                  isSelected: selected,
                  onTap: () => setState(() => _filterIndex = index),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Khách mới',
                    value:
                        "+${provider.customers.where((customer) => customer.tag == 'Mới').length}",
                    color: AdminColors.primary,
                    isHighlighted: true,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Thành viên',
                    value: "${provider.customers.length}",
                    color: AdminColors.onSurface,
                    isHighlighted: false,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Danh sách khách hàng',
                    style: AdminTextStyles.titleLg,
                  ),
                ),
                _SortButton(
                  selected: _sort,
                  label: _sortLabel,
                  onSelected: (value) => setState(() => _sort = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: customers.isEmpty
                ? _EmptyCustomersState(
                    onClear: () {
                      _searchCtrl.clear();
                      setState(() {
                        _searchQuery = '';
                        _filterIndex = 0;
                      });
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: customers.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _CustomerCard(customer: customers[index]),
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
        duration: const Duration(milliseconds: 200),
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
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.isHighlighted,
  });

  final String title;
  final String value;
  final Color color;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? AdminColors.primary : AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AdminColors.ambientShadow,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AdminTextStyles.headlineSm.copyWith(
              color: isHighlighted ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AdminTextStyles.bodyMd.copyWith(
              color: isHighlighted ? Colors.white70 : AdminColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final _CustomerSort selected;
  final String label;
  final ValueChanged<_CustomerSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CustomerSort>(
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _CustomerSort.totalSpent,
          child: Text('Tổng chi cao nhất'),
        ),
        PopupMenuItem(
          value: _CustomerSort.totalBookings,
          child: Text('Lượt hẹn nhiều nhất'),
        ),
        PopupMenuItem(value: _CustomerSort.name, child: Text('Tên A-Z')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AdminColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AdminColors.surfaceContainerHigh),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sort_rounded,
              size: 18,
              color: AdminColors.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AdminTextStyles.bodySm.copyWith(
                color: AdminColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final AdminCustomer customer;

  @override
  Widget build(BuildContext context) {
    final tagColor = _tagColor(customer.tag);
    final tagBackground = _tagBackground(customer.tag);

    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AdminColors.ambientShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerDetailScreen(customerId: customer.id),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: tagColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AdminColors.secondaryFixed,
                              child: Text(
                                customer.name[0],
                                style: AdminTextStyles.titleLg.copyWith(
                                  color: AdminColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AdminTextStyles.titleMd,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    customer.phone,
                                    style: AdminTextStyles.bodyMd.copyWith(
                                      color: AdminColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _CustomerTag(
                              label: customer.tag,
                              color: tagColor,
                              backgroundColor: tagBackground,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _CustomerMetric(
                                icon: Icons.event_available_rounded,
                                label: 'Lượt hẹn',
                                value: '${customer.totalBookings}',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _CustomerMetric(
                                icon: Icons.payments_rounded,
                                label: 'Tổng chi',
                                value: formatAdminMoney(customer.totalSpent),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AdminColors.outline,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'VIP':
        return const Color(0xFFFF9800);
      case 'Mới':
        return AdminColors.primary;
      default:
        return AdminColors.statusCompleted;
    }
  }

  Color _tagBackground(String tag) {
    switch (tag) {
      case 'VIP':
        return AdminColors.statusPendingBg;
      case 'Mới':
        return AdminColors.statusConfirmedBg;
      default:
        return AdminColors.statusCompletedBg;
    }
  }
}

class _CustomerTag extends StatelessWidget {
  const _CustomerTag({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(label, style: AdminTextStyles.labelLg.copyWith(color: color)),
    );
  }
}

class _CustomerMetric extends StatelessWidget {
  const _CustomerMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AdminColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AdminTextStyles.labelSm.copyWith(
                  color: AdminColors.outline,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AdminTextStyles.bodyMd.copyWith(
                  color: AdminColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyCustomersState extends StatelessWidget {
  const _EmptyCustomersState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 120),
      children: [
        Icon(
          Icons.people_outline_rounded,
          size: 56,
          color: AdminColors.primary.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 16),
        Text(
          'Không có khách phù hợp',
          textAlign: TextAlign.center,
          style: AdminTextStyles.titleLg,
        ),
        const SizedBox(height: 8),
        Text(
          'Hãy đổi bộ lọc hoặc từ khóa tìm kiếm.',
          textAlign: TextAlign.center,
          style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Đặt lại bộ lọc'),
          ),
        ),
      ],
    );
  }
}
