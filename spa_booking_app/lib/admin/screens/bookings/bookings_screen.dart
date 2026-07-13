import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../core/widgets/admin_app_bar.dart';
import '../../models/admin_mock_data.dart';
import 'booking_detail_screen.dart';
import 'create_booking_screen.dart';

/// Màn hình Quản lý Lịch Hẹn – danh sách, tìm kiếm, lọc và xác nhận nhanh.
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _filterIndex = 0; // 0=Tất cả, 1=Chờ xác nhận, 2=Đã xác nhận
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _filters = ['Tất cả', 'Chờ xác nhận', 'Đã xác nhận'];

  List<AdminBooking> get _filtered {
    var list = mockAdminBookings;
    if (_filterIndex == 1) list = list.where((b) => b.status == AdminBookingStatus.pending).toList();
    if (_filterIndex == 2) list = list.where((b) => b.status == AdminBookingStatus.confirmed).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((b) => b.customerName.toLowerCase().contains(q) || b.phone.contains(q)).toList();
    }
    return list;
  }

  int get _upcomingCount => mockAdminBookings
      .where((b) => b.status == AdminBookingStatus.pending || b.status == AdminBookingStatus.confirmed)
      .length;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AdminAppBar(title: 'Lịch hẹn', showMenuIcon: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateBookingScreen())),
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: AdminTextStyles.bodyMd,
              decoration: InputDecoration(
                hintText: 'Tìm tên khách hàng hoặc số điện thoại',
                hintStyle: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
                prefixIcon: const Icon(Icons.search_rounded, color: AdminColors.outline),
                filled: true,
                fillColor: AdminColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                  borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _filterIndex;
                return GestureDetector(
                  onTap: () => setState(() => _filterIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AdminColors.primary : AdminColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _filters[i],
                      style: AdminTextStyles.bodyMd.copyWith(
                        color: selected ? Colors.white : AdminColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              itemCount: _filtered.length + 1, // +1 cho banner cuối
              separatorBuilder: (_, i) => i < _filtered.length - 1 ? const SizedBox(height: 12) : const SizedBox.shrink(),
              itemBuilder: (context, i) {
                if (i < _filtered.length) {
                  return _BookingCard(
                    booking: _filtered[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: _filtered[i])),
                    ),
                    onConfirm: () => setState(() {}),
                    onCancel: () => setState(() {}),
                  );
                }
                // Banner cuối
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _UpcomingBanner(count: _upcomingCount),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Card lịch hẹn có color bar trạng thái, thông tin khách, dịch vụ, giá.
class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.onTap,
    required this.onConfirm,
    required this.onCancel,
  });

  final AdminBooking booking;
  final VoidCallback onTap;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

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
    return GestureDetector(
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
              // Color bar trái
              Container(width: 4, color: _barColor),

              // Nội dung
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên + badge trạng thái
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(booking.customerName, style: AdminTextStyles.titleMd),
                                const SizedBox(height: 2),
                                Text(booking.phone, style: AdminTextStyles.bodyMd),
                              ],
                            ),
                          ),
                          _StatusBadge(status: booking.status),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Dịch vụ
                      Row(
                        children: [
                          const Icon(Icons.spa_outlined, size: 16, color: AdminColors.outline),
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
                          const Icon(Icons.access_time_rounded, size: 16, color: AdminColors.outline),
                          const SizedBox(width: 6),
                          Text(
                            formatAdminDateTime(booking.dateTime),
                            style: AdminTextStyles.bodySm,
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AdminColors.surfaceContainerHigh, height: 1),
                      ),

                      // Giá + actions
                      Row(
                        children: [
                          Text(formatAdminMoney(booking.price), style: AdminTextStyles.price),
                          const Spacer(),
                          if (booking.status == AdminBookingStatus.pending) ...[
                            _ActionButton(
                              icon: Icons.close_rounded,
                              color: AdminColors.statusCancelled,
                              onTap: onCancel,
                              outlined: true,
                            ),
                            const SizedBox(width: 8),
                            _PillButton(label: 'Xác nhận', onTap: onConfirm),
                          ] else
                            GestureDetector(
                              onTap: onTap,
                              child: Row(
                                children: [
                                  Text('Chi tiết', style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.primary, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right_rounded, size: 18, color: AdminColors.primary),
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
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final AdminBookingStatus status;

  String get _label {
    switch (status) {
      case AdminBookingStatus.pending: return 'Chờ xác nhận';
      case AdminBookingStatus.confirmed: return 'Đã xác nhận';
      case AdminBookingStatus.completed: return 'Hoàn tất';
      case AdminBookingStatus.cancelled: return 'Đã hủy';
    }
  }

  Color get _bg {
    switch (status) {
      case AdminBookingStatus.pending: return AdminColors.statusPendingBg;
      case AdminBookingStatus.confirmed: return AdminColors.statusConfirmedBg;
      case AdminBookingStatus.completed: return AdminColors.statusCompletedBg;
      case AdminBookingStatus.cancelled: return AdminColors.statusCancelledBg;
    }
  }

  Color get _fg {
    switch (status) {
      case AdminBookingStatus.pending: return AdminColors.statusPending;
      case AdminBookingStatus.confirmed: return AdminColors.statusConfirmed;
      case AdminBookingStatus.completed: return AdminColors.statusCompleted;
      case AdminBookingStatus.cancelled: return AdminColors.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(99)),
      child: Text(_label, style: AdminTextStyles.labelSm.copyWith(color: _fg, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, required this.onTap, this.outlined = false});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
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
  const _PillButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: AdminColors.primary, borderRadius: BorderRadius.circular(99)),
        child: Text(label, style: AdminTextStyles.bodyMd.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Banner tím "Sắp diễn ra" ở cuối danh sách.
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
          // Background decorative circles
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
                  'SẮP DIỄN RA',
                  style: AdminTextStyles.labelLg.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sắp có $count lịch hẹn mới\ntrong ngày mai',
                  style: AdminTextStyles.headlineSm.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
