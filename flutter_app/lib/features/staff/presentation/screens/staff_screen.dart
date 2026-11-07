import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config.dart';
import '../../../../core/data/shop_repository.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/sheet.dart';
import '../../../../core/widgets/ui.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admin = ref.watch(isAdminProvider);
    final staff = ref.watch(staffProvider);
    final me = ref.watch(profileProvider);

    if (!admin) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: NoteBox('Yeh section sirf Admin ke liye hai.', icon: Icons.lock_outline_rounded, color: AppColors.amber),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(staffProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          PageHeader(
            title: 'Staff',
            subtitle: 'Kaun login kar sakta hai, kiska kya role hai',
            action: FilledButton.icon(
              onPressed: () => showAppSheet(context, title: 'Naya staff', builder: (_) => const _NewStaffWidget()),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Naya'),
            ),
          ),
          const NoteBox(
            'Admin: sab dekh/badal/delete sakta hai. Staff: repair status badal sakta hai, sale entry, bill upload aur naya stock jod sakta hai. '
            '"Sales dekh sakta hai" on karne par staff sales list bhi dekhega.',
          ),
          const SizedBox(height: 14),
          if (staff.hasError && !staff.hasValue)
            ErrorBlock(message: friendlyError(staff.error), onRetry: () => ref.read(staffProvider.notifier).refresh())
          else if (!staff.hasValue)
            const LoadingBlock()
          else
            for (final (i, p) in (staff.value ?? const <Profile>[]).indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  onTap: () => showAppSheet(context, title: p.name, builder: (_) => _EditStaffWidget(profile: p, isMe: p.id == me?.id)),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Avatar(initials(p.name), gold: p.isAdmin),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${p.name}${p.id == me?.id ? '  (aap)' : ''}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                            Text(
                              p.isAdmin ? 'Admin · Joined ${fmtDate(p.createdAt)}' : '${p.canView ? 'Sales dekh sakta hai' : 'Sales list nahi dikhegi'} · Joined ${fmtDate(p.createdAt)}',
                              style: const TextStyle(color: AppColors.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Pill(p.isAdmin ? 'Admin' : 'Staff', tone: p.isAdmin ? Tone.gold : Tone.muted),
                    ],
                  ),
                ).entry(i),
              ),
        ],
      ),
    );
  }
}

class _NewStaffWidget extends HookConsumerWidget {
  const _NewStaffWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final name = useTextEditingController();
    final email = useTextEditingController();
    final pass = useTextEditingController();

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      final nav = Navigator.of(context);
      var active = false;
      final ok = await runAction(context, () async {
        active = await ref.read(repositoryProvider).createStaff(name: name.text.trim(), email: email.text.trim(), password: pass.text);
      });
      if (!ok) return;
      if (context.mounted) showToast(context, active ? 'Staff account ban gaya' : 'Account ban gaya. Staff ko email confirm karna hoga.');
      nav.pop();
      await ref.read(staffProvider.notifier).refresh();
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Field(label: 'Naam', controller: name, required: true),
          Field(
            label: 'Login email',
            controller: email,
            keyboard: TextInputType.emailAddress,
            validator: (v) => (v ?? '').contains('@') ? null : 'Sahi email daaliye',
          ),
          Field(
            label: 'Password',
            controller: pass,
            helper: 'Kam se kam 6 akshar',
            validator: (v) => (v ?? '').length < 6 ? 'Kam se kam 6 akshar' : null,
          ),
          const NoteBox('Account banne ke baad woh is app aur website ke sale/bills/stock pages par isi email-password se login karega.'),
          const SizedBox(height: 14),
          SheetActions(primary: BusyButton(label: 'Account banao', icon: Icons.person_add_alt_1_rounded, onPressed: submit)),
        ],
      ),
    );
  }
}

class _EditStaffWidget extends HookConsumerWidget {
  const _EditStaffWidget({required this.profile, required this.isMe});
  final Profile profile;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = profile;
    final name = useTextEditingController(text: p.fullName ?? '');
    final role = useState(p.role);
    final canView = useState(p.canView);
    final repo = ref.watch(repositoryProvider);

    Future<void> save() async {
      final o = <String, dynamic>{'full_name': clean(name.text), 'can_view': canView.value};
      if (!isMe) o['role'] = role.value;
      final nav = Navigator.of(context);
      final ok = await runAction(context, () => repo.updateProfile(p.id, o), ok: 'Staff update ho gaya');
      if (ok) {
        if (isMe) ref.read(sessionProvider.notifier).updateName(o['full_name'] as String?);
        nav.pop();
        await ref.read(staffProvider.notifier).refresh();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Field(label: 'Naam', controller: name),
        DropdownField<String>(
          label: 'Role',
          value: role.value,
          items: const ['staff', 'admin'],
          itemLabel: (r) => r == 'admin' ? 'Admin' : 'Staff',
          enabled: !isMe,
          onChanged: (v) => role.value = v,
        ),
        if (isMe) const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Apna role khud nahi badal sakte.', style: TextStyle(color: AppColors.muted))),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Sales list dekh sakta hai'),
          value: canView.value,
          onChanged: (v) => canView.value = v,
        ),
        const SizedBox(height: 10),
        SheetActions(primary: BusyButton(label: 'Save karein', icon: Icons.check_rounded, onPressed: save)),
        if (!isMe) ...[
          const SizedBox(height: 14),
          ConfirmDeleteButton(
            what: 'Is staff ka app access',
            label: 'Access hatao',
            onConfirm: () async {
              final nav = Navigator.of(context);
              final ok = await runAction(context, () => repo.delete(DeleteKind.staff, p.id), ok: 'Access hata diya');
              if (ok) {
                nav.pop();
                await ref.read(staffProvider.notifier).refresh();
              }
            },
          ),
        ],
      ],
    );
  }
}
