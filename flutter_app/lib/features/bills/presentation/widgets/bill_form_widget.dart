import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/feedback.dart';
import '../../../../core/widgets/sheet.dart';

Future<void> openBillForm(BuildContext context) => showAppSheet(context, title: 'Bill upload', builder: (_) => const BillFormWidget());

String _typeFor(String name) {
  final n = name.toLowerCase();
  if (n.endsWith('.pdf')) return 'application/pdf';
  if (n.endsWith('.png')) return 'image/png';
  if (n.endsWith('.webp')) return 'image/webp';
  return 'image/jpeg';
}

/// Photo (camera/gallery, chhoti karke) ya PDF chuno.
Future<List<PickedUpload>> pickUploads(BuildContext context, {required int max}) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.photo_camera_rounded, color: AppColors.gold), title: const Text('Camera se photo'), onTap: () => Navigator.pop(ctx, 'camera')),
          ListTile(leading: const Icon(Icons.photo_library_rounded, color: AppColors.gold), title: const Text('Gallery se photos'), onTap: () => Navigator.pop(ctx, 'gallery')),
          ListTile(leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.gold), title: const Text('PDF file'), onTap: () => Navigator.pop(ctx, 'pdf')),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (choice == null) return const [];
  final picker = ImagePicker();
  final out = <PickedUpload>[];
  if (choice == 'camera') {
    final x = await picker.pickImage(source: ImageSource.camera, maxWidth: 1600, maxHeight: 1600, imageQuality: 80);
    if (x != null) out.add(PickedUpload(bytes: await x.readAsBytes(), contentType: 'image/jpeg', name: x.name));
  } else if (choice == 'gallery') {
    final xs = await picker.pickMultiImage(maxWidth: 1600, maxHeight: 1600, imageQuality: 80, limit: max >= 2 ? max : null);
    for (final x in xs.take(max)) {
      out.add(PickedUpload(bytes: await x.readAsBytes(), contentType: _typeFor(x.name), name: x.name));
    }
  } else {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf'], allowMultiple: true, withData: true);
    for (final f in (r?.files ?? const <PlatformFile>[]).take(max)) {
      if (f.bytes != null) out.add(PickedUpload(bytes: f.bytes!, contentType: 'application/pdf', name: f.name));
    }
  }
  return out;
}

class BillFormWidget extends HookConsumerWidget {
  const BillFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(profileProvider);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final type = useState(billTypes.first.value);
    final date = useState<String?>(today());
    final party = useTextEditingController();
    final mobile = useTextEditingController();
    final model = useTextEditingController();
    final imei = useTextEditingController();
    final work = useState(workTypes.first);
    final amount = useTextEditingController();
    final staff = useTextEditingController(text: me?.name ?? '');
    final notes = useTextEditingController();
    final billFiles = useState<List<PickedUpload>>([]);
    final idFiles = useState<List<PickedUpload>>([]);
    final progress = useState<String?>(null);
    final unlock = type.value == 'Unlocking Job';

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      final m = mobile.text.replaceAll(RegExp(r'\s'), '');
      if (billFiles.value.isEmpty) {
        showToast(context, 'Bill ki photo ya PDF chuniye.', error: true);
        return;
      }
      if (m.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(m)) {
        showToast(context, 'Mobile number 10 digit ka hona chahiye.', error: true);
        return;
      }
      final im = imei.text.replaceAll(RegExp(r'\s'), '');
      if (unlock && (model.text.trim().isEmpty || !RegExp(r'^\d{15}$').hasMatch(im))) {
        showToast(context, 'Model aur 15 digit IMEI daaliye.', error: true);
        return;
      }
      final repo = ref.read(repositoryProvider);
      final nav = Navigator.of(context);
      final items = [
        for (final f in billFiles.value) (f, 'bill'),
        if (unlock) for (final f in idFiles.value) (f, 'id'),
      ];
      final ok = await runAction(context, () async {
        final bp = <String>[], ip = <String>[];
        for (var i = 0; i < items.length; i++) {
          progress.value = 'Uploading ${i + 1} / ${items.length}...';
          final p = await repo.uploadBillFile(items[i].$1, items[i].$2);
          (items[i].$2 == 'id' ? ip : bp).add(p);
        }
        await repo.insertBill({
          'bill_date': date.value ?? today(),
          'bill_type': type.value,
          'party_name': party.text.trim(),
          'mobile_number': m.isEmpty ? null : m,
          'phone_model': unlock ? model.text.trim() : null,
          'imei': unlock ? im : null,
          'work_type': unlock ? work.value : null,
          'amount': numOrNull(amount.text),
          'notes': clean(notes.text),
          'bill_file_path': bp.first,
          'id_file_path': ip.isEmpty ? null : ip.first,
          'extra_file_paths': [...bp.skip(1), ...ip.skip(1)],
          'uploaded_by_name': staff.text.trim(),
        });
      }, ok: 'Bill upload ho gaya');
      if (context.mounted) progress.value = null;
      if (ok) {
        nav.pop();
        await ref.read(billsProvider.notifier).refresh();
      }
    }

    Widget filesBox(String label, ValueNotifier<List<PickedUpload>> files, int max) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: files.value.isEmpty ? AppColors.line : AppColors.gold.withValues(alpha: .4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < files.value.length; i++)
                      InputChip(
                        avatar: Icon(files.value[i].contentType == 'application/pdf' ? Icons.picture_as_pdf_rounded : Icons.image_rounded, size: 18),
                        label: Text('${i + 1}. ${(files.value[i].bytes.length / 1024).round()} KB'),
                        onDeleted: () => files.value = [...files.value]..removeAt(i),
                      ),
                    if (files.value.length < max)
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 18, color: AppColors.gold),
                        label: const Text('File jodo'),
                        onPressed: () async {
                          final picked = await pickUploads(context, max: max - files.value.length);
                          files.value = [...files.value, ...picked];
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Max $max files, 10 MB har ek', style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
              ],
            ),
          ),
        );

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldRow([
            DropdownField<String>(
              label: 'Bill type',
              value: type.value,
              items: [for (final t in billTypes) t.value],
              itemLabel: (v) => billTypeOf(v).label,
              onChanged: (v) => type.value = v,
            ),
            DateField(label: 'Date', value: date.value, onChanged: (v) => date.value = v),
          ]),
          FieldRow([
            Field(label: type.value == 'Purchase Bill' ? 'Supplier / party naam' : 'Customer naam', controller: party, required: true),
            Field(label: 'Mobile', controller: mobile, digitsOnly: true, maxLength: 10),
          ]),
          if (unlock) ...[
            FieldRow([
              Field(label: 'Phone model', controller: model, required: true),
              Field(label: 'IMEI (15 digit)', controller: imei, digitsOnly: true, maxLength: 15, required: true),
            ]),
            DropdownField<String>(label: 'Kaam', value: work.value, items: workTypes, onChanged: (v) => work.value = v),
          ],
          FieldRow([
            Field(label: 'Amount (₹)', controller: amount, decimal: true),
            Field(label: 'Upload karne wala', controller: staff, required: true),
          ]),
          filesBox('Bill photo / PDF *', billFiles, 10),
          if (unlock) filesBox('Customer ID photo', idFiles, 4),
          Field(label: 'Notes', controller: notes),
          if (progress.value != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(progress.value!, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
            ),
          SheetActions(primary: BusyButton(label: 'Upload karo', icon: Icons.cloud_upload_rounded, onPressed: submit)),
        ],
      ),
    );
  }
}
