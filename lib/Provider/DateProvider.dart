// import 'package:flutter/material.dart';
//
// class DateProvider with ChangeNotifier {
//   DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
//
//   DateTime get selectedDate => _selectedDate;
//
//   void updateDate(DateTime newDate) {
//     _selectedDate = DateTime(newDate.year, newDate.month, 1);
//     notifyListeners();
//   }
//
//   void updateDateFromUrl(String monthYear) {
//     final parts = monthYear.split('-');
//     final year = int.tryParse(parts[0]) ?? DateTime.now().year;
//     final month = int.tryParse(parts[1]) ?? DateTime.now().month;
//     _selectedDate = DateTime(year, month, 1);
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';

class DateProvider with ChangeNotifier {
  // ✅ Giữ nguyên ngày hiện tại, không ép về ngày 1
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void updateDate(DateTime newDate) {
    _selectedDate = newDate; // ✅ Lưu đúng ngày được chọn
    notifyListeners();
  }

  void updateDateFromUrl(String monthYear) {
    final parts = monthYear.split('-');
    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? DateTime.now().month;
    _selectedDate = DateTime(year, month, DateTime.now().day); // ✅ Giữ ngày hiện tại
    notifyListeners();
  }
}