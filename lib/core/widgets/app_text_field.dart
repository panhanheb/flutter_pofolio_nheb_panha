import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shared text input: radius 8, 1px border, accent border + soft ring on focus.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.hint,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
    this.onSubmitted,
    this.enabled = true,
    this.label,
  });
  final TextEditingController controller;
  final String? hint;
  final String? label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffix;
  final int? maxLength;
  final int minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pal = context.pal;
    final focused = _focus.hasFocus;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: c),
        );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (focused) BoxShadow(color: pal.accent.withValues(alpha: 0.18), spreadRadius: 3),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        style: TextStyle(fontSize: 14, color: pal.text),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hint,
          labelText: null,
          counterText: '',
          hintStyle: TextStyle(fontSize: 14, color: pal.muted.withValues(alpha: 0.75)),
          filled: true,
          fillColor: pal.bg,
          prefixIcon: widget.prefixIcon,
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: widget.suffix,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: border(pal.border),
          enabledBorder: border(pal.border),
          disabledBorder: border(pal.border),
          focusedBorder: border(pal.accent),
        ),
      ),
    );
  }
}

