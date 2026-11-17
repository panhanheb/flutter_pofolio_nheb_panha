import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/portfolio.dart';
import 'about_view_model.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final vm = context.read<AboutViewModel>();

    final left = Reveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'About',
            title: 'Developer with an eye for detail and data',
          ),
          const SizedBox(height: 20),
          for (final p in vm.paragraphs) ...[
            Text(p, style: TextStyle(fontSize: 15, height: 1.7, color: pal.muted)),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 8),
          ChipWrap(vm.coreStack),
        ],
      ),
    );

    final grid = ResponsiveGrid(
      columns: context.isSm ? 2 : 1,
      spacing: 16,
      children: [
        for (final (i, s) in vm.services.indexed)
          Reveal(delay: Reveal.stagger(i + 1), child: _ServiceCard(s)),
      ],
    );

    return Section(
      alt: true,
      child: context.isLg
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: left),
                const SizedBox(width: 48),
                Expanded(flex: 7, child: grid),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [left, const SizedBox(height: 40), grid],
            ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard(this.service);
  final Service service;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(service.icon),
          const SizedBox(height: 16),
          Text(
            service.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: pal.text),
          ),
          const SizedBox(height: 8),
          Text(service.text, style: TextStyle(fontSize: 14, height: 1.6, color: pal.muted)),
        ],
      ),
    );
  }
}
