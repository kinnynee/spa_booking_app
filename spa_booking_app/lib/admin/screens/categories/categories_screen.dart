import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_category_provider.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../core/widgets/admin_app_bar.dart';
import '../../models/admin_category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _filterIndex = 0;
  String _searchQuery = '';

  final List<String> _filters = const [
    'T\u1ea5t c\u1ea3',
    '\u0110ang ho\u1ea1t \u0111\u1ed9ng',
    'T\u1ea1m \u1ea9n',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AdminCategoryProvider>().loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminCategory> _filtered(List<AdminCategory> categories) {
    var list = categories;
    if (_filterIndex == 1) {
      list = list.where((category) => category.isActive).toList();
    }
    if (_filterIndex == 2) {
      list = list.where((category) => !category.isActive).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final keyword = _searchQuery.toLowerCase().trim();
      list = list
          .where(
            (category) =>
                category.name.toLowerCase().contains(keyword) ||
                category.slug.toLowerCase().contains(keyword) ||
                category.description.toLowerCase().contains(keyword),
          )
          .toList();
    }
    return list;
  }

  Future<void> _openForm({AdminCategory? category}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AdminColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CategoryFormSheet(category: category),
    );

    if (!mounted || result != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          category == null
              ? '\u0110\u00e3 th\u00eam danh m\u1ee5c.'
              : '\u0110\u00e3 c\u1eadp nh\u1eadt danh m\u1ee5c.',
        ),
        backgroundColor: AdminColors.statusCompleted,
      ),
    );
  }

  Future<void> _toggleStatus(AdminCategory category, bool value) async {
    final provider = context.read<AdminCategoryProvider>();
    final ok = await provider.updateCategory(
      category,
      name: category.name,
      slug: category.slug,
      description: category.description,
      sortOrder: category.sortOrder,
      isActive: value,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '\u0110\u00e3 c\u1eadp nh\u1eadt tr\u1ea1ng th\u00e1i danh m\u1ee5c.'
              : provider.errorMessage ??
                    'Kh\u00f4ng th\u1ec3 c\u1eadp nh\u1eadt danh m\u1ee5c.',
        ),
        backgroundColor: ok
            ? AdminColors.statusCompleted
            : AdminColors.statusCancelled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCategoryProvider>();
    final categories = _filtered(provider.categories);
    final activeCount = provider.categories
        .where((item) => item.isActive)
        .length;
    final inactiveCount = provider.categories.length - activeCount;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AdminAppBar(
        title: 'Danh m\u1ee5c',
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: 'T\u1ea3i l\u1ea1i',
            onPressed: () => provider.loadCategories(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Th\u00eam'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadCategories(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                    label: '\u0110ang ho\u1ea1t \u0111\u1ed9ng',
                    value: activeCount.toString(),
                    color: AdminColors.statusCompleted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatPill(
                    label: 'T\u1ea1m \u1ea9n',
                    value: inactiveCount.toString(),
                    color: AdminColors.statusPending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: AdminTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'T\u00ecm danh m\u1ee5c...',
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
            if (provider.isLoading && !provider.hasLoaded)
              const Padding(
                padding: EdgeInsets.only(top: 96),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null &&
                provider.categories.isEmpty)
              _MessageState(
                icon: Icons.wifi_off_rounded,
                title: 'Ch\u01b0a t\u1ea3i \u0111\u01b0\u1ee3c danh m\u1ee5c',
                message: provider.errorMessage!,
                actionLabel: 'Th\u1eed l\u1ea1i',
                onAction: () => provider.loadCategories(refresh: true),
              )
            else if (categories.isEmpty)
              const _MessageState(
                icon: Icons.category_outlined,
                title: 'Kh\u00f4ng c\u00f3 danh m\u1ee5c ph\u00f9 h\u1ee3p',
                message:
                    'H\u00e3y th\u00eam danh m\u1ee5c m\u1edbi ho\u1eb7c \u0111\u1ed5i b\u1ed9 l\u1ecdc.',
              )
            else
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CategoryCard(
                    category: category,
                    onEdit: () => _openForm(category: category),
                    onStatusChanged: (value) => _toggleStatus(category, value),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AdminColors.ambientShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.category_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AdminTextStyles.headlineSm),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AdminTextStyles.bodySm.copyWith(
                    color: AdminColors.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onStatusChanged,
  });

  final AdminCategory category;
  final VoidCallback onEdit;
  final ValueChanged<bool> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final statusColor = category.isActive
        ? AdminColors.statusCompleted
        : AdminColors.statusPending;
    final statusBg = category.isActive
        ? AdminColors.statusCompletedBg
        : AdminColors.statusPendingBg;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AdminColors.ambientShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AdminColors.secondaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: AdminColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: AdminTextStyles.titleMd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.slug,
                      style: AdminTextStyles.bodySm.copyWith(
                        color: AdminColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Ch\u1ec9nh s\u1eeda',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: AdminColors.primary,
              ),
            ],
          ),
          if (category.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              category.description,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  category.isActive
                      ? '\u0110ang ho\u1ea1t \u0111\u1ed9ng'
                      : 'T\u1ea1m \u1ea9n',
                  style: AdminTextStyles.labelSm.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Th\u1ee9 t\u1ef1: ${category.sortOrder}',
                style: AdminTextStyles.bodySm.copyWith(
                  color: AdminColors.outline,
                ),
              ),
              const Spacer(),
              Switch(
                value: category.isActive,
                onChanged: onStatusChanged,
                activeThumbColor: AdminColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  const _CategoryFormSheet({this.category});

  final AdminCategory? category;

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _sortCtrl;
  late bool _isActive;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _nameCtrl = TextEditingController(text: category?.name ?? '');
    _slugCtrl = TextEditingController(text: category?.slug ?? '');
    _descriptionCtrl = TextEditingController(text: category?.description ?? '');
    _sortCtrl = TextEditingController(
      text: (category?.sortOrder ?? 0).toString(),
    );
    _isActive = category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _descriptionCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<AdminCategoryProvider>();
    final sortOrder = int.tryParse(_sortCtrl.text.trim()) ?? 0;
    final category = widget.category;
    final ok = category == null
        ? await provider.createCategory(
            name: _nameCtrl.text,
            slug: _slugCtrl.text,
            description: _descriptionCtrl.text,
            sortOrder: sortOrder,
            isActive: _isActive,
          )
        : await provider.updateCategory(
            category,
            name: _nameCtrl.text,
            slug: _slugCtrl.text,
            description: _descriptionCtrl.text,
            sortOrder: sortOrder,
            isActive: _isActive,
          );

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ??
              'Kh\u00f4ng th\u1ec3 l\u01b0u danh m\u1ee5c.',
        ),
        backgroundColor: AdminColors.statusCancelled,
      ),
    );
  }

  Future<void> _archive() async {
    final category = widget.category;
    if (category == null) {
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('\u1ea8n danh m\u1ee5c?'),
        content: Text(
          'Danh m\u1ee5c "${category.name}" s\u1ebd kh\u00f4ng c\u00f2n hi\u1ec3n th\u1ecb cho kh\u00e1ch h\u00e0ng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('H\u1ee7y'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AdminColors.statusCancelled,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('\u1ea8n'),
          ),
        ],
      ),
    );

    if (accepted != true || !mounted) {
      return;
    }

    final provider = context.read<AdminCategoryProvider>();
    final ok = await provider.archiveCategory(category);

    if (!mounted) {
      return;
    }

    if (ok) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ?? 'Kh\u00f4ng th\u1ec3 \u1ea9n danh m\u1ee5c.',
        ),
        backgroundColor: AdminColors.statusCancelled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminCategoryProvider>();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _isEdit
                        ? 'Ch\u1ec9nh s\u1eeda danh m\u1ee5c'
                        : 'Th\u00eam danh m\u1ee5c',
                    style: AdminTextStyles.titleLg,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FormField(
                controller: _nameCtrl,
                label: 'T\u00ean danh m\u1ee5c',
                hint: 'VD: Massage body',
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Nh\u1eadp t\u00ean danh m\u1ee5c';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _FormField(
                controller: _slugCtrl,
                label: 'Slug',
                hint: 'massage-body',
              ),
              const SizedBox(height: 14),
              _FormField(
                controller: _descriptionCtrl,
                label: 'M\u00f4 t\u1ea3',
                hint: 'M\u00f4 t\u1ea3 ng\u1eafn cho danh m\u1ee5c',
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              _FormField(
                controller: _sortCtrl,
                label: 'Th\u1ee9 t\u1ef1 hi\u1ec3n th\u1ecb',
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed < 0) {
                    return 'Nh\u1eadp s\u1ed1 th\u1ee9 t\u1ef1 h\u1ee3p l\u1ec7';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AdminColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.surfaceContainerHigh),
                ),
                child: Row(
                  children: [
                    Text(
                      '\u0110ang ho\u1ea1t \u0111\u1ed9ng',
                      style: AdminTextStyles.titleMd,
                    ),
                    const Spacer(),
                    Switch(
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      activeThumbColor: AdminColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_isEdit) ...[
                    IconButton.filledTonal(
                      onPressed: provider.isSaving ? null : _archive,
                      icon: const Icon(Icons.visibility_off_outlined),
                      color: AdminColors.statusCancelled,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: provider.isSaving ? null : _submit,
                      icon: provider.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: Text(
                        _isEdit
                            ? 'L\u01b0u thay \u0111\u1ed5i'
                            : 'Th\u00eam danh m\u1ee5c',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                        textStyle: AdminTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AdminTextStyles.bodyMd.copyWith(
              color: AdminColors.outline,
            ),
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

class _MessageState extends StatelessWidget {
  const _MessageState({
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
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: AdminColors.outline),
          const SizedBox(height: 12),
          Text(
            title,
            style: AdminTextStyles.titleMd,
            textAlign: TextAlign.center,
          ),
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
