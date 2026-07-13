import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../core/widgets/admin_app_bar.dart';
import 'spa_settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: const AdminAppBar(title: 'Lavender Spa', showMenuIcon: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          const _AdminProfile(),
          const SizedBox(height: 22),
          const _QuickStatsCard(),
          const SizedBox(height: 18),
          _MenuCard(
            children: [
              _MenuTile(
                icon: Icons.storefront_rounded,
                title: 'Cài đặt spa',
                subtitle: 'Thông tin tiệm, giờ mở cửa',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SpaSettingsScreen(),
                    ),
                  );
                },
              ),
              const _MenuDivider(),
              _MenuTile(
                icon: Icons.notifications_none_rounded,
                title: 'Thông báo',
                subtitle: 'Cập nhật đặt lịch và hệ thống',
                showDot: true,
                onTap: () {},
              ),
              const _MenuDivider(),
              _MenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Trợ giúp',
                subtitle: 'Hướng dẫn vận hành admin app',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _LogoutButton(),
        ],
      ),
    );
  }
}

class _AdminProfile extends StatelessWidget {
  const _AdminProfile();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ProfileAvatar(),
        const SizedBox(height: 14),
        Text('Nguyễn Hưng', style: AdminTextStyles.headlineMd),
        const SizedBox(height: 4),
        Text('admin@lavenderspa.vn', style: AdminTextStyles.bodyMd),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _ProfileChip(label: 'Quản trị viên', filled: true),
            SizedBox(width: 8),
            _ProfileChip(label: 'Online', filled: false),
          ],
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 104,
          height: 104,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AdminColors.surfaceWhite,
            boxShadow: AdminColors.ambientShadow,
          ),
          child: const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/240?img=12'),
            backgroundColor: AdminColors.secondaryFixed,
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AdminColors.statusCompleted,
              border: Border.all(color: AdminColors.surfaceWhite, width: 3),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? AdminColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: filled
              ? AdminColors.primary
              : AdminColors.surfaceContainerHigh,
        ),
      ),
      child: Text(
        label,
        style: AdminTextStyles.bodySm.copyWith(
          color: filled ? Colors.white : AdminColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  const _QuickStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AdminColors.ambientShadow,
      ),
      child: Row(
        children: const [
          Expanded(
            child: _QuickStat(
              icon: Icons.confirmation_number_outlined,
              label: 'Khuyến mãi',
              value: '08',
              tone: AdminColors.statusPending,
            ),
          ),
          SizedBox(
            height: 54,
            child: VerticalDivider(color: AdminColors.surfaceContainerHigh),
          ),
          Expanded(
            child: _QuickStat(
              icon: Icons.trending_up_rounded,
              label: 'Doanh thu',
              value: '18.5tr',
              tone: AdminColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: tone, size: 22),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AdminTextStyles.titleLg),
              const SizedBox(height: 2),
              Text(
                label,
                style: AdminTextStyles.bodySm,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AdminColors.ambientShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AdminColors.secondaryFixed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AdminColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AdminTextStyles.titleMd,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (showDot) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AdminColors.statusCancelled,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AdminTextStyles.bodySm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AdminColors.outline),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 70,
      endIndent: 16,
      color: AdminColors.surfaceContainerHigh,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AdminColors.statusCancelledBg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AdminColors.statusCancelled,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: AdminTextStyles.titleMd.copyWith(
                color: AdminColors.statusCancelled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
