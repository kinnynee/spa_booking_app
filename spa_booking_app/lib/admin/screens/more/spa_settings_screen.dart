import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/admin_colors.dart';
import '../../core/constants/admin_text_styles.dart';
import '../../core/widgets/admin_app_bar.dart';

class SpaSettingsScreen extends StatefulWidget {
  const SpaSettingsScreen({super.key});

  @override
  State<SpaSettingsScreen> createState() => _SpaSettingsScreenState();
}

class _SpaSettingsScreenState extends State<SpaSettingsScreen> {
  final _spaNameCtrl = TextEditingController(text: 'Lavender Spa');
  final _addressCtrl = TextEditingController(
    text: '24 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh',
  );
  final _hotlineCtrl = TextEditingController(text: '090 123 4567');
  final _emailCtrl = TextEditingController(text: 'hello@lavenderspa.vn');
  final _cancelHoursCtrl = TextEditingController(text: '2');

  final List<String> _days = const [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

  late final Map<String, bool> _openByDay;

  @override
  void initState() {
    super.initState();
    _openByDay = {for (final day in _days) day: true};
  }

  @override
  void dispose() {
    _spaNameCtrl.dispose();
    _addressCtrl.dispose();
    _hotlineCtrl.dispose();
    _emailCtrl.dispose();
    _cancelHoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: const AdminAppBar(title: 'Cài đặt Spa', showBackButton: true),
      bottomNavigationBar: _SaveSettingsBar(onSave: _saveSettings),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          const _SectionHeader(
            icon: Icons.storefront_rounded,
            label: 'THÔNG TIN TIỆM',
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              TextField(
                controller: _spaNameCtrl,
                style: AdminTextStyles.bodyMd,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration('Tên Spa', Icons.spa_rounded),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressCtrl,
                style: AdminTextStyles.bodyMd,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(
                  'Địa chỉ',
                  Icons.location_on_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _hotlineCtrl,
                style: AdminTextStyles.bodyMd,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration('Hotline', Icons.call_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                style: AdminTextStyles.bodyMd,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration(
                  'Email',
                  Icons.mail_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _SectionHeader(
            icon: Icons.schedule_rounded,
            label: 'GIỜ HOẠT ĐỘNG',
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              for (var index = 0; index < _days.length; index++) ...[
                _BusinessHourRow(
                  day: _days[index],
                  weekend: index >= 5,
                  enabled: _openByDay[_days[index]] ?? true,
                  onChanged: (value) {
                    setState(() => _openByDay[_days[index]] = value);
                  },
                ),
                if (index != _days.length - 1) const _SettingsDivider(),
              ],
            ],
          ),
          const SizedBox(height: 22),
          const _SectionHeader(
            icon: Icons.verified_user_outlined,
            label: 'CHÍNH SÁCH ĐẶT LỊCH',
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AdminColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.event_busy_rounded,
                      color: AdminColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hủy lịch trước', style: AdminTextStyles.titleMd),
                        const SizedBox(height: 2),
                        Text(
                          'Khoảng thời gian tối thiểu để khách hủy lịch',
                          style: AdminTextStyles.bodySm,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 84,
                    child: TextField(
                      controller: _cancelHoursCtrl,
                      style: AdminTextStyles.titleMd,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _smallFieldDecoration('giờ'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: AdminTextStyles.bodyMd.copyWith(color: AdminColors.outline),
      prefixIcon: Icon(icon, color: AdminColors.outline, size: 20),
      filled: true,
      fillColor: AdminColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
      ),
    );
  }

  InputDecoration _smallFieldDecoration(String suffix) {
    return InputDecoration(
      suffixText: suffix,
      suffixStyle: AdminTextStyles.bodySm,
      filled: true,
      fillColor: AdminColors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
      ),
    );
  }

  void _saveSettings() {
    if (_spaNameCtrl.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập tên spa');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu cài đặt spa!'),
        backgroundColor: AdminColors.statusCompleted,
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AdminColors.primary),
        const SizedBox(width: 8),
        Text(label, style: AdminTextStyles.labelLg),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AdminColors.ambientShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _BusinessHourRow extends StatelessWidget {
  const _BusinessHourRow({
    required this.day,
    required this.weekend,
    required this.enabled,
    required this.onChanged,
  });

  final String day;
  final bool weekend;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              day,
              style: AdminTextStyles.titleMd.copyWith(
                color: weekend ? AdminColors.primary : AdminColors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: enabled
                    ? AdminColors.surfaceContainerLow
                    : AdminColors.surfaceContainer,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    enabled
                        ? Icons.access_time_rounded
                        : Icons.do_not_disturb_on_outlined,
                    size: 16,
                    color: enabled ? AdminColors.primary : AdminColors.outline,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      enabled ? '09:00 - 21:00' : 'Nghỉ',
                      style: AdminTextStyles.bodySm.copyWith(
                        color: enabled
                            ? AdminColors.onSurfaceVariant
                            : AdminColors.outline,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            activeThumbColor: AdminColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 14, color: AdminColors.surfaceContainerHigh);
  }
}

class _SaveSettingsBar extends StatelessWidget {
  const _SaveSettingsBar({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: onSave,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AdminColors.primary,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Lưu thay đổi',
                  style: AdminTextStyles.titleMd.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
