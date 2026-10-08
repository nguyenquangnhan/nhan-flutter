import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/parsed_bank_bill.dart';
import '../../screens/app_navigation_shell.dart';
import '../../screens/home_screen.dart';
import '../../screens/reports_screen.dart';
import '../../screens/bill_scanner_screen.dart';
import '../../screens/review_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ShellRoute giữ thanh NavigationBar cố định cho các tab chính
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Danh sách Giao dịch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 2: Báo cáo Biểu đồ Thống kê
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Tuyến đường quét biên lai OCR (mở full màn hình)
    GoRoute(
      path: '/scan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BillScannerScreen(),
    ),

    // Tuyến đường xác thực và chọn danh mục tiêu sài
    GoRoute(
      path: '/review',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final bill = state.extra as ParsedBankBill?;
        if (bill == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy dữ liệu biên lai hợp lệ')),
          );
        }
        return ReviewScreen(parsedBill: bill);
      },
    ),
  ],
);
