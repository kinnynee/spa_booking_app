import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/appointment.dart';
import '../../widgets/booking_card.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch hẹn của tôi'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đã xác nhận'),
              Tab(text: 'Hoàn tất'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: Consumer<BookingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(provider.error!),
                    TextButton(
                      onPressed: () => provider.fetchMyBookings(),
                      child: const Text('Thử lại'),
                    )
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                _buildList(provider.bookings, AppointmentStatus.pending),
                _buildList(provider.bookings, AppointmentStatus.confirmed),
                _buildList(provider.bookings, AppointmentStatus.completed),
                _buildList(provider.bookings, AppointmentStatus.cancelled),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<Appointment> allBookings, AppointmentStatus status) {
    final filteredBookings = allBookings.where((b) => b.status == status).toList();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Text('Không có lịch hẹn nào.', style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<BookingProvider>().fetchMyBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return BookingCard(
            booking: booking,
            onCancel: () => _handleCancel(booking.id),
          );
        },
      ),
    );
  }

  void _handleCancel(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy lịch hẹn?'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Không')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BookingProvider>().cancelBooking(id);
            },
            child: const Text('Có, hủy', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
