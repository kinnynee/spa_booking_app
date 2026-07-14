import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../models/appointment.dart';
import '../../widgets/booking_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
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
          title: const Text('Lß╗ïch hß║╣n cß╗ºa t├┤i'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chß╗¥ x├íc nhß║¡n'),
              Tab(text: '─É├ú x├íc nhß║¡n'),
              Tab(text: 'Ho├án tß║Ñt'),
              Tab(text: '─É├ú hß╗ºy'),
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
                      child: const Text('Thß╗¡ lß║íi'),
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
        child: Text('Kh├┤ng c├│ lß╗ïch hß║╣n n├áo.', style: TextStyle(color: Colors.grey.shade600)),
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
        title: const Text('Hß╗ºy lß╗ïch hß║╣n?'),
        content: const Text('Bß║ín c├│ chß║»c chß║»n muß╗æn hß╗ºy lß╗ïch hß║╣n n├áy kh├┤ng?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kh├┤ng')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BookingProvider>().cancelBooking(id);
            },
            child: const Text('C├│, hß╗ºy', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
