import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../core/widgets/admin_app_bar.dart';
import '../../../providers/auth_provider.dart';
import '../../../screens/profile/edit_profile_screen.dart';
import '../categories/categories_screen.dart';
import 'spa_settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AdminAppBar(title: 'Lavender Spa', showMenuIcon: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AdminColors.secondaryFixed,
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: AdminColors.primary,
                        size: 40,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AdminColors.background,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(user.fullName, style: AdminTextStyles.titleLg),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AdminTextStyles.bodyMd.copyWith(
                    color: AdminColors.outline,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AdminColors.primary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Quản trị viên',
                        style: AdminTextStyles.labelSm.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AdminColors.surfaceContainerHigh,
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'Online',
                        style: AdminTextStyles.labelSm.copyWith(
                          color: AdminColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Quick Action Cards
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.local_offer_rounded,
                  title: 'Khuyến mãi',
                  color: const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Doanh thu',
                  color: AdminColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Menu List
          Container(
            decoration: BoxDecoration(
              color: AdminColors.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AdminColors.ambientShadow,
            ),
            child: Column(
              children: [
                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  title: 'H\u1ed3 s\u01a1 qu\u1ea3n tr\u1ecb',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(isAdmin: true),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.settings_rounded,
                  title: 'Cài đặt Spa',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SpaSettingsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.category_rounded,
                  title: 'Danh m\u1ee5c',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Thông báo',
                  hasDot: true,
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _MenuTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Trợ giúp & Hỗ trợ',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Logout Button
          TextButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            style: TextButton.styleFrom(
              foregroundColor: AdminColors.statusCancelled,
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AdminColors.statusCancelledBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Đăng xuất',
              style: AdminTextStyles.titleMd.copyWith(
                color: AdminColors.statusCancelled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
  });
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AdminColors.ambientShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: AdminTextStyles.titleMd),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.hasDot = false,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool hasDot;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AdminColors.onSurfaceVariant),
      title: Text(
        title,
        style: AdminTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDot)
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AdminColors.statusCancelled,
                shape: BoxShape.circle,
              ),
            ),
          const Icon(Icons.chevron_right_rounded, color: AdminColors.outline),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
