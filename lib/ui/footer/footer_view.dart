import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import 'footer_view_model.dart';

class FooterView extends StatelessWidget {
  const FooterView({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final sm = context.isSm;
    final vm = context.read<FooterViewModel>();

    final copyright = Text(
      vm.copyright,
      textAlign: sm ? TextAlign.left : TextAlign.center,
      style: TextStyle(fontSize: 14, color: pal.muted),
    );
    final links = Wrap(
      spacing: 20,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [for (final l in vm.links) _FooterLink(l)],
    );

    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: pal.border))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: PageContainer(
          child: sm
              ? Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 24,
                  runSpacing: 12,
                  children: [copyright, links],
                )
              : Column(children: [copyright, const SizedBox(height: 16), links]),
        ),
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink(this.link);
  final FooterLink link;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => openUrl(widget.link.url),
          child: Text(
            widget.link.label,
            style: TextStyle(fontSize: 14, color: _hover ? pal.text : pal.muted),
          ),
        ),
      ),
    );
  }
}
