import 'package:flutter/material.dart';
import '../constants/admin_colors.dart';
import '../constants/admin_text_styles.dart';

/// AppBar dùng chung cho Admin – hỗ trợ title, actions và menu icon.
class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminAppBar({
    super.key,
    required this.title,
    this.showMenuIcon = false,
    this.showBackButton = false,
    this.actions,
  });

  final String title;
  final bool showMenuIcon;
  final bool showBackButton;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AdminColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AdminColors.primary,
              onPressed: () => Navigator.of(context).pop(),
            )
          : showMenuIcon
              ? IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: AdminColors.onSurfaceVariant,
                  onPressed: () {},
                )
              : null,
      title: Text(title, style: AdminTextStyles.headlineSm.copyWith(color: AdminColors.primary)),
      centerTitle: false,
      actions: [
        if (actions != null) ...actions!,
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          color: AdminColors.onSurfaceVariant,
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
