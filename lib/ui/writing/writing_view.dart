import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../data/models/portfolio.dart';
import 'writing_view_model.dart';

class WritingView extends StatelessWidget {
  const WritingView({super.key});

  @override
  Widget build(BuildContext context) {
    final cols = context.isLg ? 3 : (context.isSm ? 2 : 1);
    final vm = context.watch<WritingViewModel>();
    return Section(
      alt: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: SectionHeading(
              eyebrow: 'Writing',
              title: 'Notes and articles',
              lead: vm.lead,
            ),
          ),
          const SizedBox(height: 48),
          ResponsiveGrid(
            columns: cols,
            children: [
              for (final (i, p) in vm.posts.indexed)
                Reveal(delay: Reveal.stagger(i % cols), child: _PostCard(p)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.post);
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Eyebrow(post.category),
        Text('·', style: mono(context)),
        Text(post.date, style: mono(context)),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard(this.post);
  final Post post;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return AppCard(
      semanticLabel: '${post.title}, read article',
      onTap: () => showPostDialog(context, post),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Meta(post),
          const SizedBox(height: 12),
          Text(
            post.title,
            style: TextStyle(fontSize: 17, height: 1.35, fontWeight: FontWeight.w600, color: pal.text),
          ),
          const SizedBox(height: 10),
          Text(
            post.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, height: 1.6, color: pal.muted),
          ),
          const SizedBox(height: 20),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  post.readTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono(context),
                ),
              ),
              const SizedBox(width: 8),
              const ArrowLink('Read'),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showPostDialog(BuildContext context, Post post) {
  return showAppDialog(
    context,
    maxWidth: 672,
    label: post.title,
    builder: (ctx) {
      final pal = ctx.pal;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Eyebrow(post.category),
                Text('·', style: mono(ctx)),
                Text(post.date, style: mono(ctx)),
                Text('·', style: mono(ctx)),
                Text(post.readTime, style: mono(ctx)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Semantics(
              header: true,
              child: Text(
                post.title,
                style: TextStyle(
                  fontSize: ctx.isSm ? 26 : 22,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: pal.text,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text('By ${ctx.read<WritingViewModel>().author}', style: TextStyle(fontSize: 14, color: pal.muted)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          ArticleBody(post.content),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          ChipWrap(post.tags),
        ],
      );
    },
  );
}

/// Renders an article body parsed by [WritingViewModel.parse].
class ArticleBody extends StatelessWidget {
  const ArticleBody(this.content, {super.key});
  final String content;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final blocks = WritingViewModel.parse(content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, b) in blocks.indexed)
          if (b.isHeading)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 12, bottom: 8),
              child: Semantics(
                header: true,
                child: Text(
                  b.text,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: pal.text),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(b.text, style: TextStyle(fontSize: 15, height: 1.75, color: pal.muted)),
            ),
      ],
    );
  }
}
