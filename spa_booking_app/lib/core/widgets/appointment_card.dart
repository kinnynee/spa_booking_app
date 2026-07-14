// Thư viện Material cung cấp widget, icon, màu và button cho card.
import 'package:flutter/material.dart';

// Import model lịch hẹn, hàm format/status và màu dùng trong card.
import '../../models/appointment.dart';
import '../../providers/booking_provider.dart';
import '../constants/app_colors.dart';

// Card hiển thị một lịch hẹn, bao gồm trạng thái, thời gian, giá và nút hủy.
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onCancel,
  });

  final Appointment appointment;
  final VoidCallback? onCancel;

  @override
  // build dựng phần giao diện của widget lịch hẹn.
  Widget build(BuildContext context) {
    final statusColor = _statusColor(appointment.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  appointment.service.name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText(appointment.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SmallLine(
            icon: Icons.calendar_month_outlined,
            text: '${formatDate(appointment.date)} - ${appointment.time}',
          ),
          const SizedBox(height: 8),
          _SmallLine(
            icon: Icons.schedule,
            text: '${appointment.service.durationMinutes} phút',
          ),
          const SizedBox(height: 8),
          _SmallLine(
            icon: Icons.payments_outlined,
            text: formatMoney(appointment.service.price),
          ),
          if (appointment.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            _SmallLine(icon: Icons.notes_outlined, text: appointment.note),
          ],
          if (appointment.status == AppointmentStatus.pending) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Hủy lịch'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: .28),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Đổi trạng thái lịch hẹn sang màu tương ứng trên badge.
  Color _statusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.confirmed:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.danger;
    }
  }
}

// Dòng thông tin nhỏ có icon bên trái và nội dung bên phải.
class _SmallLine extends StatelessWidget {
  const _SmallLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  // build dựng phần giao diện của widget lịch hẹn.
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
