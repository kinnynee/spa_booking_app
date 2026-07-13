import 'package:flutter/material.dart';

/// Typography Admin – Plus Jakarta Sans (heading) + Be Vietnam Pro (body)
class AdminTextStyles {
  AdminTextStyles._();

  // Display
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.72,
    color: Color(0xFF1A1C1F),
  );

  // Headline
  static const TextStyle headlineLg = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    letterSpacing: -0.28,
    color: Color(0xFF1A1C1F),
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    color: Color(0xFF1A1C1F),
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: Color(0xFF1A1C1F),
  );

  // Title
  static const TextStyle titleLg = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: Color(0xFF1A1C1F),
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    color: Color(0xFF1A1C1F),
  );

  // Body
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: Color(0xFF1A1C1F),
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: Color(0xFF4A4452),
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: Color(0xFF4A4452),
  );

  // Label
  static const TextStyle labelLg = TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.6,
    color: Color(0xFF4A4452),
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 14 / 10,
    color: Color(0xFF7B7483),
  );

  // Price (purple bold)
  static const TextStyle price = TextStyle(
    fontFamily: 'BeVietnamPro',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFF6A46B2),
  );
}
