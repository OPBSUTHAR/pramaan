import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data/samples.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/services/engine.dart';
import '../../../core/services/history_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/hero_backdrop.dart';
import '../../../core/widgets/risk_gauge.dart';
import '../../../core/widgets/settings_sheet.dart';
import '../../result/presentation/result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _scanning = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      _toast(context.t('scan.clipboardEmpty'));
      return;
    }
    _controller.text = text;
    _toast(context.t('scan.pasted'));
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _scan() async {
    final text = _controller.text.trim();
    if (text.length < 12) {
      _toast(context.t('scan.tooShort'));
      return;
    }
    _focus.unfocus();
    setState(() => _scanning = true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;

    final report = Engine.scan(text);
    await HistoryScope.read(context).add(SavedScan.fromReport(report));
    if (!mounted) return;

    setState(() => _scanning = false);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(report: report),
      ),
    );
    if (!mounted) return;
    setState(() {});
  }

  void _openSamples() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('scan.action.example'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  context.t('common.demo'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                for (final sample in sampleMessages)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _controller.text = sample.body;
                        _scan();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.ink,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.inkLine),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sms_outlined,
                              size: 18,
                              color: AppColors.saffron,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.isHindi
                                    ? sample.labelHi
                                    : sample.labelEn,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
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

  @override
  Widget build(BuildContext context) {
    final history = HistoryScope.of(context);
    final recent = history.items.take(3).toList(growable: false);
    final chars = _controller.text.trim().length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: HeroBackdrop(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              _TopBar(onSettings: () => showSettingsSheet(context)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('scan.hero.title'),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.t('scan.hero.body'),
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(
                          icon: Icons.phonelink_lock,
                          keyName: 'scan.badge.offline',
                        ),
                        _Badge(
                          icon: Icons.airplanemode_active,
                          keyName: 'scan.badge.airplane',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _InputCard(
                      controller: _controller,
                      focus: _focus,
                      focused: _focused,
                      scanning: _scanning,
                      chars: chars,
                      onPaste: _paste,
                      onClear: () {
                        _controller.clear();
                        _focus.requestFocus();
                      },
                      onSample: _openSamples,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: _scanning ? null : _scan,
                      icon: _scanning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF1A1200),
                              ),
                            )
                          : const Icon(Icons.search, size: 20),
                      label: Text(context.t('scan.action.scan')),
                    ),
                    const SizedBox(height: 22),
                    const _StatsCard(),
                    const SizedBox(height: 14),
                    const _DnaTipCard(),
                  ],
                ),
              ),
              SectionHeader(title: context.t('scan.recent')),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.inkSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.inkLine),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_toggle_off,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.t('scan.recent.empty'),
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final item in recent)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _RecentTile(item: item),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 14, 0),
      child: Row(
        children: [
          const PramaanMark(size: 40, glow: true),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('app.name'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  context.t('app.subtitle'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: controller.toggle,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.inkSoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.inkLine),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.translate,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.isHindi ? 'हिं' : 'EN',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined, size: 21),
            color: AppColors.textSecondary,
            tooltip: context.t('common.settings'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.keyName});

  final IconData icon;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.mint.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.mint),
          const SizedBox(width: 6),
          Text(
            context.t(keyName),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.mint,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.controller,
    required this.focus,
    required this.focused,
    required this.scanning,
    required this.chars,
    required this.onPaste,
    required this.onClear,
    required this.onSample,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final bool focused;
  final bool scanning;
  final int chars;
  final VoidCallback onPaste;
  final VoidCallback onClear;
  final VoidCallback onSample;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.inkSoft,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: focused ? AppColors.saffron : AppColors.inkLine,
              width: focused ? 1.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: ScanSweep(
              active: scanning,
              child: TextField(
                controller: controller,
                focusNode: focus,
                maxLines: 7,
                minLines: 5,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 14.5, height: 1.55),
                decoration: InputDecoration(
                  hintText: context.t('scan.input.hint'),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _GhostAction(
                    icon: Icons.content_paste,
                    label: context.t('scan.action.paste'),
                    onTap: onPaste,
                  ),
                  _GhostAction(
                    icon: Icons.close,
                    label: context.t('scan.action.clear'),
                    onTap: onClear,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$chars',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onSample,
            icon: const Icon(Icons.bolt_outlined, size: 16),
            label: Text(
              context.t('scan.action.example'),
              style: const TextStyle(fontSize: 12.5),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.inkLine),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.inkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: StatBlock(
              value: '${Engine.ruleCount}',
              label: context.t('scan.stats.rules'),
              color: AppColors.saffron,
            ),
          ),
          Container(width: 1, height: 34, color: AppColors.inkLine),
          const SizedBox(width: 16),
          Expanded(
            child: StatBlock(
              value: '${Engine.templateCount}',
              label: context.t('scan.stats.patterns'),
              color: AppColors.mint,
            ),
          ),
          Container(width: 1, height: 34, color: AppColors.inkLine),
          const SizedBox(width: 16),
          Expanded(
            child: StatBlock(
              value: 'हिं + EN',
              label: context.t('scan.stats.languages'),
              color: AppColors.sky,
            ),
          ),
        ],
      ),
    );
  }
}

class _DnaTipCard extends StatelessWidget {
  const _DnaTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lilac.withValues(alpha: 0.28)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lilac.withValues(alpha: 0.13),
            AppColors.inkSoft.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.lilac.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.fingerprint,
              size: 20,
              color: AppColors.lilac,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('scan.dna.title'),
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.t('scan.dna.body'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.item});

  final SavedScan item;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forRisk(item.level);
    final title = context.isHindi
        ? (item.topTitleHi ?? item.topTitleEn)
        : (item.topTitleEn ?? item.topTitleHi);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        final report = Engine.scan(item.input);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultScreen(report: report),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inkSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inkLine),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.score}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? item.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
