import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_booking_provider.dart';
import '../../../providers/admin_spa_service_provider.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../../core/constants/app_assets.dart';
import '../../models/admin_mock_data.dart';
import '../../models/admin_spa_service.dart';
import '../bookings/booking_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AdminBookingProvider>().loadBookings();
        context.read<AdminSpaServiceProvider>().loadServices();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<AdminBookingProvider>();
    final serviceProvider = context.watch<AdminSpaServiceProvider>();
    final bookings = bookingProvider.bookings;
    final activeServices = serviceProvider.services
        .where((service) => service.isActive)
        .toList();
    final popularServices = [
      ...activeServices.where((service) => service.isPopular),
      ...activeServices.where((service) => !service.isPopular),
    ];
    final upcoming = bookings
        .where(
          (booking) =>
              booking.status == AdminBookingStatus.pending ||
              booking.status == AdminBookingStatus.confirmed,
        )
        .take(3)
        .toList();
    final todayCount = bookings.where(_isToday).length;
    final paidRevenue = bookings
        .where((booking) => booking.paymentStatus == AdminPaymentStatus.paid)
        .fold<int>(0, (sum, booking) => sum + booking.price);

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              bookingProvider.loadBookings(refresh: true),
              serviceProvider.loadServices(refresh: true),
            ]);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AdminColors.secondaryFixed,
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: AdminColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ch\u00e0o bu\u1ed5i s\u00e1ng,',
                        style: AdminTextStyles.bodyMd,
                      ),
                      Text('Admin Lavender', style: AdminTextStyles.titleLg),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.surfaceWhite,
                      shape: BoxShape.circle,
                      boxShadow: AdminColors.ambientShadow,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AdminColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _StatCard(
                    title: 'L\u1ecbch h\u00f4m nay',
                    value: todayCount.toString(),
                    icon: Icons.calendar_today_rounded,
                    color: AdminColors.primary,
                  ),
                  _StatCard(
                    title: 'Doanh thu',
                    value: _compactMoney(paidRevenue),
                    icon: Icons.payments_rounded,
                    color: AdminColors.statusCompleted,
                  ),
                  _StatCard(
                    title: 'Ch\u1edd x\u00e1c nh\u1eadn',
                    value: bookings
                        .where((b) => b.status == AdminBookingStatus.pending)
                        .length
                        .toString(),
                    icon: Icons.pending_actions_rounded,
                    color: AdminColors.statusPending,
                  ),
                  _StatCard(
                    title: '\u0110\u00e3 x\u00e1c nh\u1eadn',
                    value: bookings
                        .where((b) => b.status == AdminBookingStatus.confirmed)
                        .length
                        .toString(),
                    icon: Icons.verified_rounded,
                    color: AdminColors.statusConfirmed,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'L\u1ecbch h\u1eb9n s\u1eafp t\u1edbi',
                    style: AdminTextStyles.titleLg,
                  ),
                  if (bookingProvider.isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (bookingProvider.errorMessage != null && bookings.isEmpty)
                _DashboardMessage(
                  icon: Icons.wifi_off_rounded,
                  title:
                      'Ch\u01b0a t\u1ea3i \u0111\u01b0\u1ee3c l\u1ecbch h\u1eb9n',
                  message: bookingProvider.errorMessage!,
                )
              else if (upcoming.isEmpty)
                const _DashboardMessage(
                  icon: Icons.event_available_rounded,
                  title: 'Ch\u01b0a c\u00f3 l\u1ecbch s\u1eafp t\u1edbi',
                  message:
                      'K\u00e9o xu\u1ed1ng \u0111\u1ec3 t\u1ea3i l\u1ea1i d\u1eef li\u1ec7u m\u1edbi nh\u1ea5t.',
                )
              else
                ...upcoming.map((b) => _UpcomingBookingCard(booking: b)),
              const SizedBox(height: 24),
              Text(
                'D\u1ecbch v\u1ee5 ph\u1ed5 bi\u1ebfn',
                style: AdminTextStyles.titleLg,
              ),
              const SizedBox(height: 12),
              if (serviceProvider.isLoading && !serviceProvider.hasLoaded)
                const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (popularServices.isEmpty)
                const SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      'Ch\u01b0a c\u00f3 d\u1ecbch v\u1ee5 \u0111ang ho\u1ea1t \u0111\u1ed9ng.',
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: popularServices.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) =>
                        _PopularServiceCard(service: popularServices[i]),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  bool _isToday(AdminBooking booking) {
    final now = DateTime.now();
    return booking.dateTime.year == now.year &&
        booking.dateTime.month == now.month &&
        booking.dateTime.day == now.day;
  }

  String _compactMoney(int amount) {
    if (amount >= 1000000) {
      final value = amount / 1000000;
      return '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).round()}K';
    }
    return amount.toString();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AdminColors.ambientShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Text(value, style: AdminTextStyles.headlineSm),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: AdminTextStyles.bodyMd.copyWith(
              color: AdminColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingBookingCard extends StatelessWidget {
  const _UpcomingBookingCard({required this.booking});
  final AdminBooking booking;

  @override
  Widget build(BuildContext context) {
    final initial = booking.customerName.isEmpty
        ? '?'
        : booking.customerName[0];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AdminColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AdminColors.ambientShadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: AdminColors.primary),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AdminColors.secondaryFixed,
                        child: Text(
                          initial,
                          style: AdminTextStyles.titleMd.copyWith(
                            color: AdminColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.customerName,
                              style: AdminTextStyles.titleMd,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              booking.serviceName,
                              style: AdminTextStyles.bodySm.copyWith(
                                color: AdminColors.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatAdminTime(booking.dateTime),
                        style: AdminTextStyles.labelLg.copyWith(
                          color: AdminColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularServiceCard extends StatelessWidget {
  const _PopularServiceCard({required this.service});
  final AdminSpaService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AdminColors.ambientShadow,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 90,
            width: double.infinity,
            child: service.imageUrl.trim().isEmpty
                ? Image.asset(
                    AppAssets.serviceImageFor(name: service.name),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _serviceImageFallback(),
                  )
                : Image.network(
                    service.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      AppAssets.serviceImageFor(name: service.name),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _serviceImageFallback(),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: AdminTextStyles.labelLg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatAdminMoney(service.price),
                  style: AdminTextStyles.bodySm.copyWith(
                    color: AdminColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _serviceImageFallback() {
  return Container(
    color: AdminColors.secondaryFixed,
    child: const Icon(Icons.spa_rounded, color: AdminColors.primary, size: 32),
  );
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AdminColors.ambientShadow,
      ),
      child: Row(
        children: [
          Icon(icon, color: AdminColors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AdminTextStyles.titleMd),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AdminTextStyles.bodyMd.copyWith(
                    color: AdminColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
