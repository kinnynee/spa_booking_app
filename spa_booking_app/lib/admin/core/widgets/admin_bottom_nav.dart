import 'package:flutter/material.dart';

import '../../screens/bookings/bookings_screen.dart';
import '../../screens/customers/customers_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/more/more_screen.dart';
import '../../screens/services/services_screen.dart';
import '../constants/admin_colors.dart';
import '../../../core/constants/app_assets.dart';

/// Bottom navigation dùng chung cho toàn bộ Admin App.
class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A46B2).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(asset: AppAssets.navHome, label: 'Tổng quan', index: 0, currentIndex: currentIndex, onTap: onTap),
              _NavItem(asset: AppAssets.navCalendar, label: 'Lịch hẹn', index: 1, currentIndex: currentIndex, onTap: onTap),
              _NavItem(asset: AppAssets.navService, label: 'Dịch vụ', index: 2, currentIndex: currentIndex, onTap: onTap),
              _NavItem(asset: AppAssets.navProfile, label: 'Khách hàng', index: 3, currentIndex: currentIndex, onTap: onTap),
              _NavItem(asset: AppAssets.navHome, label: 'Thêm', index: 4, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.asset,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final String asset;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AdminColors.secondaryFixed : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: isSelected ? 1 : .58,
                child: Image.asset(
                  asset,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.image_not_supported_outlined,
                    size: 20,
                    color: isSelected ? AdminColors.primary : AdminColors.outline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'BeVietnamPro',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AdminColors.primary : AdminColors.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    BookingsScreen(),
    ServicesScreen(),
    CustomersScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}