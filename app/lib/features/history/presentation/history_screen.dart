import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/services/engine.dart';
import '../../../core/services/history_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../result/presentation/result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = HistoryScope.of(context);
    final items = store.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('history.title')),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: context.t('history.clear'),
              onPressed: () => _confirmClear(context, store),
              icon: const Icon(Icons.delete_sweep_outlined, size: 21),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.history_toggle_off,
              title: context.t('history.empty'),
              body: context.t('history.body'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: AppColors.mint,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            context.t('history.body'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final item = items[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.critical.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.critical,
                      ),
                    ),
                    onDismissed: (_) => store.remove(item.id),
                    child: _HistoryTile(item: item),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, HistoryStore store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.inkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.inkLine),
        ),
        title: Text(context.t('history.clear')),
        content: Text(context.t('history.clear.confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.t('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.critical),
            child: Text(context.t('common.delete')),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await store.clear();
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final SavedScan item;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forRisk(item.level);
    final hindi = context.isHindi;
    final level = hindi ? item.level.labelHi : item.level.labelEn;
    final title = hindi ? item.topTitleHi : item.topTitleEn;
    final template = hindi ? item.templateTitleHi : item.templateTitleEn;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        final report = Engine.scan(item.input);
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ResultScreen(report: report)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inkLine),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Text(
                '${item.score}',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusPill(
                        label: level.toUpperCase(),
                        color: color,
                        dense: true,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _relative(item.at, context),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    title ?? template ?? item.preview,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relative(DateTime at, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    final time =
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

    final diff = today.difference(day).inDays;
    if (diff == 0) return '${context.t('common.today')} · $time';
    if (diff == 1) return '${context.t('common.yesterday')} · $time';
    return '${at.day.toString().padLeft(2, '0')}/'
        '${at.month.toString().padLeft(2, '0')}/${at.year}';
  }
}
