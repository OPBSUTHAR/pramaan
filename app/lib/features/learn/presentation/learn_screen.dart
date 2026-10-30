import 'package:flutter/material.dart';
import 'package:scam_engine/scam_engine.dart';

import '../../../core/data/learn_library.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/hero_backdrop.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextEditingController _search = TextEditingController();
  String _family = '*';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() => _query = _search.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> get _families {
    final seen = <String>{};
    for (final template in builtInTemplates) {
      seen.add(template.familyEn);
    }
    final list = seen.toList()..sort();
    return list;
  }

  List<ScamTemplate> get _visible {
    return builtInTemplates.where((template) {
      if (_family != '*' && template.familyEn != _family) return false;
      if (_query.isEmpty) return true;
      return template.titleEn.toLowerCase().contains(_query) ||
          template.titleHi.contains(_query) ||
          template.body.toLowerCase().contains(_query) ||
          template.familyEn.toLowerCase().contains(_query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: HeroBackdrop(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('learn.title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t('learn.body'),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _search,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: context.t('learn.search'),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 34,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _FilterChip(
                              label: context.t('learn.all'),
                              selected: _family == '*',
                              onTap: () => setState(() => _family = '*'),
                            ),
                            for (final family in _families)
                              _FilterChip(
                                label: _familyLabel(family),
                                selected: _family == family,
                                onTap: () => setState(() => _family = family),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
              if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: context.t('learn.empty'),
                    body: context.t('learn.body'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  sliver: SliverList.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final template = visible[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TemplateCard(template: template),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _familyLabel(String family) {
    if (!context.isHindi) return family;
    for (final template in builtInTemplates) {
      if (template.familyEn == family) return template.familyHi;
    }
    return family;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.saffron.withValues(alpha: 0.15)
                : AppColors.inkSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.saffron : AppColors.inkLine,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.saffron : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatefulWidget {
  const _TemplateCard({required this.template});

  final ScamTemplate template;

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    final hindi = context.isHindi;
    final guide = guideFor(template.familyEn);
    final title = hindi ? template.titleHi : template.titleEn;
    final family = hindi ? template.familyHi : template.familyEn;
    final flags = hindi ? guide.flagsHi : guide.flagsEn;
    final advice = hindi ? guide.adviceHi : guide.adviceEn;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _open
              ? AppColors.saffron.withValues(alpha: 0.35)
              : AppColors.inkLine,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          family.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
                _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inkLine),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('learn.example').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          template.body,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.t('learn.redFlags').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.critical,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final flag in flags)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Icon(
                              Icons.circle,
                              size: 5,
                              color: AppColors.critical,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              flag,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.mint.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('learn.action').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.mint,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          advice,
                          style: const TextStyle(
                            fontSize: 13,
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
        ],
      ),
    );
  }
}
