import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/portfolio.dart';
import 'skills_view_model.dart';

class SkillsView extends StatelessWidget {
  const SkillsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cols = context.isLg ? 3 : (context.isSm ? 2 : 1);
    final vm = context.read<SkillsViewModel>();
    final cards = <Widget>[
      for (final g in vm.groups) _GroupCard(g),
      _PracticesCard(vm.practices),
    ];
    return Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Reveal(
            child: SectionHeading(
              eyebrow: 'Skills',
              title: 'Tools and technologies',
              lead: 'The stack I use day to day, grouped by where it fits in a product.',
            ),
          ),
          const SizedBox(height: 48),
          ResponsiveGrid(
            columns: cols,
            children: [
              for (final (i, c) in cards.indexed)
                Reveal(delay: Reveal.stagger(i % cols), child: c),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.icon, this.title);
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconTile(icon, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.pal.text),
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard(this.group);
  final SkillGroup group;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardTitle(group.icon, group.title),
          const SizedBox(height: 16),
          for (final (i, item) in group.items.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: i == 0 ? null : Border(top: BorderSide(color: pal.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.$1,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: pal.text),
                    ),
                  ),
                  if (item.$2 != null) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        item.$2!,
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 12, color: pal.muted),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PracticesCard extends StatelessWidget {
  const _PracticesCard(this.practices);
  final List<String> practices;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitle(Icons.lightbulb_outline, 'How I work'),
          const SizedBox(height: 16),
          for (final p in practices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.check, size: 16, color: pal.success),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(p, style: TextStyle(fontSize: 14, height: 1.55, color: pal.muted)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
