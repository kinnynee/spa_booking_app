import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../models/admin_mock_data.dart';
import '../../../providers/admin_booking_provider.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context) {
    AdminCustomer? customer;
    for (final item in context.watch<AdminBookingProvider>().customers) {
      if (item.id == customerId) {
        customer = item;
        break;
      }
    }

    if (customer == null) {
      return Scaffold(
        backgroundColor: AdminColors.background,
        appBar: AppBar(
          backgroundColor: AdminColors.background,
          elevation: 0,
          title: Text('Hồ sơ khách hàng', style: AdminTextStyles.titleLg),
        ),
        body: const Center(child: Text('Không tìm thấy dữ liệu khách hàng.')),
      );
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AdminColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Hồ sơ khách hàng', style: AdminTextStyles.titleLg),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Profile
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AdminColors.secondaryFixed,
              child: Text(
                customer.name[0],
                style: AdminTextStyles.headlineMd.copyWith(
                  color: AdminColors.primary,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(customer.name, style: AdminTextStyles.headlineSm),
          const SizedBox(height: 4),
          Text(
            customer.phone,
            style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
          ),
          const SizedBox(height: 12),
          if (customer.isVip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                'KHÁCH THÂN THIẾT',
                style: TextStyle(
                  color: Color(0xFFFF9800),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCol(title: 'Tổng lịch', value: '${customer.totalBookings}'),
              Container(
                width: 1,
                height: 40,
                color: AdminColors.surfaceContainerHigh,
              ),
              _StatCol(
                title: 'Tổng chi',
                value: formatAdminMoney(customer.totalSpent),
              ),
              Container(
                width: 1,
                height: 40,
                color: AdminColors.surfaceContainerHigh,
              ),
              _StatCol(title: 'Yêu thích', value: 'Massage'),
            ],
          ),
          const SizedBox(height: 24),

          // Tabs
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: AdminColors.primary,
                    unselectedLabelColor: AdminColors.outline,
                    indicatorColor: AdminColors.primary,
                    tabs: [
                      Tab(text: 'Lịch sử'),
                      Tab(text: 'Ghi chú'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // History Tab
                        const Center(
                          child: Text(
                            'Lịch sử lịch hẹn sẽ hiển thị từ dữ liệu thực.',
                          ),
                        ),
                        // Notes Tab
                        const Center(child: Text('Chưa có ghi chú nào.')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tạo lịch hẹn'),
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AdminTextStyles.titleLg),
        const SizedBox(height: 4),
        Text(
          title,
          style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
        ),
      ],
    );
  }
}
