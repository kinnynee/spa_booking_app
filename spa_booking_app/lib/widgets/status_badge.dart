import 'package:flutter/material.dart';
import '../models/appointment.dart';

class StatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status) {
      case AppointmentStatus.pending:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF9800);
        text = 'Chờ xác nhận';
        break;
      case AppointmentStatus.confirmed:
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF2196F3);
        text = 'Đã xác nhận';
        break;
      case AppointmentStatus.completed:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        text = 'Hoàn tất';
        break;
      case AppointmentStatus.cancelled:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFF44336);
        text = 'Đã hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
