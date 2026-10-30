import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scam_engine/scam_engine.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/services/engine.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/hero_backdrop.dart';

class UpiScreen extends StatefulWidget {
  const UpiScreen({super.key});

  @override
  State<UpiScreen> createState() => _UpiScreenState();
}

class _UpiScreenState extends State<UpiScreen> {
  final TextEditingController _controller = TextEditingController();
  UpiIntent? _intent;
  String? _error;

  static const List<({String label, String value})> _samples = [
    (
      label: 'pay link',
      value:
          'upi://pay?pa=sharma.store@okhdfcbank&pn=Sharma%20Store&am=250&cu=INR&mc=5411',
    ),
    (
      label: 'collect',
      value: 'upi://collect?pa=seller99@okaxis&am=5000&cu=INR',
    ),
    (label: 'typo handle', value: 'rahul@okhdfbank'),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_intent != null || _error != null) {
        setState(() {
          _intent = null;
          _error = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _inspect() {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      _toast(context.t('upi.empty'));
      return;
    }
    FocusScope.of(context).unfocus();
    if (!UpiLinkParser.looksLikeUpi(input)) {
      setState(() {
        _intent = null;
        _error = context.t('upi.notUpi');
      });
      return;
    }
    setState(() {
      _error = null;
      _intent = Engine.inspectUpi(input);
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
              Text(
                context.t('upi.title'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                context.t('upi.body'),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                minLines: 3,
                maxLines: 5,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: context.t('upi.hint'),
                  hintStyle: const TextStyle(
                    fontFamily: null,
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final sample in _samples)
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => _controller.text = sample.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.inkSoft,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.inkLine),
                              ),
                              child: Text(
                                sample.label,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final data =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (data?.text != null) {
                        _controller.text = data!.text!.trim();
                      }
                    },
                    icon: const Icon(Icons.content_paste, size: 18),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FilledButton.icon(
                onPressed: _inspect,
                icon: const Icon(Icons.search, size: 20),
                label: Text(context.t('upi.action')),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                _ErrorCard(message: _error!),
              ],
              if (_intent != null) ...[
                const SizedBox(height: 20),
                _IntentCard(intent: _intent!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.caution.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.caution.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.caution,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntentCard extends StatelessWidget {
  const _IntentCard({required this.intent});

  final UpiIntent intent;

  @override
  Widget build(BuildContext context) {
    final hindi = context.isHindi;
    final worst = intent.worstSeverity;
    final color = intent.warnings.isEmpty
        ? AppColors.safe
        : AppColors.forSeverity(worst);
    final amount = intent.amount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconFor(intent.operation),
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hindi
                          ? intent.operation.labelHi
                          : intent.operation.labelEn,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.t('upi.operation'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (amount != null)
                Text(
                  _rupees(amount),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (intent.payeeAddress != null) ...[
            InfoRow(
              label: context.t('upi.payee'),
              value: intent.payeeAddress!,
              mono: true,
              selectable: true,
            ),
            _HandleBadge(address: intent.payeeAddress!),
          ],
          if (intent.payeeName != null)
            InfoRow(
              label: context.t('upi.payeeName'),
              value: intent.payeeName!,
            ),
          if (intent.merchantCode != null)
            InfoRow(
              label: context.t('upi.merchant'),
              value: intent.merchantCode!,
              mono: true,
            ),
          if (intent.transactionNote != null)
            InfoRow(
              label: context.t('upi.note'),
              value: intent.transactionNote!,
            ),
          if (intent.transactionRef != null)
            InfoRow(
              label: context.t('upi.ref'),
              value: intent.transactionRef!,
              mono: true,
            ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            context.t('upi.warnings').toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          if (intent.warnings.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                context.t('upi.noWarnings'),
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            for (final warning in intent.warnings)
              _WarningRow(warning: warning),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  static IconData _iconFor(UpiOperation operation) => switch (operation) {
        UpiOperation.pay => Icons.north_east,
        UpiOperation.collect => Icons.south_west,
        UpiOperation.mandate => Icons.autorenew,
        UpiOperation.unknown => Icons.help_outline,
      };

  static String _rupees(double value) {
    final whole = value.round();
    final text = whole.toString();
    if (text.length <= 3) return '₹$text';
    final last3 = text.substring(text.length - 3);
    var rest = text.substring(0, text.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '₹${parts.join(',')},$last3';
  }
}

class _HandleBadge extends StatelessWidget {
  const _HandleBadge({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    final vpa = VpaInspector.parse(address);
    if (vpa == null) {
      return Padding(
        padding: const EdgeInsets.only(left: 122, bottom: 6),
        child: StatusPill(
          label: context.t('upi.handle.unknown'),
          color: AppColors.caution,
          icon: Icons.help_outline,
          dense: true,
        ),
      );
    }

    final known = PspRegistry.isKnown(vpa.handle);
    final lookalikes =
        known ? const <String>[] : PspRegistry.lookalikes(vpa.handle);
    final isTypo = lookalikes.isNotEmpty;
    final color = known
        ? AppColors.safe
        : (isTypo ? AppColors.dangerous : AppColors.caution);
    final label = known
        ? context.t('upi.handle.known')
        : (isTypo
            ? context.t('upi.handle.typosquat')
            : context.t('upi.handle.unknown'));

    return Padding(
      padding: const EdgeInsets.only(left: 122, bottom: 8),
      child: StatusPill(
        label: isTypo ? '$label · ${lookalikes.first}' : label,
        color: color,
        icon: known ? Icons.verified_outlined : Icons.report_outlined,
        dense: true,
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  const _WarningRow({required this.warning});

  final UpiWarning warning;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forSeverity(warning.severity);
    final message = context.isHindi ? warning.messageHi : warning.messageEn;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(_iconFor(warning.severity), size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(Severity severity) => switch (severity) {
        Severity.info => Icons.info_outline,
        Severity.low => Icons.info_outline,
        Severity.medium => Icons.error_outline,
        Severity.high => Icons.warning_amber_rounded,
        Severity.critical => Icons.dangerous_outlined,
      };
}
