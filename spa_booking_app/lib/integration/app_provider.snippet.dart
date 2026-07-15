// Trong MultiProvider cua lib/app.dart phai co dong nay:
ChangeNotifierProvider(create: (_) => AuthProvider()),

// AuthGate phai dieu huong toi LoginScreen khi chua dang nhap,
// sau khi AuthProvider.isAuthenticated == true thi dieu huong den man hinh user/admin.
