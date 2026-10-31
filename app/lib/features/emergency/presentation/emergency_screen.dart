import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/hero_backdrop.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final Set<int> _done = <int>{};

  static const List<String> _stepKeys = [
    'emergency.step1',
    'emergency.step2',
    'emergency.step3',
    'emergency.step4',
    'emergency.step5',
  ];

  static const List<String> _tipKeys = [
    'emergency.tip1',
    'emergency.tip2',
    'emergency.tip3',
    'emergency.tip4',
  ];

  Future<void> _launch(String url, {String? fallback}) async {
    try {
      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (ok) return;
    } on Exception {
      // Fall through to the clipboard fallback.
    }
    if (!mounted) return;
    final text = fallback ?? url;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _toast('$text · ${context.t('result.copied')}');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyChecklist() async {
    final buffer = StringBuffer()
      ..writeln('${context.t('emergency.title')} — Pramaan')
      ..writeln();
    for (var i = 0; i < _stepKeys.length; i++) {
      buffer.writeln('${i + 1}. ${context.t('${_stepKeys[i]}.title')}');
      buffer.writeln('   ${context.t('${_stepKeys[i]}.body')}');
    }
    buffer
      ..writeln()
      ..writeln('1930 · cybercrime.gov.in');
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    _toast(context.t('emergency.copied'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: HeroBackdrop(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.critical.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.critical.withValues(alpha: 0.32),
                      ),
                    ),
                    child: const Icon(
                      Icons.sos,
                      size: 20,
                      color: AppColors.critical,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.t('emergency.title'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                context.t('emergency.body'),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _HelplineCard(
                onCall: () => _launch('tel:1930', fallback: '1930'),
                onPortal: () => _launch('https://cybercrime.gov.in'),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Text(
                    context.t('emergency.remember'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _copyChecklist,
                    icon: const Icon(Icons.copy_all_outlined, size: 15),
                    label: Text(
                      context.t('emergency.copy'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              for (var i = 0; i < _stepKeys.length; i++)
                _StepTile(
                  index: i + 1,
                  title: context.t('${_stepKeys[i]}.title'),
                  body: context.t('${_stepKeys[i]}.body'),
                  done: _done.contains(i),
                  onToggle: () => setState(() {
                    if (!_done.remove(i)) _done.add(i);
                  }),
                ),
              const SizedBox(height: 22),
              Text(
                context.t('emergency.remember').toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: AppColors.inkCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.inkLine),
                ),
                child: Column(
                  children: [
                    for (final key in _tipKeys)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_circle_outline,
                                size: 15,
                                color: AppColors.saffron,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.t(key),
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.55,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  context.t('app.tagline'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelplineCard extends StatelessWidget {
  const _HelplineCard({required this.onCall, required this.onPortal});

  final VoidCallback onCall;
  final VoidCallback onPortal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A1220), Color(0xFF1E1526)],
        ),
        border: Border.all(color: AppColors.critical.withValues(alpha: 0.34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('emergency.helpline').toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.critical,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '1930',
                style: TextStyle(
                  fontSize: 44,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  context.t('emergency.portal'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCall,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.critical,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  icon: const Icon(Icons.call, size: 18),
                  label: Text(context.t('emergency.call')),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 48,
                child: OutlinedButton(
                  onPressed: onPortal,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.square(48),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.open_in_new, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.title,
    required this.body,
    required this.done,
    required this.onToggle,
  });

  final int index;
  final String title;
  final String body;
  final bool done;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: done
                ? AppColors.mint.withValues(alpha: 0.06)
                : AppColors.inkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: done
                  ? AppColors.mint.withValues(alpha: 0.32)
                  : AppColors.inkLine,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.mint
                      : AppColors.ink.withValues(alpha: 0.6),
                  border: Border.all(
                    color: done ? AppColors.mint : AppColors.inkLine,
                    width: 1.4,
                  ),
                ),
                child: done
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Color(0xFF00281C),
                      )
                    : Text(
                        '$index',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.textMuted,
                        color: done
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 12.8,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
