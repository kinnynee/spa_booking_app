import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/info_row.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      children: [
        Text(
          'H\u1ed3 s\u01a1',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: [
              _ProfileAvatar(imageUrl: user.avatar),
              const SizedBox(height: 14),
              Text(user.fullName, style: AppTextStyles.sectionTitle),
              const SizedBox(height: 4),
              Text(user.email, style: AppTextStyles.muted),
              const SizedBox(height: 4),
              Text(user.phone, style: AppTextStyles.muted),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: [
              InfoRow(
                icon: Icons.person_outline,
                label: 'H\u1ecd v\u00e0 t\u00ean',
                value: user.fullName,
              ),
              const SizedBox(height: 14),
              InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              const SizedBox(height: 14),
              InfoRow(
                icon: Icons.phone_outlined,
                label: 'S\u1ed1 \u0111i\u1ec7n tho\u1ea1i',
                value: user.phone,
              ),
              const SizedBox(height: 14),
              InfoRow(
                icon: Icons.cake_outlined,
                label: 'Ng\u00e0y sinh',
                value: user.displayBirthday,
              ),
              const SizedBox(height: 14),
              InfoRow(
                icon: Icons.wc_outlined,
                label: 'Gi\u1edbi t\u00ednh',
                value: user.displayGender,
              ),
              const SizedBox(height: 14),
              InfoRow(
                icon: Icons.location_on_outlined,
                label: '\u0110\u1ecba ch\u1ec9',
                value: user.displayAddress,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EditProfileScreen(isAdmin: false),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Ch\u1ec9nh s\u1eeda h\u1ed3 s\u01a1'),
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => context.read<AuthProvider>().logout(),
          icon: const Icon(Icons.logout),
          label: const Text('\u0110\u0103ng xu\u1ea5t'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: AppColors.danger,
            side: BorderSide(color: AppColors.danger.withValues(alpha: .25)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl});

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
          : const Icon(
              Icons.person_outline,
              color: AppColors.primary,
              size: 48,
            ),
    );
  }
}
