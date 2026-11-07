import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ui.dart';
import '../widgets/repair_card_widget.dart';
import '../widgets/repair_detail_widget.dart';
import '../widgets/repair_form_widget.dart';

class RepairsScreen extends HookConsumerWidget {
  const RepairsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repairs = ref.watch(repairsProvider);
    final filter = ref.watch(repairFilterProvider);
    final query = useState('');

    final all = repairs.value ?? const <Repair>[];
    int count(String k) => switch (k) {
          'open' => all.where((r) => r.isOpen).length,
          'all' => all.length,
          _ => all.where((r) => r.status == k).length,
        };
    final q = query.value.trim().toLowerCase();
    final list = all
        .where((r) => filter == 'all' || (filter == 'open' ? r.isOpen : r.status == filter))
        .where((r) => q.isEmpty || r.searchText.contains(q))
        .take(300)
        .toList();
    final chips = ['open', 'all', ...repairStatuses.map((s) => s.key)];

    return RefreshIndicator(
      onRefresh: () => ref.read(repairsProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList.list(
              children: [
                PageHeader(
                  title: 'Repair status',
                  subtitle: 'Customer yahi status track page par dekhta hai',
                  action: FilledButton.icon(
                    onPressed: () => openRepairForm(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Naya'),
                  ),
                ),
                AppSearchField(hint: 'Naam, mobile, model, IMEI ya SSS code', onChanged: (v) => query.value = v),
                const SizedBox(height: 10),
                ChipBar<String>(
                  items: chips,
                  selected: filter,
                  onSelect: (v) => ref.read(repairFilterProvider.notifier).set(v),
                  label: (k) => switch (k) {
                    'open' => 'Chalu',
                    'all' => 'Sab',
                    _ => statusOf(k).label,
                  },
                  count: count,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => launchUrl(Uri.parse('${AppConfig.site}/track.html'), mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Customer track page kholo'),
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: repairs.when(
              skipLoadingOnRefresh: true,
              loading: () => const SliverToBoxAdapter(child: LoadingBlock()),
              error: (e, _) => SliverToBoxAdapter(
                child: ErrorBlock(message: friendlyError(e), onRetry: () => ref.read(repairsProvider.notifier).refresh()),
              ),
              data: (_) => list.isEmpty
                  ? const SliverToBoxAdapter(
                      child: EmptyState(title: 'Koi repair nahi mila', message: 'Filter badlein ya naya repair banayein.', icon: Icons.phone_android_outlined),
                    )
                  : SliverList.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RepairCardWidget(
                          repair: list[i],
                          onTap: () => openRepairDetail(context, list[i].id),
                        ).entry(i),
                      ),
                    ),
            ),
          ),
          if (repairs.isLoading && repairs.hasValue)
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(8), child: Text('Refresh ho raha hai…', style: TextStyle(color: AppColors.muted))))),
        ],
      ),
    );
  }
}
