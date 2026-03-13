import 'package:flutter/material.dart';
import 'package:ma_visualization/Provider/PickupTimelineProvider.dart';
import 'package:ma_visualization/Provider/RemainTableProvider.dart';
import 'package:provider/provider.dart';

import 'Provider/DateProvider.dart';
import 'Provider/RemainChartProvider.dart';
import 'Routes/GoRouter.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RemainTableProvider()),
        ChangeNotifierProvider(create: (_) => RemainChartProvider()),
        ChangeNotifierProvider(create: (_) => PickupTimelineProvider()),

        ChangeNotifierProvider(create: (_) => DateProvider()),
      ],
      child: DashboardApp(),
    ),
  );
}

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDarkMode = true; // 🔥 Mặc định bật chế độ tối

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = createRouter(_toggleTheme); // Tạo router mới với chế độ tối
    return MaterialApp.router(
      routerConfig: router,
      // Cấu hình router cho MaterialApp
      title: 'Packing PO Monitoring',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
