import 'package:flutter/material.dart';
import '../../core/constants/admin_colors.dart';
import 'package:provider/provider.dart';

import '../../../providers/admin_booking_provider.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../models/admin_mock_data.dart';

/// Màn hình Tạo Lịch Hẹn Mới cho admin.
class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _searchCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  AdminCustomer? _selectedCustomer;
  AdminService? _selectedService;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final List<String> _timeSlots = [
    '09:00', '10:00', '11:00',
    '13:30', '14:30', '15:30',
    '16:30', '18:00', '19:00',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<AdminBookingProvider>().loadBookingFormOptions();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // Tạo 7 ngày từ hôm nay
  List<DateTime> get _weekDays {
    final today = DateTime.now();
    return List.generate(7, (i) => today.add(Duration(days: i)));
  }

  String _dayLabel(DateTime dt) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return labels[(dt.weekday - 1) % 7];
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  List<AdminCustomer> _matchingCustomers(List<AdminCustomer> customers) {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      return customers;
    }
    return customers
        .where((customer) => customer.name.toLowerCase().contains(query) || customer.phone.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBookingProvider>();
    final customers = _matchingCustomers(provider.customers);
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
        title: Text('Lịch hẹn mới', style: AdminTextStyles.headlineSm.copyWith(color: AdminColors.primary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AdminColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        service: _selectedService,
        onSave: _onSave,
        isSaving: provider.isCreating,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          // ── CHỌN KHÁCH HÀNG ──────────────────────────────
          _SectionLabel(label: 'CHỌN KHÁCH HÀNG'),
          const SizedBox(height: 10),
          TextField(
            controller: _searchCtrl,
            style: AdminTextStyles.bodyLg,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm tên hoặc SĐT...',
              hintStyle: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
              prefixIcon: const Icon(Icons.search_rounded, color: AdminColors.outline),
              filled: true,
              fillColor: AdminColors.surfaceWhite,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(99),
                borderSide: const BorderSide(color: AdminColors.surfaceContainerHigh),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(99),
                borderSide: const BorderSide(color: AdminColors.surfaceContainerHigh),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(99),
                borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Quick suggestions
          if (!provider.isLoadingFormOptions)
            ...customers.take(5).map((c) => _CustomerTile(
                  customer: c,
                  selected: _selectedCustomer?.id == c.id,
                  onTap: () => setState(() => _selectedCustomer = c),
                )),
          const SizedBox(height: 10),
          // Nút Thêm khách mới
          _OutlineButton(
            icon: Icons.refresh_rounded,
            label: 'Tải lại khách hàng',
            onTap: () => provider.loadBookingFormOptions(refresh: true),
          ),

          const SizedBox(height: 24),

          // ── DỊCH VỤ ──────────────────────────────────────
          _SectionLabel(label: 'DỊCH VỤ'),
          const SizedBox(height: 10),
          _ServiceDropdown(
            selected: _selectedService,
            services: provider.services,
            onChanged: (s) => setState(() => _selectedService = s),
          ),

          const SizedBox(height: 24),

          // ── CHỌN NGÀY ─────────────────────────────────────
          Row(
            children: [
              const _SectionLabel(label: 'CHỌN NGÀY'),
              const Spacer(),
              Text('Xem lịch tháng', style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _weekDays.map((day) {
                final selected = _isSameDay(day, _selectedDate);
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: selected ? AdminColors.primary : AdminColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dayLabel(day),
                          style: AdminTextStyles.labelLg.copyWith(
                            color: selected ? Colors.white70 : AdminColors.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: AdminTextStyles.titleLg.copyWith(
                            color: selected ? Colors.white : AdminColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // ── KHUNG GIỜ ─────────────────────────────────────
          const _SectionLabel(label: 'KHUNG GIỜ'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.6,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (context, i) {
              final time = _timeSlots[i];
              final selected = time == _selectedTime;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = time),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: selected ? AdminColors.primary : AdminColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AdminColors.primary : AdminColors.surfaceContainerHigh,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      time,
                      style: AdminTextStyles.bodyMd.copyWith(
                        color: selected ? Colors.white : AdminColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ── GHI CHÚ ───────────────────────────────────────
          const _SectionLabel(label: 'GHI CHÚ'),
          const SizedBox(height: 10),
          TextField(
            controller: _noteCtrl,
            minLines: 3,
            maxLines: 5,
            style: AdminTextStyles.bodyMd,
            decoration: InputDecoration(
              hintText: 'Ghi chú yêu cầu riêng (Ví dụ: khách dị ứng tinh dầu cam...)',
              hintStyle: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
              filled: true,
              fillColor: AdminColors.surfaceWhite,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AdminColors.surfaceContainerHigh),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AdminColors.surfaceContainerHigh),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 100), // space for bottom bar
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (_selectedCustomer == null) {
      _showSnack('Vui lòng chọn khách hàng');
      return;
    }
    if (_selectedService == null) {
      _showSnack('Vui lòng chọn dịch vụ');
      return;
    }
    if (_selectedTime == null) {
      _showSnack('Vui lòng chọn khung giờ');
      return;
    }
    final provider = context.read<AdminBookingProvider>();
    final booking = await provider.createBooking(
      customerId: _selectedCustomer!.id,
      serviceId: _selectedService!.id,
      appointmentTime: _combineDateAndTime(_selectedDate, _selectedTime!),
      note: _noteCtrl.text,
    );

    if (!mounted) {
      return;
    }
    if (booking == null) {
      _showSnack(provider.errorMessage ?? 'Không thể lưu lịch hẹn.');
      return;
    }
    Navigator.pop(context, true);
    return;
  }

  DateTime _combineDateAndTime(DateTime date, String time) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ─── Sub-widgets ───────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AdminTextStyles.labelLg);
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer, required this.selected, required this.onTap});
  final AdminCustomer customer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AdminColors.secondaryFixed : AdminColors.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AdminColors.primary : AdminColors.surfaceContainerHigh,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AdminColors.secondaryFixed,
              child: Text(customer.name[0], style: AdminTextStyles.titleMd.copyWith(color: AdminColors.primary)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: AdminTextStyles.titleMd),
                  Text(customer.phone, style: AdminTextStyles.bodyMd),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, color: AdminColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ServiceDropdown extends StatelessWidget {
  const _ServiceDropdown({required this.selected, required this.services, required this.onChanged});
  final AdminService? selected;
  final List<AdminService> services;
  final ValueChanged<AdminService?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AdminColors.surfaceContainerHigh),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AdminService>(
          value: selected,
          isExpanded: true,
          hint: Text('Chọn gói dịch vụ...', style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AdminColors.outline),
          items: services.map((s) => DropdownMenuItem(
            value: s,
            child: Text('${s.name} – ${formatAdminMoney(s.price)}', style: AdminTextStyles.bodyMd),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AdminColors.secondaryFixed,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AdminColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AdminTextStyles.bodyMd.copyWith(color: AdminColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.service, required this.isSaving, required this.onSave});
  final AdminService? service;
  final VoidCallback onSave;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (service != null) ...[
            Row(
              children: [
                Text('Tổng tiền:', style: AdminTextStyles.bodyMd),
                const Spacer(),
                Text(formatAdminMoney(service!.price), style: AdminTextStyles.price.copyWith(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
          ],
          GestureDetector(
            onTap: isSaving ? null : onSave,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8460CD), Color(0xFF6A46B2)],
                ),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Lưu lịch hẹn', style: AdminTextStyles.titleMd.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
