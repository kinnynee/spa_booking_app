import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../models/admin_mock_data.dart';

/// Màn hình Chi tiết Lịch Hẹn – xem đầy đủ thông tin và thực hiện hành động.
class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.booking});
  final AdminBooking booking;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late AdminBookingStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.booking.status;
  }

  Color get _statusColor {
    switch (_status) {
      case AdminBookingStatus.pending: return AdminColors.statusPending;
      case AdminBookingStatus.confirmed: return AdminColors.statusConfirmed;
      case AdminBookingStatus.completed: return AdminColors.statusCompleted;
      case AdminBookingStatus.cancelled: return AdminColors.statusCancelled;
    }
  }

  String get _statusLabel {
    switch (_status) {
      case AdminBookingStatus.pending: return 'ĐANG XỬ LÝ';
      case AdminBookingStatus.confirmed: return 'ĐÃ XÁC NHẬN';
      case AdminBookingStatus.completed: return 'HOÀN TẤT';
      case AdminBookingStatus.cancelled: return 'ĐÃ HỦY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AdminColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('Mã #${b.id}', style: AdminTextStyles.headlineSm.copyWith(color: AdminColors.primary)),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(_statusLabel, style: AdminTextStyles.labelSm.copyWith(color: _statusColor, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: AdminColors.onSurfaceVariant), onPressed: () {}),
        ],
      ),
      bottomNavigationBar: _status != AdminBookingStatus.cancelled && _status != AdminBookingStatus.completed
          ? _ActionBar(status: _status, onCancel: _handleCancel, onConfirm: _handleConfirm, onComplete: _handleComplete)
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          // ── Header ảnh ──────────────────────────────────
          _HeroHeader(booking: b),
          const SizedBox(height: 16),

          // ── Thông tin khách hàng ─────────────────────────
          _InfoCard(
            icon: Icons.person_outline_rounded,
            title: 'Thông tin khách',
            child: Column(
              children: [
                const SizedBox(height: 12),
                _CustomerRow(booking: b),
                const SizedBox(height: 12),
                _InfoRow(icon: Icons.phone_outlined, text: b.phone),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.email_outlined, text: '${b.customerName.toLowerCase().replaceAll(' ', '')}@example.com'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Dịch vụ ──────────────────────────────────────
          _InfoCard(
            icon: Icons.spa_outlined,
            title: 'Dịch vụ',
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
                    Text('TÊN DỊCH VỤ', style: AdminTextStyles.labelLg),
                    const SizedBox(height: 4),
                    Text(b.serviceName, style: AdminTextStyles.titleMd),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 16, color: AdminColors.outline),
                        const SizedBox(width: 4),
                        Text('60 phút', style: AdminTextStyles.bodyMd),
                        const Spacer(),
                        Text(formatAdminMoney(b.price), style: AdminTextStyles.price),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Thanh toán ───────────────────────────────────
          _InfoCard(
            icon: Icons.payment_outlined,
            title: 'Thanh toán',
            accentColor: AdminColors.statusCancelled,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Trạng thái:', style: AdminTextStyles.bodyMd),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AdminColors.statusCancelledBg, borderRadius: BorderRadius.circular(99)),
                        child: Text('CHƯA THANH TOÁN', style: AdminTextStyles.labelSm.copyWith(color: AdminColors.statusCancelled, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('Tổng cộng:', style: AdminTextStyles.bodyMd),
                      const Spacer(),
                      Text(formatAdminMoney(b.price), style: AdminTextStyles.price.copyWith(fontSize: 22)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Ghi chú ──────────────────────────────────────
          if (b.note.isNotEmpty)
            _InfoCard(
              icon: Icons.notes_rounded,
              title: 'Ghi chú',
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AdminColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('"${b.note}"', style: AdminTextStyles.bodyMd.copyWith(fontStyle: FontStyle.italic)),
                ),
              ),
            ),

          if (b.note.isNotEmpty) const SizedBox(height: 16),

          // ── Nhật ký hoạt động ────────────────────────────
          Text('NHẬT KÝ HOẠT ĐỘNG', style: AdminTextStyles.labelLg),
          const SizedBox(height: 12),
          _ActivityLog(booking: b),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hủy lịch hẹn?'),
        content: const Text('Bạn có chắc muốn hủy lịch hẹn này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Không')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AdminColors.statusCancelled),
            onPressed: () {
              setState(() => _status = AdminBookingStatus.cancelled);
              Navigator.pop(context);
            },
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );
  }

  void _handleConfirm() => setState(() => _status = AdminBookingStatus.confirmed);
  void _handleComplete() => setState(() => _status = AdminBookingStatus.completed);
}

// ─── Sub-widgets ───────────────────────────────────────────

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
          image: NetworkImage('https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=600'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Color(0x88000000), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          // Bottom info overlay
          Positioned(
            left: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NGÀY HẸN', style: AdminTextStyles.labelSm.copyWith(color: Colors.white70)),
                Text(
                  '${booking.dateTime.day} Tháng ${booking.dateTime.month}, ${booking.dateTime.year}',
                  style: AdminTextStyles.titleLg.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          // Time badge
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
  const _InfoCard({required this.icon, required this.title, required this.child, this.accentColor});
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

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.booking});
  final AdminBooking booking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AdminColors.secondaryFixed),
          child: Center(
            child: Icon(Icons.person_rounded, color: AdminColors.primary, size: 24),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên khách hàng', style: AdminTextStyles.labelLg),
            const SizedBox(height: 2),
            Text(booking.customerName, style: AdminTextStyles.titleMd),
          ],
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
        Text(text, style: AdminTextStyles.bodyMd),
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
      _LogEvent(icon: Icons.check_circle_rounded, color: AdminColors.statusCompleted, title: 'Đặt lịch thành công', subtitle: 'Hệ thống • ${formatAdminDate(booking.dateTime)} 14:20'),
      _LogEvent(icon: Icons.update_rounded, color: AdminColors.statusConfirmed, title: 'Cập nhật trạng thái "Đang xử lý"', subtitle: 'Admin Lavender • ${formatAdminDate(booking.dateTime)} 15:00'),
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
                  decoration: BoxDecoration(color: e.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(e.icon, color: e.color, size: 18),
                ),
                if (i < events.length - 1)
                  Container(width: 2, height: 32, color: AdminColors.surfaceContainerHigh),
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
                    Text(e.subtitle, style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline)),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _LogEvent {
  const _LogEvent({required this.icon, required this.color, required this.title, required this.subtitle});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.status, required this.onCancel, required this.onConfirm, required this.onComplete});
  final AdminBookingStatus status;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          // Hủy lịch
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Hủy lịch'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AdminColors.statusCancelled,
                side: const BorderSide(color: AdminColors.statusCancelled),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                textStyle: AdminTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Xác nhận
          if (status == AdminBookingStatus.pending)
            Expanded(
              child: FilledButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Xác nhận'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  textStyle: AdminTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          // Hoàn tất
          if (status == AdminBookingStatus.confirmed)
            Expanded(
              child: FilledButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: const Text('Hoàn tất'),
                style: FilledButton.styleFrom(
                  backgroundColor: AdminColors.statusCompleted,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  textStyle: AdminTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
