import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/preview_controller.dart';
import '../theme/app_colors.dart';
import 'risk_gauge.dart';

Future<void> showSettingsSheet(BuildContext context) {
  if (kIsWeb) {
    final PreviewController? preview = PreviewScope.maybeOf(context);
    preview?.restore();
  }
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final locale = AppScope.of(context);
    final preview = PreviewScope.maybeOf(context);

    return AnimatedBuilder(
      animation: preview ?? Listenable.merge([]),
      builder: (context, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const PramaanMark(size: 40),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('app.name'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          context.t('app.tagline'),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  context.t('common.language'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _LanguageOption(
                      label: 'English',
                      selected: !locale.isHindi,
                      onTap: () => locale.setLanguage(false),
                    ),
                    const SizedBox(width: 10),
                    _LanguageOption(
                      label: 'हिन्दी',
                      selected: locale.isHindi,
                      onTap: () => locale.setLanguage(true),
                    ),
                  ],
                ),
                if (kIsWeb) ...[
                  const SizedBox(height: 24),
                  _DisplaySection(preview: preview),
                ],
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inkLine),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: AppColors.mint,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.t('common.about'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t('common.about.body'),
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'v1.0.0 · open source · no servers',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DisplaySection extends StatelessWidget {
  const _DisplaySection({required this.preview});

  final PreviewController? preview;

  @override
  Widget build(BuildContext context) {
    final controller = preview;
    if (controller == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.display_settings_outlined,
                size: 16,
                color: AppColors.saffron,
              ),
              const SizedBox(width: 8),
              Text(
                context.t('display.title'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.t('display.body'),
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _DisplayOption(
                icon: Icons.smartphone,
                label: context.t('display.phone'),
                selected: controller.mode == PreviewMode.phone,
                onTap: () => controller.setMode(PreviewMode.phone),
              ),
              const SizedBox(width: 10),
              _DisplayOption(
                icon: Icons.tablet_mac,
                label: context.t('display.tablet'),
                selected: controller.mode == PreviewMode.tablet,
                onTap: () => controller.setMode(PreviewMode.tablet),
              ),
              const SizedBox(width: 10),
              _DisplayOption(
                icon: Icons.open_in_full,
                label: context.t('display.full'),
                selected: controller.mode == PreviewMode.full,
                onTap: () => controller.setMode(PreviewMode.full),
              ),
            ],
          ),
          if (controller.mode == PreviewMode.full) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.saffron.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.saffron.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.saffron,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.t('display.escape'),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DisplayOption extends StatelessWidget {
  const _DisplayOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.saffron : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        enableFeedback: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.saffron.withValues(alpha: 0.14)
                : AppColors.ink,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.saffron : AppColors.inkLine,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.saffron : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        enableFeedback: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.saffron.withValues(alpha: 0.14)
                : AppColors.ink,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.saffron : AppColors.inkLine,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}
