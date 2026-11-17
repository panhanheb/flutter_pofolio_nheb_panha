import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
}

bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

// ---------------------------------------------------------------- Layout

/// Max width 1152, centred, side padding 32 (≥640) or 20.
class PageContainer extends StatelessWidget {
  const PageContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1152),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.isSm ? 32 : 20),
          child: child,
        ),
      ),
    );
  }
}

/// Full-width section. "alt" sections use the surface fill with borders.
class Section extends StatelessWidget {
  const Section({super.key, this.alt = false, required this.child});
  final bool alt;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final v = context.isMd ? 112.0 : 80.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: alt ? pal.surface : pal.bg,
        border: alt
            ? Border.symmetric(horizontal: BorderSide(color: pal.border))
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: v),
        child: PageContainer(child: child),
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.7,
        color: context.pal.accent,
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.lead,
  });
  final String eyebrow;
  final String title;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(eyebrow),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(
            title,
            style: TextStyle(
              fontSize: context.isSm ? 36 : 30,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
              height: 1.15,
              color: pal.text,
            ),
          ),
        ),
        if (lead != null) ...[
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: Text(
              lead!,
              style: TextStyle(
                fontSize: context.isMd ? 18 : 16,
                height: 1.6,
                color: pal.muted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Lays children out in rows of [columns]; each row's cards share the
/// tallest card's height.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.columns,
    required this.children,
    this.spacing = 24,
  });
  final int columns;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = <Widget>[];
      for (var c = 0; c < columns; c++) {
        if (c > 0) cells.add(SizedBox(width: spacing));
        final idx = i + c;
        cells.add(Expanded(
          child: idx < children.length ? children[idx] : const SizedBox.shrink(),
        ));
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

// ---------------------------------------------------------------- Cards

/// bg fill, 1px border, radius 16, padding 24. With [onTap] the border turns
/// accent on hover.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(24),
    this.semanticLabel,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final String? semanticLabel;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final interactive = widget.onTap != null;
    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: pal.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: interactive && _hover ? pal.accent.withValues(alpha: 0.45) : pal.border,
        ),
      ),
      padding: widget.padding,
      child: widget.child,
    );
    if (!interactive) return card;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: card,
        ),
      ),
    );
  }
}

/// 40×40 (or [size]) accent-tinted rounded icon tile.
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.size = 40, this.neutral = false});
  final IconData icon;
  final double size;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: neutral ? pal.bg : pal.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size >= 48 ? 12 : 10),
        border: Border.all(
          color: neutral ? pal.border : pal.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(icon, size: size * 0.5, color: pal.accent),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pal.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: pal.border),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: pal.muted),
      ),
    );
  }
}

class ChipWrap extends StatelessWidget {
  const ChipWrap(this.labels, {super.key});
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final l in labels) TagChip(l)],
    );
  }
}

// ---------------------------------------------------------------- Buttons

enum ButtonKind { primary, secondary }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = ButtonKind.primary,
    this.arrow = false,
    this.icon,
    this.compact = false,
    this.expand = false,
    this.loading = false,
    this.tooltip,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonKind kind;
  final bool arrow;
  final IconData? icon;
  final bool compact;
  final bool expand;
  final bool loading;
  final String? tooltip;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final primary = widget.kind == ButtonKind.primary;
    final enabled = widget.onPressed != null && !widget.loading;

    final bg = primary
        ? (_hover && enabled ? pal.accentStrong : pal.accent)
        : (_hover && enabled ? pal.surface : pal.bg);
    final fg = primary ? pal.onAccent : pal.text;

    final children = <Widget>[
      if (widget.loading) ...[
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
        ),
        const SizedBox(width: 8),
      ] else if (widget.icon != null) ...[
        Icon(widget.icon, size: 16, color: fg),
        const SizedBox(width: 8),
      ],
      Flexible(
        child: Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg),
        ),
      ),
      if (widget.arrow) ...[
        AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(left: _hover ? 11 : 8),
          child: Icon(Icons.arrow_forward, size: 16, color: fg),
        ),
      ],
    ];

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: widget.compact ? 36 : 44,
      padding: EdgeInsets.symmetric(horizontal: widget.compact ? 14 : 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primary ? bg : pal.border),
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );

    button = Semantics(
      button: true,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.onPressed : null,
          child: Opacity(opacity: enabled || widget.loading ? 1 : 0.6, child: button),
        ),
      ),
    );
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

/// Bordered square icon button (theme toggle, GitHub, close).
class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 36,
    this.bordered = true,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;
  final bool bordered;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _hover ? pal.surface : (widget.bordered ? pal.bg : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
                border: widget.bordered ? Border.all(color: pal.border) : null,
              ),
              child: Icon(widget.icon, size: 18, color: _hover ? pal.text : pal.muted),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accent text link with optional trailing arrow, e.g. "View details →".
class ArrowLink extends StatelessWidget {
  const ArrowLink(this.label, {super.key, this.hover = false});
  final String label;
  final bool hover;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: pal.accent),
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.arrow_forward, size: 14, color: pal.accent),
      ],
    );
  }
}

// ---------------------------------------------------------------- Motion

/// Fades in and slides up 14px the first time it scrolls into view.
/// Skipped entirely when reduce-motion is on.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.immediate = false,
  });
  final Widget child;
  final Duration delay;

  /// Animate on load instead of on scroll (hero).
  final bool immediate;

  /// Stagger helper: 70ms per item.
  static Duration stagger(int i) => Duration(milliseconds: 70 * i);

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  ScrollPosition? _position;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.value = 1;
      _started = true;
    }
    final pos = Scrollable.maybeOf(context)?.position;
    if (pos != _position) {
      _position?.removeListener(_check);
      _position = pos;
      _position?.addListener(_check);
    }
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_started || !mounted) return;
    if (widget.immediate) return _start();
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      return;
    }
    final top = box.localToGlobal(Offset.zero).dy;
    final viewport = MediaQuery.sizeOf(context).height;
    if (top < viewport * 0.92 && top + box.size.height > 0) _start();
  }

  void _start() {
    _started = true;
    _position?.removeListener(_check);
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _position?.removeListener(_check);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value;
        if (v >= 1) return child!;
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- Dialog

/// Shared dialog shell: max width, 90% max height, scrollable, Esc closes.
Future<void> showAppDialog(
  BuildContext context, {
  required double maxWidth,
  required String label,
  required Widget Function(BuildContext) builder,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    barrierLabel: 'Close',
    builder: (ctx) {
      final pal = ctx.pal;
      final h = MediaQuery.sizeOf(ctx).height;
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: pal.bg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: pal.border),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: h * 0.9),
          child: Semantics(
            container: true,
            label: label,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: builder(ctx),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: AppIconButton(
                    icon: Icons.close,
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
