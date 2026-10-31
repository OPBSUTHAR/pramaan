import 'package:flutter/material.dart';
import 'package:scam_engine/scam_engine.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 26, 20, 12),
  });

  final String title;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A rounded label used for risk levels, severities and states.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    required this.color,
    super.key,
    this.icon,
    this.dense = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 9 : 12,
        vertical: dense ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: dense ? 11 : 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Label on the left, value on the right. Used by the UPI inspector.
class InfoRow extends StatelessWidget {
  const InfoRow({
    required this.label,
    required this.value,
    super.key,
    this.mono = false,
    this.valueColor,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool mono;
  final Color? valueColor;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: valueColor ?? AppColors.textPrimary,
      fontFamily: mono ? 'monospace' : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: selectable
                ? SelectableText(value, style: style)
                : Text(value, style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class SignalTile extends StatelessWidget {
  const SignalTile({required this.signal, super.key});

  final ScamSignal signal;

  @override
  Widget build(BuildContext context) {
    final hindi = context.isHindi;
    final color = AppColors.forSeverity(signal.severity);
    final title = hindi ? signal.titleHi : signal.titleEn;
    final explain = hindi ? signal.explainHi : signal.explainEn;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(signal.category), size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hindi ? signal.category.labelHi : signal.category.labelEn,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: hindi
                    ? signal.severity.label.toUpperCase()
                    : signal.severity.label.toUpperCase(),
                color: color,
                dense: true,
              ),
            ],
          ),
          if (explain.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              explain,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (signal.evidence.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final item in signal.evidence.take(4))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.28)),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontFamily: 'monospace',
                        color: color.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static IconData _iconFor(RiskCategory category) => switch (category) {
    RiskCategory.urgency => Icons.timer_outlined,
    RiskCategory.threat => Icons.gavel_outlined,
    RiskCategory.payment => Icons.currency_rupee,
    RiskCategory.credential => Icons.key_outlined,
    RiskCategory.impersonation => Icons.badge_outlined,
    RiskCategory.prize => Icons.card_giftcard_outlined,
    RiskCategory.link => Icons.link_outlined,
    RiskCategory.remoteAccess => Icons.desktop_windows_outlined,
    RiskCategory.secrecy => Icons.visibility_off_outlined,
    RiskCategory.job => Icons.work_outline,
    RiskCategory.investment => Icons.trending_up,
    RiskCategory.loan => Icons.account_balance_wallet_outlined,
    RiskCategory.upi => Icons.qr_code_2_outlined,
    RiskCategory.format => Icons.text_fields,
    RiskCategory.knownPattern => Icons.fingerprint,
  };
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.inkSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.inkLine),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 28),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: AppColors.textMuted,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

/// Small stat block for the scan screen footer.
class StatBlock extends StatelessWidget {
  const StatBlock({
    required this.value,
    required this.label,
    super.key,
    this.color = AppColors.textPrimary,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
