import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/common.dart';
import '../../data/models/portfolio.dart';
import 'projects_view_model.dart';

class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  // The text controller is UI plumbing; the query itself lives in the view model.
  late final _search = TextEditingController(text: context.read<ProjectsViewModel>().query);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final md = context.isMd;
    final vm = context.watch<ProjectsViewModel>();
    final heading = SectionHeading(eyebrow: 'Projects', title: 'Selected work', lead: vm.lead);
    final search = _SearchField(controller: _search, onChanged: vm.search);
    final items = vm.visible;

    return Section(
      alt: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: md
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: heading),
                      const SizedBox(width: 24),
                      SizedBox(width: 288, child: search),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [heading, const SizedBox(height: 24), search],
                  ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in vm.categories)
                _FilterPill(
                  label: c,
                  selected: c == vm.category,
                  onTap: () => vm.selectCategory(c),
                ),
            ],
          ),
          const SizedBox(height: 32),
          if (items.isEmpty)
            const _EmptyState()
          else
            ResponsiveGrid(
              columns: md ? 2 : 1,
              children: [
                for (final (i, p) in items.indexed)
                  Reveal(
                    key: ValueKey(p.title),
                    delay: Reveal.stagger(i % 2),
                    child: _ProjectCard(p),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppTextField(
      controller: controller,
      hint: 'Search by name or technology',
      onChanged: onChanged,
      prefixIcon: Icon(Icons.search, size: 18, color: pal.muted),
      suffix: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, value, _) => value.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                tooltip: 'Clear search',
                iconSize: 16,
                icon: Icon(Icons.close, color: pal.muted),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
      ),
    );
  }
}


class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Semantics(
      button: true,
      selected: selected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? pal.text : pal.bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? pal.text : pal.border),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? pal.bg : pal.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard(this.project);
  final Project project;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      padding: EdgeInsets.zero,
      semanticLabel: '${project.title}, view details',
      onTap: () => showProjectDialog(context, project),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: pal.surface,
              border: Border(bottom: BorderSide(color: pal.border)),
            ),
            alignment: Alignment.centerLeft,
            child: IconTile(project.icon, size: 48, neutral: true),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(project.category),
                  const SizedBox(height: 8),
                  Text(
                    project.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: pal.text),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, height: 1.6, color: pal.muted),
                  ),
                  const SizedBox(height: 16),
                  ChipWrap(project.tags),
                  const SizedBox(height: 20),
                  const Spacer(),
                  const ArrowLink('View details'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: pal.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pal.border),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 32, color: pal.muted),
          const SizedBox(height: 12),
          Text(
            'No projects found',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: pal.text),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or category.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: pal.muted),
          ),
        ],
      ),
    );
  }
}

Future<void> showProjectDialog(BuildContext context, Project p) {
  return showAppDialog(
    context,
    maxWidth: 576,
    label: p.title,
    builder: (ctx) {
      final pal = ctx.pal;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTile(p.icon, size: 48),
          const SizedBox(height: 16),
          Eyebrow(p.category),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Semantics(
              header: true,
              child: Text(
                p.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: pal.text),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(p.description, style: TextStyle(fontSize: 15, height: 1.65, color: pal.muted)),
          const SizedBox(height: 24),
          Text(
            'Built with',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: pal.text),
          ),
          const SizedBox(height: 10),
          ChipWrap(p.tags),
          if (p.hasDemo || p.hasSource) ...[
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (p.hasDemo)
                  AppButton(
                    label: 'Live demo',
                    icon: Icons.open_in_new,
                    onPressed: () => openUrl(p.demoUrl!),
                  ),
                if (p.hasSource)
                  AppButton(
                    label: 'Source code',
                    icon: Icons.code,
                    kind: ButtonKind.secondary,
                    onPressed: () => openUrl(p.sourceUrl!),
                  ),
              ],
            ),
          ],
        ],
      );
    },
  );
}
