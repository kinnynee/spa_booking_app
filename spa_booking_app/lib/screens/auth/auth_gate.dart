import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../admin/admin_app.dart';
import '../../providers/auth_provider.dart';
import '../main_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    return auth.isAdmin ? const AdminApp() : const MainShell();
  }
}
