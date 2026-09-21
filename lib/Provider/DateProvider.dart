import 'package:flutter/material.dart';

class DateProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void updateDate(DateTime newDate) {
    if (_selectedDate == newDate) return; // ✅ Tránh notify không cần thiết
    _selectedDate = newDate;
    notifyListeners();
  }

  void updateDateFromUrl(String monthYear) {
    final parts = monthYear.split('-');
    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? DateTime.now().month;
    final newDate = DateTime(year, month, DateTime.now().day);
    if (_selectedDate == newDate) return; // ✅ Tránh notify không cần thiết
    _selectedDate = newDate;
    notifyListeners();
  }
}