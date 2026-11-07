import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/brand.dart';
import '../../../../core/widgets/feedback.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = useTextEditingController();
    final password = useTextEditingController();
    final hide = useState(true);
    final busy = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      busy.value = true;
      try {
        await ref.read(sessionProvider.notifier).signIn(email.text.trim(), password.text);
      } catch (e) {
        if (context.mounted) showToast(context, friendlyError(e), error: true);
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: AppColors.glowGradient))),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AutofillGroup(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(child: BrandLogo(width: 210)).animate().fadeIn(duration: 500.ms).slideY(begin: -.08, end: 0),
                          const SizedBox(height: 26),
                          Text('Shop App', textAlign: TextAlign.center, style: AppTheme.head(size: 30)),
                          const SizedBox(height: 4),
                          const Text(
                            'Repair status, sales, bills, stock aur staff ek jagah',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 15),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: .85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.gold.withValues(alpha: .25)),
                              boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 18))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: email,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.alternate_email_rounded)),
                                  validator: (v) => (v ?? '').contains('@') ? null : 'Sahi email daaliye',
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: password,
                                  obscureText: hide.value,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => submit(),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                                    suffixIcon: IconButton(
                                      tooltip: hide.value ? 'Password dikhao' : 'Password chhupao',
                                      onPressed: () => hide.value = !hide.value,
                                      icon: Icon(hide.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                    ),
                                  ),
                                  validator: (v) => (v ?? '').isEmpty ? 'Password daaliye' : null,
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 54,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(99)),
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                                      onPressed: busy.value ? null : submit,
                                      child: busy.value
                                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.goldInk))
                                          : const Text('Login', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 450.ms).slideY(begin: .06, end: 0),
                          const SizedBox(height: 22),
                          const Text(
                            'Account Admin banata hai. Password bhool gaye to Admin se baat karein.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          const Text('shreesawriyasolutions.in', textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold, fontSize: 13, letterSpacing: .5)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
