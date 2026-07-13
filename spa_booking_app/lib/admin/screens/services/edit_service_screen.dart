import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../models/admin_mock_data.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key, this.serviceId});
  final String? serviceId;

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _shortDescCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();

  late String _category;
  late bool _isActive;
  late String _imageUrl;

  final List<String> _categories = const [
    'Massage',
    'Facial',
    'Tóc',
    'Body',
    'Combo',
  ];

  AdminService? get _editingService {
    for (final service in mockAdminServices) {
      if (service.id == widget.serviceId) return service;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final service = _editingService;

    _category = service?.category ?? _categories.first;
    _isActive = service?.isActive ?? true;
    _imageUrl = service?.imageUrl ?? mockAdminServices.first.imageUrl;

    _nameCtrl.text = service?.name ?? '';
    _priceCtrl.text = service == null ? '' : service.price.toString();
    _durationCtrl.text = service == null
        ? '60'
        : service.durationMinutes.toString();
    _shortDescCtrl.text = service?.description ?? '';
    _detailCtrl.text = service == null
        ? ''
        : '${service.description}\n\nPhù hợp cho khách muốn thư giãn và phục hồi năng lượng sau một ngày dài.';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _shortDescCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.serviceId != null;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AdminColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Chỉnh sửa dịch vụ' : 'Thêm dịch vụ',
          style: AdminTextStyles.headlineSm.copyWith(
            color: AdminColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AdminColors.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: _EditorBottomBar(onSave: _saveService),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _ImageUploadCard(
            imageUrl: _imageUrl,
            onChange: () {
              setState(() {
                _imageUrl = mockAdminServices[1].imageUrl;
              });
            },
          ),
          const SizedBox(height: 22),
          _SectionHeader(
            icon: Icons.info_outline_rounded,
            label: 'THÔNG TIN CƠ BẢN',
          ),
          const SizedBox(height: 10),
          _SectionCard(
            children: [
              TextField(
                controller: _nameCtrl,
                style: AdminTextStyles.bodyMd,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration('Tên dịch vụ', Icons.spa_outlined),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _fieldDecoration(
                  'Danh mục',
                  Icons.category_outlined,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AdminColors.outline,
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category, style: AdminTextStyles.bodyMd),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceCtrl,
                      style: AdminTextStyles.bodyMd,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _fieldDecoration(
                        'Giá',
                        Icons.payments_outlined,
                      ).copyWith(suffixText: 'đ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _durationCtrl,
                      style: AdminTextStyles.bodyMd,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _fieldDecoration(
                        'Thời lượng',
                        Icons.schedule_rounded,
                      ).copyWith(suffixText: 'phút'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeader(icon: Icons.notes_rounded, label: 'MÔ TẢ DỊCH VỤ'),
          const SizedBox(height: 10),
          _SectionCard(
            children: [
              TextField(
                controller: _shortDescCtrl,
                style: AdminTextStyles.bodyMd,
                maxLines: 2,
                decoration: _fieldDecoration(
                  'Mô tả ngắn',
                  Icons.short_text_rounded,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _detailCtrl,
                style: AdminTextStyles.bodyMd,
                minLines: 5,
                maxLines: 7,
                decoration: _fieldDecoration(
                  'Mô tả chi tiết',
                  Icons.article_outlined,
                ).copyWith(alignLabelWithHint: true),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SectionHeader(icon: Icons.tune_rounded, label: 'CÀI ĐẶT'),
          const SizedBox(height: 10),
          _SectionCard(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AdminColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.visibility_rounded,
                      color: AdminColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trạng thái hoạt động',
                          style: AdminTextStyles.titleMd,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isActive
                              ? 'Khách hàng có thể đặt dịch vụ này'
                              : 'Dịch vụ đang được tạm ẩn',
                          style: AdminTextStyles.bodySm,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isActive,
                    activeThumbColor: AdminColors.primary,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
      prefixIcon: Icon(icon, color: AdminColors.outline, size: 20),
      filled: true,
      fillColor: AdminColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
      ),
    );
  }

  void _saveService() {
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập tên dịch vụ');
      return;
    }

    if (_priceCtrl.text.trim().isEmpty || _durationCtrl.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập giá và thời lượng');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu dịch vụ thành công!'),
        backgroundColor: AdminColors.statusCompleted,
      ),
    );
    Navigator.pop(context);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ImageUploadCard extends StatelessWidget {
  const _ImageUploadCard({required this.imageUrl, required this.onChange});

  final String imageUrl;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AdminColors.ambientShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: AdminColors.secondaryFixed,
              child: const Icon(
                Icons.image_outlined,
                size: 48,
                color: AdminColors.primary,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.42),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ảnh dịch vụ',
                  style: AdminTextStyles.labelLg.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tỉ lệ 16:9, rõ nét',
                  style: AdminTextStyles.titleMd.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            right: 14,
            bottom: 14,
            child: FilledButton.icon(
              onPressed: onChange,
              style: FilledButton.styleFrom(
                backgroundColor: AdminColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              icon: const Icon(Icons.photo_camera_rounded, size: 18),
              label: Text(
                'Thay đổi ảnh',
                style: AdminTextStyles.bodySm.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AdminColors.primary),
        const SizedBox(width: 8),
        Text(label, style: AdminTextStyles.labelLg),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AdminColors.ambientShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _EditorBottomBar extends StatelessWidget {
  const _EditorBottomBar({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: onSave,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AdminColors.primary,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Lưu dịch vụ',
                  style: AdminTextStyles.titleMd.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
