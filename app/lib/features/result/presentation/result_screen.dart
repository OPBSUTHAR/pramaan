import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scam_engine/scam_engine.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/risk_gauge.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({required this.report, super.key});

  final ScanReport report;

  @override
  Widget build(BuildContext context) {
    final hindi = context.isHindi;
    final color = AppColors.forRisk(report.level);
    final levelLabel = hindi ? report.level.labelHi : report.level.labelEn;
    final advice = hindi ? report.level.adviceHi : report.level.adviceEn;
    final signals = [...report.signals]
      ..sort((a, b) => b.effectiveWeight.compareTo(a.effectiveWeight));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('result.title')),
        actions: [
          IconButton(
            tooltip: context.t('result.copy'),
            onPressed: () => _copyVerdict(context, levelLabel),
            icon: const Icon(Icons.copy_all_outlined, size: 20),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Center(
            child: RiskGauge(score: report.score, level: report.level),
          ),
          const SizedBox(height: 14),
          Center(
            child: StatusPill(
              label: levelLabel.toUpperCase(),
              color: color,
              icon: _iconFor(report.level),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            advice,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          if (report.templateMatch != null) ...[
            const SizedBox(height: 24),
            _DnaCard(match: report.templateMatch!),
          ],
          const SizedBox(height: 26),
          if (signals.isEmpty)
            const _CleanCard()
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.t('result.why'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                StatusPill(
                  label: '${signals.length}',
                  color: color,
                  dense: true,
                  icon: Icons.bolt,
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final signal in signals) SignalTile(signal: signal),
          ],
          if (report.upiFindings.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              context.t('result.upi'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final vpa in report.upiFindings)
                  StatusPill(
                    label: vpa,
                    color: AppColors.sky,
                    icon: Icons.alternate_email,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.inkSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.inkLine),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.memory,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${context.t('result.templateSource')} · '
                    '${(report.durationMicros / 1000).toStringAsFixed(1)} ms',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.refresh, size: 20),
            label: Text(context.t('result.newScan')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _copyWarning(context, levelLabel),
            icon: const Icon(Icons.ios_share, size: 18),
            label: Text(context.t('result.share')),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(RiskLevel level) => switch (level) {
        RiskLevel.safe => Icons.verified_user_outlined,
        RiskLevel.caution => Icons.info_outline,
        RiskLevel.suspicious => Icons.report_problem_outlined,
        RiskLevel.dangerous => Icons.warning_amber_rounded,
        RiskLevel.critical => Icons.dangerous_outlined,
      };

  Future<void> _copyVerdict(BuildContext context, String levelLabel) async {
    final hindi = context.isHindi;
    final top = report.topSignal;
    final tpl = report.templateMatch;
    final buffer = StringBuffer()
      ..writeln('Pramaan · ${report.score}/100 · $levelLabel')
      ..writeln(
        hindi
            ? 'भेजने से पहले प्रमाण।'
            : 'Proof before you pay.',
      );
    if (tpl != null) {
      buffer.writeln(
        '${context.t('result.dna')}: '
        '${hindi ? tpl.titleHi : tpl.titleEn} '
        '(${(tpl.similarity * 100).round()}%)',
      );
    }
    if (top != null) {
      buffer.writeln(
        '${context.t('result.why')}: '
        '${hindi ? top.titleHi : top.titleEn}',
      );
    }
    buffer.write(
      hindi
          ? 'OTP, UPI पिन या स्क्रीन एक्सेस किसी को न दें। शिकायत: 1930 / cybercrime.gov.in'
          : 'Never share an OTP, UPI PIN or screen access. Report: 1930 / cybercrime.gov.in',
    );
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    _snack(context, context.t('result.copied'));
  }

  Future<void> _copyWarning(BuildContext context, String levelLabel) async {
    final hindi = context.isHindi;
    final text = hindi
        ? '⚠️ प्रमाण ने यह संदेश ठगी बताया (${report.score}/100 · $levelLabel)। '
            'जवाब न दें, पैसा न भेजें, OTP या UPI पिन साझा न करें। '
            'शिकायत: 1930 या cybercrime.gov.in'
        : '⚠️ Pramaan flagged this message as a scam '
            '(${report.score}/100 · $levelLabel). Do not reply, do not pay, '
            'and never share an OTP or UPI PIN. Report: 1930 or '
            'cybercrime.gov.in';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    _snack(context, context.t('result.copied'));
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DnaCard extends StatelessWidget {
  const _DnaCard({required this.match});

  final TemplateMatch match;

  @override
  Widget build(BuildContext context) {
    final hindi = context.isHindi;
    final percent = (match.similarity * 100).round();
    final title = hindi ? match.titleHi : match.titleEn;
    final family = hindi ? match.familyHi : match.familyEn;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lilac.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lilac.withValues(alpha: 0.14),
            AppColors.inkCard,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fingerprint,
                size: 18,
                color: AppColors.lilac,
              ),
              const SizedBox(width: 8),
              Text(
                context.t('result.dna').toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: AppColors.lilac,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lilac,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${context.t('result.dna.family')}: $family · '
            '${match.confidenceLabel} ${context.t('result.confidence')}',
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: match.similarity.clamp(0, 1),
              minHeight: 6,
              backgroundColor: AppColors.inkLine,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.lilac),
            ),
          ),
        ],
      ),
    );
  }
}

class _CleanCard extends StatelessWidget {
  const _CleanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.mint,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.t('result.clean'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.t('result.clean.body'),
            style: const TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
