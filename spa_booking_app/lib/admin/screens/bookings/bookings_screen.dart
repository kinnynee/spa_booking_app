import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_booking_provider.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../core/widgets/admin_app_bar.dart';
import '../../models/admin_mock_data.dart';
import 'booking_detail_screen.dart';
import 'create_booking_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _filterIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _filters = [
    'T\u1ea5t c\u1ea3',
    'Ch\u1edd x\u00e1c nh\u1eadn',
    '\u0110\u00e3 x\u00e1c nh\u1eadn',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AdminBookingProvider>().loadBookings();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminBooking> _filtered(List<AdminBooking> bookings) {
    var list = bookings;
    if (_filterIndex == 1) {
      list = list.where((b) => b.status == AdminBookingStatus.pending).toList();
    }
    if (_filterIndex == 2) {
      list = list
          .where((b) => b.status == AdminBookingStatus.confirmed)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (b) =>
                b.customerName.toLowerCase().contains(q) ||
                b.phone.toLowerCase().contains(q) ||
                b.serviceName.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  int _upcomingCount(List<AdminBooking> bookings) {
    return bookings
        .where(
          (b) =>
              b.status == AdminBookingStatus.pending ||
              b.status == AdminBookingStatus.confirmed,
        )
        .length;
  }

  Future<void> _confirmBooking(AdminBooking booking) async {
    final provider = context.read<AdminBookingProvider>();
    final updated = await provider.confirmBooking(booking.id);
    if (!mounted) {
      return;
    }
    _showResult(
      updated != null,
      successMessage: '\u0110\u00e3 x\u00e1c nh\u1eadn l\u1ecbch h\u1eb9n.',
      fallbackError:
          'Kh\u00f4ng th\u1ec3 x\u00e1c nh\u1eadn l\u1ecbch h\u1eb9n.',
    );
  }

  Future<void> _cancelBooking(AdminBooking booking) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('H\u1ee7y l\u1ecbch h\u1eb9n?'),
        content: Text(
          'B\u1ea1n c\u00f3 ch\u1eafc mu\u1ed1n h\u1ee7y l\u1ecbch c\u1ee7a ${booking.customerName} kh\u00f4ng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Kh\u00f4ng'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AdminColors.statusCancelled,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('H\u1ee7y l\u1ecbch'),
          ),
        ],
      ),
    );

    if (accepted != true || !mounted) {
      return;
    }

    final provider = context.read<AdminBookingProvider>();
    final updated = await provider.cancelBooking(
      booking.id,
      reason: 'Admin cancelled from booking list',
    );
    if (!mounted) {
      return;
    }
    _showResult(
      updated != null,
      successMessage: '\u0110\u00e3 h\u1ee7y l\u1ecbch h\u1eb9n.',
      fallbackError: 'Kh\u00f4ng th\u1ec3 h\u1ee7y l\u1ecbch h\u1eb9n.',
    );
  }

  void _showResult(
    bool isSuccess, {
    required String successMessage,
    required String fallbackError,
  }) {
    final provider = context.read<AdminBookingProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuccess ? successMessage : provider.errorMessage ?? fallbackError,
        ),
        backgroundColor: isSuccess
            ? AdminColors.statusCompleted
            : AdminColors.statusCancelled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBookingProvider>();
    final filtered = _filtered(provider.bookings);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: const AdminAppBar(
        title: 'L\u1ecbch h\u1eb9n',
        showMenuIcon: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bookingProvider = context.read<AdminBookingProvider>();
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateBookingScreen()),
          );
          if (!mounted || created != true) {
            return;
          }
          // Re-read the backend list so the new booking is visible even when
          // this screen loaded before the create request completed.
          await bookingProvider.loadBookings(refresh: true);
          if (!mounted) {
            return;
          }
          _showResult(
            true,
            successMessage: 'Đã lưu lịch hẹn thành công.',
            fallbackError: 'Không thể lưu lịch hẹn.',
          );
        },
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: AdminTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText:
                    'T\u00ecm t\u00ean kh\u00e1ch h\u00e0ng, S\u0110T ho\u1eb7c d\u1ecbch v\u1ee5',
                hintStyle: AdminTextStyles.bodyMd.copyWith(
                  color: AdminColors.outline,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AdminColors.outline,
                ),
                filled: true,
                fillColor: AdminColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(99),
                  borderSide: const BorderSide(
                    color: AdminColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _filterIndex;
                return GestureDetector(
                  onTap: () => setState(() => _filterIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AdminColors.primary
                          : AdminColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _filters[i],
                      style: AdminTextStyles.bodyMd.copyWith(
                        color: selected
                            ? Colors.white
                            : AdminColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildList(provider, filtered)),
        ],
      ),
    );
  }

  Widget _buildList(
    AdminBookingProvider provider,
    List<AdminBooking> filtered,
  ) {
    if (provider.isLoading && !provider.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.bookings.isEmpty) {
      return _MessageState(
        icon: Icons.wifi_off_rounded,
        title: 'Ch\u01b0a t\u1ea3i \u0111\u01b0\u1ee3c l\u1ecbch h\u1eb9n',
        message: provider.errorMessage!,
        actionLabel: 'Th\u1eed l\u1ea1i',
        onAction: () => provider.loadBookings(refresh: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadBookings(refresh: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        itemCount: filtered.isEmpty ? 1 : filtered.length + 1,
        separatorBuilder: (_, i) => i < filtered.length - 1
            ? const SizedBox(height: 12)
            : const SizedBox.shrink(),
        itemBuilder: (context, i) {
          if (filtered.isEmpty) {
            return const _MessageState(
              icon: Icons.event_busy_rounded,
              title: 'Kh\u00f4ng c\u00f3 l\u1ecbch ph\u00f9 h\u1ee3p',
              message:
                  'H\u00e3y \u0111\u1ed5i b\u1ed9 l\u1ecdc ho\u1eb7c k\u00e9o xu\u1ed1ng \u0111\u1ec3 t\u1ea3i l\u1ea1i d\u1eef li\u1ec7u.',
            );
          }

          if (i < filtered.length) {
            final booking = filtered[i];
            final busy = provider.isUpdating(booking.id);
            return _BookingCard(
              booking: booking,
              isBusy: busy,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingDetailScreen(booking: booking),
                ),
              ),
              onConfirm: busy ? null : () => _confirmBooking(booking),
              onCancel: busy ? null : () => _cancelBooking(booking),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _UpcomingBanner(count: _upcomingCount(provider.bookings)),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onConfirm,
    required this.onCancel,
    required this.isBusy,
  });

  final AdminBooking booking;
  final VoidCallback onTap;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isBusy;

  Color get _barColor {
    switch (booking.status) {
      case AdminBookingStatus.completed:
        return AdminColors.statusCompleted;
      case AdminBookingStatus.confirmed:
        return AdminColors.statusConfirmed;
      case AdminBookingStatus.pending:
        return AdminColors.statusPending;
      case AdminBookingStatus.cancelled:
        return AdminColors.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isBusy ? 0.72 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AdminColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AdminColors.ambientShadow,
          ),
          clipBehavior: Clip.hardEdge,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: _barColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.customerName,
                                    style: AdminTextStyles.titleMd,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.phone,
                                    style: AdminTextStyles.bodyMd,
                                  ),
                                ],
                              ),
                            ),
                            _StatusBadge(status: booking.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.spa_outlined,
                              size: 16,
                              color: AdminColors.outline,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                booking.serviceName,
                                style: AdminTextStyles.bodySm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: AdminColors.outline,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              formatAdminDateTime(booking.dateTime),
                              style: AdminTextStyles.bodySm,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            color: AdminColors.surfaceContainerHigh,
                            height: 1,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              formatAdminMoney(booking.price),
                              style: AdminTextStyles.price,
                            ),
                            const Spacer(),
                            if (booking.status ==
                                AdminBookingStatus.pending) ...[
                              _ActionButton(
                                icon: Icons.close_rounded,
                                color: AdminColors.statusCancelled,
                                onTap: onCancel,
                                outlined: true,
                              ),
                              const SizedBox(width: 8),
                              _PillButton(
                                label: 'X\u00e1c nh\u1eadn',
                                isBusy: isBusy,
                                onTap: onConfirm,
                              ),
                            ] else
                              GestureDetector(
                                onTap: onTap,
                                child: Row(
                                  children: [
                                    Text(
                                      'Chi ti\u1ebft',
                                      style: AdminTextStyles.bodyMd.copyWith(
                                        color: AdminColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: AdminColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final AdminBookingStatus status;

  String get _label {
    switch (status) {
      case AdminBookingStatus.pending:
        return 'Ch\u1edd x\u00e1c nh\u1eadn';
      case AdminBookingStatus.confirmed:
        return '\u0110\u00e3 x\u00e1c nh\u1eadn';
      case AdminBookingStatus.completed:
        return 'Ho\u00e0n t\u1ea5t';
      case AdminBookingStatus.cancelled:
        return '\u0110\u00e3 h\u1ee7y';
    }
  }

  Color get _bg {
    switch (status) {
      case AdminBookingStatus.pending:
        return AdminColors.statusPendingBg;
      case AdminBookingStatus.confirmed:
        return AdminColors.statusConfirmedBg;
      case AdminBookingStatus.completed:
        return AdminColors.statusCompletedBg;
      case AdminBookingStatus.cancelled:
        return AdminColors.statusCancelledBg;
    }
  }

  Color get _fg {
    switch (status) {
      case AdminBookingStatus.pending:
        return AdminColors.statusPending;
      case AdminBookingStatus.confirmed:
        return AdminColors.statusConfirmed;
      case AdminBookingStatus.completed:
        return AdminColors.statusCompleted;
      case AdminBookingStatus.cancelled:
        return AdminColors.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _label,
        style: AdminTextStyles.labelSm.copyWith(
          color: _fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: outlined ? Border.all(color: color, width: 1.5) : null,
          color: outlined ? Colors.transparent : color,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    required this.isBusy,
  });
  final String label;
  final VoidCallback? onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 96),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: onTap == null ? AdminColors.outline : AdminColors.primary,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Center(
          child: isBusy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: AdminTextStyles.bodyMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _UpcomingBanner extends StatelessWidget {
  const _UpcomingBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF8460CD), Color(0xFF6A46B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'S\u1eaeP DI\u1ec4N RA',
                  style: AdminTextStyles.labelLg.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'C\u00f3 ${count.toString()} l\u1ecbch h\u1eb9n \u0111ang ch\u1edd x\u1eed l\u00fd',
                  style: AdminTextStyles.headlineSm.copyWith(
                    color: Colors.white,
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

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: AdminColors.outline),
            const SizedBox(height: 12),
            Text(
              title,
              style: AdminTextStyles.titleMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: AdminTextStyles.bodyMd.copyWith(
                color: AdminColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
