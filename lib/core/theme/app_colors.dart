import 'package:flutter/material.dart';

/// تمام رنگ‌های اپ فقط از اینجا استفاده می‌شوند. هیچ hard-code رنگی در Widgetها مجاز نیست.
class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF3D5AFE);
  static const primaryDark = Color(0xFF0031CA);
  static const primaryLight = Color(0xFF8187FF);

  // Semantic
  static const success = Color(0xFF2E7D32); // طلبکار
  static const danger = Color(0xFFC62828); // بدهکار
  static const warning = Color(0xFFF9A825);

  // Light theme
  static const lightBackground = Color(0xFFF7F8FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF1A1B25);
  static const lightTextSecondary = Color(0xFF6B6F80);
  static const lightBorder = Color(0xFFE3E5EC);

  // Dark theme
  static const darkBackground = Color(0xFF121218);
  static const darkSurface = Color(0xFF1D1E27);
  static const darkTextPrimary = Color(0xFFF2F2F7);
  static const darkTextSecondary = Color(0xFFA0A3B1);
  static const darkBorder = Color(0xFF2C2E3B);
}
