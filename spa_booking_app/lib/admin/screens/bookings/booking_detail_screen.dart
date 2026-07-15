import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_booking_provider.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../models/admin_mock_data.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.booking});
  final AdminBooking booking;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late AdminBooking _booking;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  Color _statusColor(AdminBookingStatus status) {
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

  String _statusLabel(AdminBookingStatus status) {
    switch (status) {
      case AdminBookingStatus.pending:
        return '\u0110ANG X\u1eec L\u00dd';
      case AdminBookingStatus.confirmed:
        return '\u0110\u00c3 X\u00c1C NH\u1eacN';
      case AdminBookingStatus.completed:
        return 'HO\u00c0N T\u1ea4T';
      case AdminBookingStatus.cancelled:
        return '\u0110\u00c3 H\u1ee6Y';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBookingProvider>();
    final latestBooking = provider.bookingById(_booking.id);
    final b = latestBooking ?? _booking;
    final isBusy = provider.isUpdating(b.id);
    final statusColor = _statusColor(b.status);

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AdminColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'M\u00e3 #${b.id}',
              style: AdminTextStyles.headlineSm.copyWith(
                color: AdminColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _statusLabel(b.status),
                    style: AdminTextStyles.labelSm.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AdminColors.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar:
          b.status != AdminBookingStatus.cancelled &&
              b.status != AdminBookingStatus.completed
          ? _ActionBar(
              status: b.status,
              isBusy: isBusy,
              onCancel: _handleCancel,
              onConfirm: _handleConfirm,
              onComplete: _handleComplete,
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _HeroHeader(booking: b),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.person_outline_rounded,
            title: 'Th\u00f4ng tin kh\u00e1ch',
            child: Column(
              children: [
                const SizedBox(height: 12),
                _CustomerRow(booking: b),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  text: b.phone.isEmpty
                      ? 'Ch\u01b0a c\u00f3 s\u1ed1 \u0111i\u1ec7n tho\u1ea1i'
                      : b.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.spa_outlined,
            title: 'D\u1ecbch v\u1ee5',
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'T\u00caN D\u1ecaCH V\u1ee4',
                      style: AdminTextStyles.labelLg,
                    ),
                    const SizedBox(height: 4),
                    Text(b.serviceName, style: AdminTextStyles.titleMd),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AdminColors.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatAdminDateTime(b.dateTime),
                          style: AdminTextStyles.bodyMd,
                        ),
                        const Spacer(),
                        Text(
                          formatAdminMoney(b.price),
                          style: AdminTextStyles.price,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PaymentCard(
            booking: b,
            isBusy: isBusy,
            onConfirmPayment: _handleConfirmPayment,
          ),
          const SizedBox(height: 12),
          if (b.note.isNotEmpty)
            _InfoCard(
              icon: Icons.notes_rounded,
              title: 'Ghi ch\u00fa',
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AdminColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '"${b.note}"',
                    style: AdminTextStyles.bodyMd.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          if (b.note.isNotEmpty) const SizedBox(height: 16),
          Text(
            'NH\u1eacT K\u00dd HO\u1ea0T \u0110\u1ed8NG',
            style: AdminTextStyles.labelLg,
          ),
          const SizedBox(height: 12),
          _ActivityLog(booking: b),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _handleCancel() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('H\u1ee7y l\u1ecbch h\u1eb9n?'),
        content: const Text(
          'B\u1ea1n c\u00f3 ch\u1eafc mu\u1ed1n h\u1ee7y l\u1ecbch h\u1eb9n n\u00e0y kh\u00f4ng?',
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

    await _runAction(
      () => context.read<AdminBookingProvider>().cancelBooking(
        _booking.id,
        reason: 'Admin cancelled from booking detail',
      ),
      successMessage: '\u0110\u00e3 h\u1ee7y l\u1ecbch h\u1eb9n.',
      fallbackError: 'Kh\u00f4ng th\u1ec3 h\u1ee7y l\u1ecbch h\u1eb9n.',
    );
  }

  Future<void> _handleConfirm() {
    return _runAction(
      () => context.read<AdminBookingProvider>().confirmBooking(_booking.id),
      successMessage: '\u0110\u00e3 x\u00e1c nh\u1eadn l\u1ecbch h\u1eb9n.',
      fallbackError:
          'Kh\u00f4ng th\u1ec3 x\u00e1c nh\u1eadn l\u1ecbch h\u1eb9n.',
    );
  }

  Future<void> _handleComplete() {
    return _runAction(
      () => context.read<AdminBookingProvider>().completeBooking(_booking.id),
      successMessage: '\u0110\u00e3 ho\u00e0n t\u1ea5t l\u1ecbch h\u1eb9n.',
      fallbackError:
          'Kh\u00f4ng th\u1ec3 ho\u00e0n t\u1ea5t l\u1ecbch h\u1eb9n.',
    );
  }

  Future<void> _handleConfirmPayment() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('X\u00e1c nh\u1eadn giao d\u1ecbch?'),
        content: Text(
          'Ghi nh\u1eadn thanh to\u00e1n ${formatAdminMoney(_booking.price)} cho l\u1ecbch h\u1eb9n n\u00e0y?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('\u0110\u1ec3 sau'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('X\u00e1c nh\u1eadn'),
          ),
        ],
      ),
    );

    if (accepted != true || !mounted) {
      return;
    }

    await _runAction(
      () => context.read<AdminBookingProvider>().confirmPayment(_booking.id),
      successMessage: '\u0110\u00e3 x\u00e1c nh\u1eadn giao d\u1ecbch.',
      fallbackError: 'Kh\u00f4ng th\u1ec3 x\u00e1c nh\u1eadn giao d\u1ecbch.',
    );
  }

  Future<void> _runAction(
    Future<AdminBooking?> Function() action, {
    required String successMessage,
    required String fallbackError,
  }) async {
    final updated = await action();
    if (!mounted) {
      return;
    }

    if (updated != null) {
      setState(() => _booking = updated);
    }

    final provider = context.read<AdminBookingProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated != null
              ? successMessage
              : provider.errorMessage ?? fallbackError,
        ),
        backgroundColor: updated != null
            ? AdminColors.statusCompleted
            : AdminColors.statusCancelled,
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.booking});
  final AdminBooking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF8460CD), Color(0xFF4A2D8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=600',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x88000000), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NG\u00c0Y H\u1eb8N',
                  style: AdminTextStyles.labelSm.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  formatAdminDate(booking.dateTime),
                  style: AdminTextStyles.titleLg.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                formatAdminTime(booking.dateTime),
                style: AdminTextStyles.headlineSm.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
    this.accentColor,
  });
  final IconData icon;
  final String title;
  final Widget child;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AdminColors.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AdminColors.ambientShadow,
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: AdminTextStyles.titleMd),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.booking,
    required this.isBusy,
    required this.onConfirmPayment,
  });

  final AdminBooking booking;
  final bool isBusy;
  final VoidCallback onConfirmPayment;

  bool get _isPaid => booking.paymentStatus == AdminPaymentStatus.paid;
  bool get _canConfirm =>
      !_isPaid && booking.status != AdminBookingStatus.cancelled;

  Color get _color =>
      _isPaid ? AdminColors.statusCompleted : AdminColors.statusCancelled;
  Color get _background =>
      _isPaid ? AdminColors.statusCompletedBg : AdminColors.statusCancelledBg;
  String get _label =>
      _isPaid ? '\u0110\u00c3 THANH TO\u00c1N' : 'CH\u01afA THANH TO\u00c1N';

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.payment_outlined,
      title: 'Thanh to\u00e1n',
      accentColor: _color,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Row(
              children: [
                Text('Tr\u1ea1ng th\u00e1i:', style: AdminTextStyles.bodyMd),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    _label,
                    style: AdminTextStyles.labelSm.copyWith(
                      color: _color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (_isPaid && booking.paidAt != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.schedule_rounded,
                text:
                    '\u0110\u00e3 thu l\u00fac ${formatAdminDateTime(booking.paidAt!)}',
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text('T\u1ed5ng c\u1ed9ng:', style: AdminTextStyles.bodyMd),
                const Spacer(),
                Text(
                  formatAdminMoney(booking.price),
                  style: AdminTextStyles.price.copyWith(fontSize: 22),
                ),
              ],
            ),
            if (_canConfirm) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isBusy ? null : onConfirmPayment,
                  icon: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.payments_rounded, size: 18),
                  label: const Text('X\u00e1c nh\u1eadn giao d\u1ecbch'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminColors.statusCompleted,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                    textStyle: AdminTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.booking});
  final AdminBooking booking;

  @override
  Widget build(BuildContext context) {
    final initial = booking.customerName.isEmpty
        ? '?'
        : booking.customerName[0];
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AdminColors.secondaryFixed,
          ),
          child: Center(
            child: Text(
              initial,
              style: AdminTextStyles.titleMd.copyWith(
                color: AdminColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'T\u00ean kh\u00e1ch h\u00e0ng',
                style: AdminTextStyles.labelLg,
              ),
              const SizedBox(height: 2),
              Text(booking.customerName, style: AdminTextStyles.titleMd),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AdminColors.outline),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AdminTextStyles.bodyMd)),
      ],
    );
  }
}

