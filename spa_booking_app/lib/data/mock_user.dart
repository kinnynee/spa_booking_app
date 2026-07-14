// Import model hồ sơ để tạo user mẫu cho luồng đăng nhập mock.
import '../models/user_profile.dart';

// User mẫu dùng khi app chạy chưa nối backend thật.
const UserProfile mockUser = UserProfile(
  fullName: 'Trần Trung Kiên',
  email: 'admin@spa.local',
  phone: '0901 234 567',
  birthday: '01/01/2005',
  gender: 'Nam',
  avatar: '',
  role: 'admin',
);
