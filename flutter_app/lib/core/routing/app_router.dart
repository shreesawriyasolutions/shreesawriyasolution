import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/bills/presentation/screens/bills_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/repairs/presentation/screens/repairs_screen.dart';
import '../../features/sales/presentation/screens/sales_screen.dart';
import '../../features/staff/presentation/screens/staff_screen.dart';
import '../../features/stock/presentation/screens/stock_screen.dart';
import '../providers/providers.dart';
import 'shell_scaffold.dart';

class AppTab {
  const AppTab(this.path, this.label, this.icon, this.selectedIcon);
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Branch order = is list ka order. Staff hamesha last (sirf Admin ko dikhta hai).
const appTabs = [
  AppTab('/home', 'Home', Icons.space_dashboard_outlined, Icons.space_dashboard_rounded),
  AppTab('/status', 'Status', Icons.phone_android_outlined, Icons.phone_android_rounded),
  AppTab('/sales', 'Sales', Icons.bar_chart_outlined, Icons.bar_chart_rounded),
  AppTab('/bills', 'Bills', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
  AppTab('/stock', 'Stock', Icons.inventory_2_outlined, Icons.inventory_2_rounded),
  AppTab('/staff', 'Staff', Icons.group_outlined, Icons.group_rounded),
];

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final s = ref.read(sessionProvider);
      final loc = state.matchedLocation;
      if (s.isLoading && !s.hasValue) return loc == '/splash' ? null : '/splash';
      final p = s.value;
      if (p == null) return loc == '/login' ? null : '/login';
      if (loc == '/login' || loc == '/splash') return '/home';
      if (loc == '/staff' && !p.isAdmin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/status', builder: (_, _) => const RepairsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/sales', builder: (_, _) => const SalesScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/bills', builder: (_, _) => const BillsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/stock', builder: (_, _) => const StockScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/staff', builder: (_, _) => const StaffScreen())]),
        ],
      ),
    ],
  );
});

extension TabNav on BuildContext {
  /// Bottom tab badlo (shell ke andar).
  void goTab(String path) => GoRouter.of(this).go(path);
}
