import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Set to false in tests so google_fonts never touches the network.
bool useWebFonts = true;

/// Tailwind-style breakpoints.
class Bp {
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
}

extension BpContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isSm => screenWidth >= Bp.sm;
  bool get isMd => screenWidth >= Bp.md;
  bool get isLg => screenWidth >= Bp.lg;
  Palette get pal => Theme.of(this).extension<Palette>()!;
}

@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.bg,
    required this.surface,
    required this.border,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentStrong,
    required this.onAccent,
    required this.success,
    required this.danger,
  });

  final Color bg;
  final Color surface;
  final Color border;
  final Color text;
  final Color muted;
  final Color accent;
  final Color accentStrong;
  final Color onAccent;
  final Color success;
  final Color danger;

  static const light = Palette(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFF8FAFC),
    border: Color(0xFFE2E8F0),
    text: Color(0xFF0F172A),
    muted: Color(0xFF475569),
    accent: Color(0xFF4F46E5),
    accentStrong: Color(0xFF4338CA),
    onAccent: Color(0xFFFFFFFF),
    success: Color(0xFF10B981),
    danger: Color(0xFFE11D48),
  );

  static const dark = Palette(
    bg: Color(0xFF09090B),
    surface: Color(0xFF141417),
    border: Color(0xFF27272A),
    text: Color(0xFFF4F4F5),
    muted: Color(0xFFA1A1AA),
    accent: Color(0xFF818CF8),
    accentStrong: Color(0xFFA5B4FC),
    onAccent: Color(0xFF09090B),
    success: Color(0xFF34D399),
    danger: Color(0xFFFB7185),
  );

  @override
  Palette copyWith({
    Color? bg,
    Color? surface,
    Color? border,
    Color? text,
    Color? muted,
    Color? accent,
    Color? accentStrong,
    Color? onAccent,
    Color? success,
    Color? danger,
  }) {
    return Palette(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      danger: danger ?? this.danger,
    );
  }

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) return this;
    return Palette(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

String? get _interFamily => useWebFonts ? GoogleFonts.inter().fontFamily : null;

/// JetBrains Mono for dates and small labels.
TextStyle mono(BuildContext context, {double size = 12, Color? color}) {
  final c = color ?? context.pal.muted;
  if (useWebFonts) {
    return GoogleFonts.jetBrainsMono(fontSize: size, color: c);
  }
  return TextStyle(fontFamily: 'monospace', fontSize: size, color: c);
}

ThemeData buildTheme(Brightness brightness) {
  final pal = brightness == Brightness.dark ? Palette.dark : Palette.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: pal.accent,
    brightness: brightness,
  ).copyWith(
    primary: pal.accent,
    onPrimary: pal.onAccent,
    surface: pal.bg,
    onSurface: pal.text,
    outline: pal.border,
    outlineVariant: pal.border,
    error: pal.danger,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: pal.bg,
    canvasColor: pal.bg,
    fontFamily: _interFamily,
    dividerColor: pal.border,
    dividerTheme: DividerThemeData(color: pal.border, thickness: 1, space: 1),
    splashFactory: NoSplash.splashFactory,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: pal.accent,
      selectionColor: pal.accent.withValues(alpha: 0.25),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: pal.text,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: TextStyle(color: pal.bg, fontSize: 12),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: pal.bg,
      surfaceTintColor: Colors.transparent,
    ),
    extensions: [pal],
  );
}
