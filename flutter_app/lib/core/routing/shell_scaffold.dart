import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';
import 'app_router.dart';

class ShellScaffold extends HookConsumerWidget {
  const ShellScaffold({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final isAdmin = profile?.isAdmin ?? false;
    final tabs = isAdmin ? appTabs : appTabs.sublist(0, appTabs.length - 1);
    final index = shell.currentIndex.clamp(0, tabs.length - 1);

    // Doosre staff ke badlav dikhane ke liye: app par wapas aate hi aur har 60 second me refresh.
    useOnAppLifecycleStateChange((prev, current) {
      if (current == AppLifecycleState.resumed) refreshAll(ref);
    });
    useEffect(() {
      final t = Timer.periodic(const Duration(seconds: 60), (_) => refreshAll(ref));
      return t.cancel;
    }, const []);

    void go(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

    final wide = MediaQuery.sizeOf(context).width >= 900;

    final topBar = SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
        child: Row(
          children: [
            if (!wide) ...[
              const BrandEmblem(size: 34),
              const SizedBox(width: 10),
              const Expanded(child: BrandWordmark(compact: true)),
            ] else
              const Spacer(),
            ModeBadge(admin: isAdmin),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => refreshAll(ref),
              icon: const Icon(Icons.refresh_rounded, color: AppColors.muted),
            ),
            PopupMenuButton<String>(
              tooltip: 'Account',
              color: AppColors.surface2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              icon: Avatar2(name: profile?.name ?? 'S'),
              onSelected: (v) {
                if (v == 'logout') ref.read(sessionProvider.notifier).signOut();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text('${profile?.name ?? ''} · ${isAdmin ? 'Admin' : 'Staff'}', style: const TextStyle(color: AppColors.muted)),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(children: [Icon(Icons.logout_rounded, size: 20), SizedBox(width: 10), Text('Logout')]),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final body = Column(children: [topBar, Expanded(child: shell)]);

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              decoration: const BoxDecoration(border: Border(right: BorderSide(color: AppColors.line))),
              child: NavigationRail(
                extended: MediaQuery.sizeOf(context).width >= 1200,
                minExtendedWidth: 220,
                selectedIndex: index,
                onDestinationSelected: go,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: [
                      const BrandEmblem(size: 46),
                      const SizedBox(height: 6),
                      Text('SSS', style: AppTheme.head(size: 14, color: AppColors.gold)),
                    ],
                  ),
                ),
                destinations: [
                  for (final t in tabs)
                    NavigationRailDestination(icon: Icon(t.icon), selectedIcon: Icon(t.selectedIcon), label: Text(t.label)),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: go,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final t in tabs) NavigationDestination(icon: Icon(t.icon), selectedIcon: Icon(t.selectedIcon), label: t.label),
          ],
        ),
      ),
    );
  }
}
