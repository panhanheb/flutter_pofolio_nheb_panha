import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/portfolio.dart';
import 'experience_view_model.dart';

class ExperienceView extends StatelessWidget {
  const ExperienceView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ExperienceViewModel>();
    return Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Reveal(
            child: SectionHeading(
              eyebrow: 'Experience',
              title: "Where I've worked",
              lead: 'Roles across mobile, web and backend development, most recent first.',
            ),
          ),
          const SizedBox(height: 56),
          for (final (i, job) in vm.jobs.indexed)
            Reveal(
              delay: Reveal.stagger(i),
              child: _TimelineEntry(job: job, first: vm.isCurrent(i), last: vm.isLast(i)),
            ),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.job, required this.first, required this.last});
  final Job job;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final md = context.isMd;

    final period = Text(job.period, style: mono(context));

    final rail = SizedBox(
      width: 13,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: first ? 6 : 0,
            bottom: last ? null : 0,
            height: last ? 6 : null,
            child: Container(width: 1, color: pal.border),
          ),
          Positioned(
            top: 4,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: first ? pal.accent : pal.bg,
                shape: BoxShape.circle,
                border: Border.all(color: first ? pal.accent : pal.border, width: 2),
              ),
            ),
          ),
        ],
      ),
    );

    final body = Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!md) ...[period, const SizedBox(height: 6)],
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                job.role,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: pal.text),
              ),
              TagChip(job.type),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${job.company} · ${job.location}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: pal.muted),
          ),
          const SizedBox(height: 12),
          Text(job.summary, style: TextStyle(fontSize: 15, height: 1.6, color: pal.muted)),
          const SizedBox(height: 12),
          for (final h in job.highlights)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 9, right: 10),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(color: pal.muted, shape: BoxShape.circle),
                    ),
                  ),
                  Expanded(
                    child: Text(h, style: TextStyle(fontSize: 14, height: 1.6, color: pal.muted)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          ChipWrap(job.tech),
        ],
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (md) ...[
            SizedBox(
              width: 144,
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Align(alignment: Alignment.topRight, child: period),
              ),
            ),
            const SizedBox(width: 24),
          ],
          rail,
          SizedBox(width: md ? 24 : 18),
          Expanded(child: body),
        ],
      ),
    );
  }
}
