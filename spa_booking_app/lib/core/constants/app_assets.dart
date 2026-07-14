// Tập trung đường dẫn asset local và ảnh online để các widget không hard-code URL.
class AppAssets {
  const AppAssets._();

  // Ảnh local dùng cho màn đăng nhập, banner và bottom navigation.
  static const String loginHero = 'assets/images/login_screen.jpg';
  static const String sales = 'assets/images/sales.jpg';
  static const String navHome = 'assets/images/home.png';
  static const String navService = 'assets/images/service.png';
  static const String navCalendar = 'assets/images/calender.png';
  static const String navProfile = 'assets/images/profile.png';

  // Ảnh online minh họa cho từng nhóm dịch vụ spa trong dữ liệu mẫu.
  static const String massage =
      'assets/images/img_massage.jpg';
  static const String facial =
      'assets/images/img_cham_soc_da_chuyensau.jpg';
  static const String hairWash =
      'assets/images/img_goidau.jpg';
  static const String hotStone =
      'assets/images/img_trilieu_huongthom.jpg';
  static const String acneCare =
      'assets/images/img_trimun.jpg';
  static const String bodyScrub =
      'assets/images/img_cham__soc.jpg';
  static const String aromatherapy =
      'assets/images/img_trilieu_huongthom.jpg';
  static const String nail =
      'assets/images/img_duong_nail.jpg';
  static const String waxing =
      'assets/images/img_waxing.jpg';
  static const String coupleSpa =
      'assets/images/img_massage.jpg';
  static const String userAvatar =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80';

  static String serviceImageFor({String? categorySlug, String? name}) {
    final slug = (categorySlug ?? '').toLowerCase();
    final label = (name ?? '').toLowerCase();
    if (slug.contains('skin') || slug.contains('facial') || label.contains('facial')) return facial;
    if (slug.contains('massage') || label.contains('massage')) return massage;
    if (slug.contains('treatment') || slug.contains('tri') || label.contains('stone')) return hotStone;
    if (slug.contains('nail') || label.contains('nail')) return nail;
    if (slug.contains('hair') || label.contains('hair')) return hairWash;
    if (slug.contains('wax') || label.contains('wax')) return waxing;
    return massage;
  }}
