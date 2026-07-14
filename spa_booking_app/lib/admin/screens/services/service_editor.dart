import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_category_provider.dart';
import '../../../providers/admin_spa_service_provider.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../models/admin_spa_service.dart';

class AdminServiceEditor extends StatefulWidget {
  const AdminServiceEditor({super.key, this.service});

  final AdminSpaService? service;

  @override
  State<AdminServiceEditor> createState() => _AdminServiceEditorState();
}

class _AdminServiceEditorState extends State<AdminServiceEditor> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  String? _categoryId;
  Uint8List? _selectedImageBytes;
  bool _isUploadingImage = false;
  late bool _isActive;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _nameController = TextEditingController(text: service?.name ?? '');
    _priceController = TextEditingController(
      text: service == null ? '' : service.price.toString(),
    );
    _durationController = TextEditingController(
      text: service == null ? '60' : service.durationMinutes.toString(),
    );
    _descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    _imageUrlController = TextEditingController(text: service?.imageUrl ?? '');
    _categoryId = service?.categoryId;
    _isActive = service?.isActive ?? true;

    Future.microtask(() {
      if (mounted) {
        context.read<AdminCategoryProvider>().loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _chooseImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Chụp ảnh mới'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final serviceProvider = context.read<AdminSpaServiceProvider>();

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (picked == null || !mounted) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _isUploadingImage = true;
      });

      final imageUrl = await serviceProvider.uploadImage(
        bytes: bytes,
        contentType: _contentTypeFor(picked.name),
      );
      if (!mounted) return;

      setState(() => _isUploadingImage = false);
      if (imageUrl != null) {
        _imageUrlController.text = imageUrl;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tải ảnh lên.'),
            backgroundColor: AdminColors.statusCompleted,
          ),
        );
      } else {
        _showError('Không thể tải ảnh lên.');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isUploadingImage = false);
      _showError(error.toString());
    }
  }

  String _contentTypeFor(String name) {
    final extension = name.toLowerCase().split('.').last;
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AdminColors.statusCancelled,
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isUploadingImage) return;

    final categoryId = _categoryId;
    if (categoryId == null) return;

    final provider = context.read<AdminSpaServiceProvider>();
    final price = int.parse(_priceController.text.trim());
    final duration = int.parse(_durationController.text.trim());
    final service = widget.service;
    final saved = service == null
        ? await provider.createService(
            categoryId: categoryId,
            name: _nameController.text,
            price: price,
            durationMinutes: duration,
            description: _descriptionController.text,
            imageUrl: _imageUrlController.text,
            isActive: _isActive,
          )
        : await provider.updateService(
            service,
            categoryId: categoryId,
            name: _nameController.text,
            price: price,
            durationMinutes: duration,
            description: _descriptionController.text,
            imageUrl: _imageUrlController.text,
            isActive: _isActive,
          );

    if (!mounted) return;
    if (saved) {
      Navigator.pop(context, true);
    } else {
      _showError(provider.errorMessage ?? 'Không thể lưu dịch vụ.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<AdminCategoryProvider>();
    final serviceProvider = context.watch<AdminSpaServiceProvider>();
    final categories = categoryProvider.categories
        .where((category) => category.isActive)
        .toList();
    final hasSelectedCategory = categories.any(
      (category) => category.id == _categoryId,
    );

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AdminColors.primary,
          onPressed: serviceProvider.isSaving || _isUploadingImage
              ? null
              : () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Chỉnh sửa dịch vụ' : 'Thêm dịch vụ mới',
          style: AdminTextStyles.titleLg,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _ImagePicker(
              imageBytes: _selectedImageBytes,
              imageUrl: _imageUrlController.text,
              uploading: _isUploadingImage,
              onTap: _chooseImage,
            ),
            const SizedBox(height: 24),
            Text('THÔNG TIN CƠ BẢN', style: AdminTextStyles.labelLg),
            const SizedBox(height: 12),
            _ServiceTextField(
              controller: _nameController,
              label: 'Tên dịch vụ',
              hint: 'Nhập tên dịch vụ',
              textCapitalization: TextCapitalization.words,
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Tên dịch vụ cần có ít nhất 2 ký tự'
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              'Danh mục',
              style: AdminTextStyles.bodyMd.copyWith(
                color: AdminColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey('category-${hasSelectedCategory ? _categoryId : 'none'}'),
              initialValue: hasSelectedCategory ? _categoryId : null,
              isExpanded: true,
              onChanged: serviceProvider.isSaving || categories.isEmpty
                  ? null
                  : (value) => setState(() => _categoryId = value),
              validator: (value) => value == null ? 'Hãy chọn danh mục' : null,
              decoration: _inputDecoration('Chọn danh mục'),
              items: categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
            ),
            if (categoryProvider.isLoading && !categoryProvider.hasLoaded)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(),
              )
            else if (categoryProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  categoryProvider.errorMessage!,
                  style: AdminTextStyles.bodySm.copyWith(
                    color: AdminColors.statusCancelled,
                  ),
                ),
              )
            else if (categoryProvider.hasLoaded && categories.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Cần có ít nhất một danh mục đang hoạt động để thêm dịch vụ.',
                  style: AdminTextStyles.bodySm.copyWith(
                    color: AdminColors.statusCancelled,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ServiceTextField(
                    controller: _priceController,
                    label: 'Giá (VNĐ)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final price = int.tryParse(value?.trim() ?? '');
                      return price == null || price < 0 ? 'Nhập giá hợp lệ' : null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ServiceTextField(
                    controller: _durationController,
                    label: 'Thời lượng (phút)',
                    hint: '60',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final duration = int.tryParse(value?.trim() ?? '');
                      return duration == null || duration < 15 || duration > 480
                          ? '15–480 phút'
                          : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('MÔ TẢ DỊCH VỤ', style: AdminTextStyles.labelLg),
            const SizedBox(height: 12),
            _ServiceTextField(
              controller: _descriptionController,
              label: 'Mô tả',
              hint: 'Giới thiệu ngắn về liệu trình...',
              maxLines: 4,
              validator: (value) => (value?.trim().length ?? 0) > 4000
                  ? 'Mô tả không được vượt quá 4.000 ký tự'
                  : null,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AdminColors.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AdminColors.ambientShadow,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Hiển thị dịch vụ cho khách'),
                  ),
                  Switch(
                    value: _isActive,
                    onChanged: serviceProvider.isSaving || _isUploadingImage
                        ? null
                        : (value) => setState(() => _isActive = value),
                    activeThumbColor: AdminColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              onPressed: serviceProvider.isSaving ||
                      _isUploadingImage ||
                      categories.isEmpty
                  ? null
                  : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AdminColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              icon: serviceProvider.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _isEditing ? 'Lưu thay đổi' : 'Thêm dịch vụ',
                style: AdminTextStyles.titleMd.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
    filled: true,
    fillColor: AdminColors.surfaceWhite,
    contentPadding: const EdgeInsets.all(16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AdminColors.surfaceContainerHigh),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AdminColors.surfaceContainerHigh),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AdminColors.primary),
    ),
  );
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.imageBytes,
    required this.imageUrl,
    required this.uploading,
    required this.onTap,
  });

  final Uint8List? imageBytes;
  final String imageUrl;
  final bool uploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(imageUrl);
    final hasUrl = uri != null && uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
    Widget content;
    if (imageBytes != null) {
      content = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (hasUrl) {
      content = Image.network(imageUrl, fit: BoxFit.cover);
    } else {
      content = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_rounded, size: 48, color: AdminColors.primary),
          SizedBox(height: 8),
          Text(
            'Chạm để chọn ảnh từ điện thoại',
            style: TextStyle(color: AdminColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return Material(
      color: AdminColors.surfaceWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: uploading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminColors.primary, width: 1.5),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [content, if (uploading) _uploadOverlay()],
          ),
        ),
      ),
    );
  }

  Widget _uploadOverlay() => Container(
    color: Colors.black45,
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 10),
          Text('Đang tải ảnh...', style: TextStyle(color: Colors.white)),
        ],
      ),
    ),
  );
}

class _ServiceTextField extends StatelessWidget {
  const _ServiceTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.onSurfaceVariant),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
          filled: true,
          fillColor: AdminColors.surfaceWhite,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AdminColors.surfaceContainerHigh),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AdminColors.surfaceContainerHigh),
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