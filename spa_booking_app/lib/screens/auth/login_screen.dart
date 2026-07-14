// Thư viện Material cung cấp form, input, button và navigation.
import 'package:flutter/material.dart';
// Provider dùng để đọc/gọi AuthProvider trong màn đăng nhập.
import 'package:provider/provider.dart';

// Import asset, style, widget dùng chung, provider và màn đăng ký.
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/config/google_auth_config.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/google_sign_in_button.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

// Màn hình đăng nhập, lưu state của form và trạng thái ẩn/hiện mật khẩu.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController(text: 'admin@local.spa');
  final _passwordController = TextEditingController(text: 'Admin@12345');
  bool _hidePassword = true;

  @override
  // Hủy controller khi rời màn để tránh rò rỉ tài nguyên.
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  // build dựng phần giao diện của widget trong màn đăng nhập.
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
          children: [
            const _AuthHero(),
            const SizedBox(height: 28),
            Text(
              'Chào mừng trở lại',
              style: AppTextStyles.title.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            const Text(
              'Đăng nhập để đặt lịch và quản lý lịch hẹn tại Lavender Spa.',
              style: AppTextStyles.muted,
            ),
            const SizedBox(height: 8),
            const _ApiEndpointNote(),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _accountController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (value) {
                      final account = value?.trim() ?? '';
                      if (account.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!account.contains('@')) {
                        return 'Email không hợp lệ';
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
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: auth.isLoading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng đang phát triển'),
                          ),
                        );
                      },
                child: const Text('Quên mật khẩu?'),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: auth.isLoading ? 'Đang xử lý...' : 'Đăng nhập',
              icon: Icons.login,
              onPressed: auth.isLoading ? null : _submit,
            ),
            if (GoogleAuthConfig.isSupportedOnCurrentPlatform) ...[
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ho\u1eb7c'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 18),
              GoogleSignInButton(
                onPressed: auth.isLoading
                    ? null
                    : () async {
                        final success = await context
                            .read<AuthProvider>()
                            .loginWithGoogle();
                        if (!context.mounted || success) {
                          return;
                        }
                        final message =
                            context.read<AuthProvider>().errorMessage ??
                            '\u0110\u0103ng nh\u1eadp Google th\u1ea5t b\u1ea1i. Vui l\u00f2ng th\u1eed l\u1ea1i.';
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      },
                isLoading: auth.isLoading,
              ),
              if (auth.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  auth.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
            ],
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Chưa có tài khoản?', style: AppTextStyles.muted),
                TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                  child: const Text('Đăng ký ngay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Validate form rồi gọi AuthProvider.login; nếu thất bại thì hiện SnackBar.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await context.read<AuthProvider>().login(
      account: _accountController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted || success) {
      return;
    }

    final message =
        context.read<AuthProvider>().errorMessage ??
        'Đăng nhập thất bại. Vui lòng thử lại.';
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
    return SelectableText(
      'API: ${ApiClient.instance.baseUrl}/auth/login',
      style: AppTextStyles.muted.copyWith(fontSize: 12),
    );
  }
}

// Ảnh hero đầu màn đăng nhập, có fallback icon khi asset lỗi.
class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  // build dựng phần giao diện của widget trong màn đăng nhập.
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 210,
        width: double.infinity,
        child: Image.asset(
          AppAssets.loginHero,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.secondary,
              alignment: Alignment.center,
              child: const Icon(Icons.spa, color: AppColors.primary, size: 72),
            );
          },
        ),
      ),
    );
  }
}
