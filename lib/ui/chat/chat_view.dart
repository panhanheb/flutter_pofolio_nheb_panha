import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/app_text_field.dart';
import 'chat_view_model.dart';


/// Floating chat button and panel. State and sending live in [ChatViewModel];
/// this view owns only the text field and list scroll controllers.
class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final ChatViewModel _vm = context.read<ChatViewModel>();
  int _shownCount = 0;

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onChanged);
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Keep the newest message in view.
  void _onChanged() {
    final count = _vm.messages.length + (_vm.busy ? 1 : 0);
    if (count == _shownCount) return;
    _shownCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _send([String? preset]) {
    final text = preset ?? _input.text;
    if (text.trim().isEmpty || _vm.busy) return;
    if (preset == null) _input.clear();
    _vm.send(text);
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final vm = context.watch<ChatViewModel>();
    final size = MediaQuery.sizeOf(context);
    final width = math.min(360.0, size.width - 32);
    final height = math.max(0.0, math.min(500.0, size.height - 120));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (vm.open) ...[
          Container(
            width: width,
            height: height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: pal.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: pal.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  _header(pal, vm),
                  Expanded(child: _messages(pal, vm)),
                  _composer(pal, vm),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _ToggleButton(open: vm.open, onTap: vm.toggle),
      ],
    );
  }

  Widget _header(Palette pal, ChatViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: pal.border))),
      child: Row(
        children: [
          const IconTile(Icons.smart_toy_outlined, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask about Panha',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: pal.text),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: pal.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'AI assistant · usually instant',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: pal.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.close,
            tooltip: 'Close chat',
            bordered: false,
            onPressed: vm.close,
          ),
        ],
      ),
    );
  }

  Widget _messages(Palette pal, ChatViewModel vm) {
    return ColoredBox(
      color: pal.surface,
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        children: [
          _Bubble(fromUser: false, text: vm.greeting),
          for (final m in vm.messages) _Bubble(fromUser: m.fromUser, text: m.text),
          if (vm.busy) const _Typing(),
          if (vm.showQuickPrompts) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final q in vm.quickPrompts)
                  _QuickChip(label: q.label, onTap: () => _send(q.question)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _composer(Palette pal, ChatViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: pal.border))),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _input,
              hint: 'Ask a question…',
              maxLength: ChatViewModel.maxPromptLength,
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Send',
            child: Semantics(
              button: true,
              label: 'Send',
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: vm.busy ? pal.accent.withValues(alpha: 0.5) : pal.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.send, size: 18, color: pal.onAccent),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({required this.open, required this.onTap});
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Tooltip(
      message: open ? 'Close chat' : 'Chat with an AI assistant',
      child: Semantics(
        button: true,
        label: open ? 'Close chat' : 'Open chat',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: pal.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, a) => RotationTransition(
                  turns: Tween(begin: 0.75, end: 1.0).animate(a),
                  child: FadeTransition(opacity: a, child: child),
                ),
                child: Icon(
                  open ? Icons.close : Icons.forum_outlined,
                  key: ValueKey(open),
                  color: pal.onAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            fromUser ? 'You' : 'Assistant',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: pal.muted),
          ),
          const SizedBox(height: 4),
          FractionallySizedBox(
            widthFactor: 0.85,
            alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Align(
              alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: fromUser ? pal.accent : pal.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: fromUser ? null : Border.all(color: pal.border),
                ),
                child: SelectableText(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: fromUser ? pal.onAccent : pal.text,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Typing extends StatefulWidget {
  const _Typing();

  @override
  State<_Typing> createState() => _TypingState();
}

class _TypingState extends State<_Typing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!reduceMotion(context) && !_c.isAnimating) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Semantics(
      label: 'Assistant is typing',
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: pal.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: pal.border),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                    child: Opacity(
                      opacity: 0.3 + 0.7 * (0.5 + 0.5 * math.sin((_c.value - i * 0.18) * 2 * math.pi)),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: pal.muted, shape: BoxShape.circle),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pal.bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: pal.border),
            ),
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: pal.text),
            ),
          ),
        ),
      ),
    );
  }
}