class _ActivityLog extends StatelessWidget {
  const _ActivityLog({required this.booking});
  final AdminBooking booking;

  @override
  Widget build(BuildContext context) {
    final events = [
      _LogEvent(
        icon: Icons.check_circle_rounded,
        color: AdminColors.statusCompleted,
        title: '\u0110\u1eb7t l\u1ecbch th\u00e0nh c\u00f4ng',
        subtitle: 'H\u1ec7 th\u1ed1ng - ${formatAdminDate(booking.dateTime)}',
      ),
      _LogEvent(
        icon: Icons.update_rounded,
        color: AdminColors.statusConfirmed,
        title:
            'Tr\u1ea1ng th\u00e1i hi\u1ec7n t\u1ea1i: ${_statusText(booking.status)}',
        subtitle: 'Admin Lavender',
      ),
      if (booking.paymentStatus == AdminPaymentStatus.paid)
        _LogEvent(
          icon: Icons.payments_rounded,
          color: AdminColors.statusCompleted,
          title:
              'Giao d\u1ecbch \u0111\u00e3 \u0111\u01b0\u1ee3c x\u00e1c nh\u1eadn',
          subtitle: booking.paidAt == null
              ? 'Admin Lavender'
              : formatAdminDateTime(booking.paidAt!),
        ),
    ];

    return Column(
      children: List.generate(events.length, (i) {
        final e = events[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: e.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(e.icon, color: e.color, size: 18),
                ),
                if (i < events.length - 1)
                  Container(
                    width: 2,
                    height: 32,
                    color: AdminColors.surfaceContainerHigh,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: AdminTextStyles.titleMd),
                    const SizedBox(height: 2),
                    Text(
                      e.subtitle,
                      style: AdminTextStyles.bodyMd.copyWith(
                        color: AdminColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _statusText(AdminBookingStatus status) {
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
}

class _LogEvent {
  const _LogEvent({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.status,
    required this.isBusy,
    required this.onCancel,
    required this.onConfirm,
    required this.onComplete,
  });

  final AdminBookingStatus status;
  final bool isBusy;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isBusy ? null : onCancel,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('H\u1ee7y l\u1ecbch'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.statusCancelled,
                side: const BorderSide(color: AdminColors.statusCancelled),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                textStyle: AdminTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (status == AdminBookingStatus.pending)
            Expanded(
              child: FilledButton.icon(
                onPressed: isBusy ? null : onConfirm,
                icon: _BusyIcon(isBusy: isBusy, fallback: Icons.check_rounded),
                label: const Text('X\u00e1c nh\u1eadn'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                  textStyle: AdminTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (status == AdminBookingStatus.confirmed)
            Expanded(
              child: FilledButton.icon(
                onPressed: isBusy ? null : onComplete,
                icon: _BusyIcon(
                  isBusy: isBusy,
                  fallback: Icons.done_all_rounded,
                ),
                label: const Text('Ho\u00e0n t\u1ea5t'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminColors.statusCompleted,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99),
                  ),
                  textStyle: AdminTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BusyIcon extends StatelessWidget {
  const _BusyIcon({required this.isBusy, required this.fallback});
  final bool isBusy;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    if (!isBusy) {
      return Icon(fallback, size: 18);
    }
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
