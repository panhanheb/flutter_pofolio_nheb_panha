import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/home_view_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import 'hero_view_model.dart';

class HeroView extends StatelessWidget {
  const HeroView({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final lg = context.isLg;
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _Backdrop(pal.accent, pal.border)),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: context.isMd ? 160 : 128, bottom: context.isMd ? 112 : 80),
          child: PageContainer(
            child: lg
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(flex: 7, child: Reveal(immediate: true, child: _Intro())),
                      const SizedBox(width: 40),
                      Expanded(
                        flex: 5,
                        child: Reveal(
                          immediate: true,
                          delay: Reveal.stagger(2),
                          child: const Align(alignment: Alignment.centerRight, child: _Portrait()),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Reveal(immediate: true, child: _Intro()),
                      const SizedBox(height: 56),
                      Reveal(
                        immediate: true,
                        delay: Reveal.stagger(2),
                        child: const Center(child: _Portrait()),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final p = context.read<HeroViewModel>().profile;
    final pal = context.pal;
    final sm = context.isSm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: pal.bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: pal.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: pal.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  p.availability,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: pal.muted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            p.name,
            style: TextStyle(
              fontSize: sm ? 60 : 46,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.6,
              height: 1.05,
              color: pal.text,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          p.role,
          style: TextStyle(fontSize: sm ? 24 : 20, fontWeight: FontWeight.w500, color: pal.muted),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 576),
          child: Text(
            p.intro,
            style: TextStyle(fontSize: sm ? 18 : 16, height: 1.6, color: pal.muted),
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppButton(
              label: 'View my work',
              arrow: true,
              onPressed: () => context.read<HomeViewModel>().navigateTo('projects'),
            ),
            AppButton(
              label: 'Get in touch',
              kind: ButtonKind.secondary,
              onPressed: () => context.read<HomeViewModel>().navigateTo('contact'),
            ),
            AppIconButton(
              icon: Icons.code,
              tooltip: 'GitHub',
              size: 44,
              onPressed: () => openUrl(p.githubUrl),
            ),
          ],
        ),
        const SizedBox(height: 40),
        DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: pal.border))),
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, f) in p.facts.indexed) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.$1,
                          style: TextStyle(fontSize: 12, color: pal.muted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          f.$2,
                          style: TextStyle(
                            fontSize: sm ? 15 : 14,
                            fontWeight: FontWeight.w600,
                            color: pal.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait();

  @override
  Widget build(BuildContext context) {
    final p = context.read<HeroViewModel>().profile;
    final pal = context.pal;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Padding(
        // Room for the outer ring (12px) and the hanging location card (20px).
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Outer ring 12px outside the photo.
            Positioned(
              left: -12,
              top: -12,
              right: -12,
              bottom: -12,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: pal.border),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: pal.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: pal.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: dark ? 0.4 : 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: Image.asset(
                        'assets/image/panha_portrait.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        semanticLabel: 'Portrait of ${p.name}',
                        frameBuilder: (context, child, frame, sync) {
                          if (sync) return child;
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Location card hanging 20px below the photo.
            const Positioned(left: 20, right: 20, bottom: -20, child: _LocationCard()),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    final p = context.read<HeroViewModel>().profile;
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: pal.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pal.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 18, color: pal.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              p.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: pal.text),
            ),
          ),
          const SizedBox(width: 8),
          Text(p.timezone, style: mono(context)),
        ],
      ),
    );
  }
}

/// Soft radial accent wash at top centre plus a faint 56px grid fading out.
class _Backdrop extends CustomPainter {
  _Backdrop(this.accent, this.line);
  final Color accent;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, 0);
    final radius = math.max(size.width * 0.6, 480.0);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: 0.14), accent.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Grid, faded with a radial mask from the top centre.
    canvas.saveLayer(rect, Paint());
    final gridPaint = Paint()
      ..color = line
      ..strokeWidth = 1;
    const step = 56.0;
    for (double x = (size.width / 2) % step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.9)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Backdrop old) => old.accent != accent || old.line != line;
}
