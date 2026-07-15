import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as google_web;

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    required this.isLoading,
    super.key,
  });

  // The browser SDK supplies the interactive button, so these parameters keep
  // the same API as the native widget while the SDK owns click handling.
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isLoading,
      child: Opacity(
        opacity: isLoading ? 0.6 : 1,
        child: google_web.renderButton(),
      ),
    );
  }
}
