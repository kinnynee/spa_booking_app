// Thư viện Material cung cấp form, input, checkbox và navigation.
import 'package:flutter/material.dart';
// Provider dùng để gọi AuthProvider khi tạo tài khoản.
import 'package:provider/provider.dart';

// Import màu, kiểu chữ, nút chính và provider đăng ký.
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

// Màn hình đăng ký, quản lý các controller nhập liệu và checkbox điều khoản.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedPolicy = true;
  bool _hidePassword = true;

  @override
  // Hủy toàn bộ controller của form khi màn hình bị dispose.
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  // build dựng form đăng ký và trạng thái loading từ AuthProvider.
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            children: [
              Text(
                'Bắt đầu hành trình thư giãn',
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tạo tài khoản để đặt lịch nhanh hơn và theo dõi lịch hẹn của bạn.',
                textAlign: TextAlign.center,
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 8),
              const _ApiEndpointNote(),
              const SizedBox(height: 26),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!email.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Số điện thoại',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _hidePassword,
                decoration: InputDecoration(
                  hintText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _hidePassword = !_hidePassword);
                    },
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Mật khẩu cần ít nhất 8 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _hidePassword,
                decoration: const InputDecoration(
                  hintText: 'Xác nhận mật khẩu',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _acceptedPolicy,
                onChanged: auth.isLoading
                    ? null
                    : (value) {
                        setState(() => _acceptedPolicy = value ?? false);
                      },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'Tôi đồng ý với Điều khoản và Chính sách bảo mật',
                  style: AppTextStyles.muted,
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: auth.isLoading ? 'Đang xử lý...' : 'Đăng ký',
                icon: Icons.person_add_alt_1,
                onPressed: auth.isLoading ? null : _submit,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản?', style: AppTextStyles.muted),
                  TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kiểm tra điều khoản, validate form rồi gọi AuthProvider.register.
  Future<void> _submit() async {
    if (!_acceptedPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý điều khoản sử dụng')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await context.read<AuthProvider>().register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop();
      return;
    }

    final message =
        context.read<AuthProvider>().errorMessage ??
        'Đăng ký thất bại. Vui lòng thử lại.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

// Hiển thị backend URL hiện tại để dễ kiểm tra app đang gọi đúng API.
class _ApiEndpointNote extends StatelessWidget {
  const _ApiEndpointNote();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SelectableText(
        'API: ${ApiClient.instance.baseUrl}/auth/register',
        style: AppTextStyles.muted.copyWith(fontSize: 12),
      ),
    );
  }
}
