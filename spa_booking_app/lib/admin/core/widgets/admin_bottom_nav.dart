import 'package:flutter/material.dart';
import '../../screens/bookings/bookings_screen.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/services/services_screen.dart';
import '../../screens/customers/customers_screen.dart';
import '../../screens/more/more_screen.dart';
import '../constants/admin_colors.dart';

/// Bottom Navigation Bar dùng chung cho toàn bộ Admin App.
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
              _NavItem(icon: Icons.grid_view_rounded, label: 'Tổng quan', index: 0, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.calendar_month_rounded, label: 'Lịch hẹn', index: 1, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.spa_rounded, label: 'Dịch vụ', index: 2, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.people_alt_rounded, label: 'Khách hàng', index: 3, currentIndex: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.more_horiz_rounded, label: 'Thêm', index: 4, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AdminColors.secondaryFixed : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? AdminColors.primary : AdminColors.outline,
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

/// Shell chính của Admin App – chứa bottom nav và các màn hình.
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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
