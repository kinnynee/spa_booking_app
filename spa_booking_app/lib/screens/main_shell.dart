import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/spa_service.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import 'booking/booking_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'services/service_detail_screen.dart';
import 'services/services_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  void _openServiceDetail(BuildContext context, SpaService service) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceDetailScreen(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        final authProvider = context.watch<AuthProvider>();
        final pages = [
          HomeScreen(
            onOpenService: (service) => _openServiceDetail(context, service),
          ),
          ServicesScreen(
            onOpenService: (service) => _openServiceDetail(context, service),
          ),
          const BookingScreen(),
          ProfileScreen(
            authProvider: authProvider,
            onAppointments: () => provider.setCurrentTab(2),
          ),
        ];

        return Scaffold(
          body: SafeArea(child: pages[provider.currentTabIndex]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: provider.currentTabIndex,
            onDestinationSelected: provider.setCurrentTab,
            indicatorColor: AppColors.secondary,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              NavigationDestination(
                icon: Icon(Icons.spa_outlined),
                selectedIcon: Icon(Icons.spa),
                label: 'Dịch vụ',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Lịch hẹn',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Hồ sơ',
              ),
            ],
          ),
        );
      },
    );
  }
}
