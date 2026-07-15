import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthdayController;
  late final TextEditingController _addressController;
  late final TextEditingController _avatarController;
  String _gender = '';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user.fullName);
    _phoneController = TextEditingController(text: user.phone);
    _birthdayController = TextEditingController(text: user.birthday);
    _addressController = TextEditingController(text: user.address);
    _avatarController = TextEditingController(text: user.avatar);
    _gender = user.genderCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final title = widget.isAdmin
        ? '\u0048\u1ed3 s\u01a1 qu\u1ea3n tr\u1ecb'
        : 'Ch\u1ec9nh s\u1eeda h\u1ed3 s\u01a1';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Center(child: _AvatarPreview(imageUrl: _avatarController.text)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'H\u1ecd v\u00e0 t\u00ean',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Vui l\u00f2ng nh\u1eadp h\u1ecd t\u00ean h\u1ee3p l\u1ec7.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: user.email,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'S\u1ed1 \u0111i\u1ec7n tho\u1ea1i',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _birthdayController,
                readOnly: true,
                onTap: _pickBirthday,
                decoration: const InputDecoration(
                  labelText: 'Ng\u00e0y sinh',
                  prefixIcon: Icon(Icons.cake_outlined),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _gender.isEmpty ? null : _gender,
                decoration: const InputDecoration(
                  labelText: 'Gi\u1edbi t\u00ednh',
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Nam')),
                  DropdownMenuItem(value: 'female', child: Text('N\u1eef')),
                  DropdownMenuItem(value: 'other', child: Text('Kh\u00e1c')),
                ],
                onChanged: (value) => setState(() => _gender = value ?? ''),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '\u0110\u1ecba ch\u1ec9',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _avatarController,
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'URL \u1ea3nh \u0111\u1ea1i di\u1ec7n',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: auth.isLoading ? null : _save,
                icon: auth.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  auth.isLoading
                      ? '\u0110ang l\u01b0u...'
                      : 'L\u01b0u h\u1ed3 s\u01a1',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthday() async {
    final initial =
        DateTime.tryParse(_birthdayController.text) ?? DateTime(1995);
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    setState(() {
      _birthdayController.text = [
        date.year.toString().padLeft(4, '0'),
        date.month.toString().padLeft(2, '0'),
        date.day.toString().padLeft(2, '0'),
      ].join('-');
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().updateProfile(
      fullName: _nameController.text,
      phone: _phoneController.text,
      birthDate: _birthdayController.text,
      gender: _gender,
      address: _addressController.text,
      avatarUrl: _avatarController.text,
    );
    if (!mounted) return;
    if (!success) {
      final message =
          context.read<AuthProvider>().errorMessage ??
          'Kh\u00f4ng th\u1ec3 l\u01b0u h\u1ed3 s\u01a1.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'H\u1ed3 s\u01a1 \u0111\u00e3 \u0111\u01b0\u1ee3c c\u1eadp nh\u1eadt.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = Uri.tryParse(imageUrl)?.hasAbsolutePath == true;
    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.secondary,
      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
      child: hasImage
          ? null
          : const Icon(Icons.person, size: 48, color: AppColors.primary),
    );
  }
}
