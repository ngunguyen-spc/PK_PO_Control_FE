import 'package:flutter/material.dart';

class AppColors {
  // // ✅ Remain PO — dùng thống nhất ở Table, Summary, Chart
  // static const remainDark        = Color(0xFFFF6B6B); // dark mode
  // static const remainLight       = Color(0xFFE53935); // light mode
  // static const remainBgDark      = Color(0xFF3B1A1A); // dark bg
  // static const remainBgLight     = Color(0xFFFFF0F0); // light bg
  // static const remainBorderDark  = Color(0xFF7A2A2A);
  // static const remainBorderLight = Color(0xFFFFCDD2);
  // ✅ Remain PO — nền sáng hồng nhạt, chữ đỏ đậm (dễ nhìn trên cả dark/light)
  static const remainDark        = Color(0xFFFF6B6B); // chữ trên dark mode
  static const remainLight       = Color(0xFFE53935); // chữ trên light mode

  static const remainBgDark      = Color(0xFFFFCDD2); // ✅ Nền hồng nhạt — dễ nhìn trên dark
  static const remainBgLight     = Color(0xFFFFCDD2); // ✅ Giống nhau cả 2 mode
  static const remainBorderDark  = Color(0xFFEF9A9A);
  static const remainBorderLight = Color(0xFFEF9A9A);
}