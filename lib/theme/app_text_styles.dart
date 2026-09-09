import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const fontFamily = 'VT323';
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    color: AppColors.white,
  );
  static const header = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    color: AppColors.white,
  );
  static const heading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    color: AppColors.green,
    shadows: [Shadow(color: AppColors.black, offset: Offset(0, 4))],
  );
  static const legend = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    color: AppColors.white,
  );
  static const action = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    color: AppColors.white,
  );
  static const task = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    color: AppColors.white,
  );
  static const number = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
}
