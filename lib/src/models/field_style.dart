import 'package:flutter/material.dart';

/// Visual variant of an input field, selectable from JSON.
enum FieldStyleVariant {
  /// Classic outlined border (Material `OutlineInputBorder`).
  outlined,

  /// Pill-shaped outlined border (large corner radius).
  rounded,

  /// Filled background with no visible border.
  filled,

  /// Single underline (classic Material).
  underline,

  /// No border at all.
  none;

  /// Parses a variant name from JSON (`"rounded"`, `"filled"`, …).
  static FieldStyleVariant? fromString(String? raw) {
    if (raw == null) return null;
    for (final v in FieldStyleVariant.values) {
      if (v.name == raw.toLowerCase().trim()) return v;
    }
    return null;
  }
}

/// JSON-configurable field appearance. Can be set at three levels — app
/// theme ([DynamicFormThemeData.defaultFieldStyle]), form root
/// (`"style": {...}` in the form JSON) and per field (`"style"` /
/// `"decoration"` on the field) — merged in that order, most specific wins.
///
/// ```json
/// {
///   "style": {
///     "variant": "rounded",
///     "fillColor": "#F1F3FF",
///     "borderColor": "#3F51B5",
///     "borderRadius": 24,
///     "textStyle": {"fontSize": 16, "fontWeight": "w600"}
///   }
/// }
/// ```
class FieldStyleConfig {
  /// Creates a style config.
  const FieldStyleConfig({
    this.variant,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderWidth,
    this.dense,
    this.contentPadding,
    this.labelBehavior,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
  });

  /// Parses a style config from a JSON map.
  factory FieldStyleConfig.fromJson(Map<String, dynamic> json) {
    EdgeInsets? edge(Object? raw) {
      if (raw is num) return EdgeInsets.all(raw.toDouble());
      if (raw is Map) {
        final m = Map<String, dynamic>.from(raw);
        double d(String k) => (m[k] as num?)?.toDouble() ?? 0;
        return EdgeInsets.fromLTRB(
            d('left'), d('top'), d('right'), d('bottom'));
      }
      return null;
    }

    return FieldStyleConfig(
      variant: FieldStyleVariant.fromString(
          (json['variant'] ?? json['type'])?.toString()),
      borderRadius:
          ((json['borderRadius'] ?? json['radius']) as num?)?.toDouble(),
      fillColor: parseColor(json['fillColor']),
      borderColor: parseColor(json['borderColor']),
      focusedBorderColor: parseColor(json['focusedBorderColor']),
      borderWidth: (json['borderWidth'] as num?)?.toDouble(),
      dense: json['dense'] as bool?,
      contentPadding: edge(json['contentPadding']),
      labelBehavior: json['labelBehavior'] as String?,
      textStyle: parseTextStyle(json['textStyle']),
      labelStyle: parseTextStyle(json['labelStyle']),
      hintStyle: parseTextStyle(json['hintStyle']),
    );
  }

  /// Border/background variant.
  final FieldStyleVariant? variant;

  /// Corner radius (defaults per variant: outlined 8, filled 12, rounded 28).
  final double? borderRadius;

  /// Background fill color (implies `filled: true`).
  final Color? fillColor;

  /// Border color in the enabled state.
  final Color? borderColor;

  /// Border color when focused (defaults to the theme primary color).
  final Color? focusedBorderColor;

  /// Border stroke width.
  final double? borderWidth;

  /// Dense layout.
  final bool? dense;

  /// Inner content padding.
  final EdgeInsets? contentPadding;

  /// `auto` (float on focus), `always`, or `never`.
  final String? labelBehavior;

  /// Style of the entered text.
  final TextStyle? textStyle;

  /// Style of the label.
  final TextStyle? labelStyle;

  /// Style of the hint.
  final TextStyle? hintStyle;

  /// Whether any property is set.
  bool get isNotEmpty =>
      variant != null ||
      borderRadius != null ||
      fillColor != null ||
      borderColor != null ||
      focusedBorderColor != null ||
      borderWidth != null ||
      dense != null ||
      contentPadding != null ||
      labelBehavior != null ||
      textStyle != null ||
      labelStyle != null ||
      hintStyle != null;

  /// Merges [layers] left to right — later non-null properties win.
  static FieldStyleConfig merge(List<FieldStyleConfig?> layers) {
    var result = const FieldStyleConfig();
    for (final layer in layers) {
      if (layer == null) continue;
      result = FieldStyleConfig(
        variant: layer.variant ?? result.variant,
        borderRadius: layer.borderRadius ?? result.borderRadius,
        fillColor: layer.fillColor ?? result.fillColor,
        borderColor: layer.borderColor ?? result.borderColor,
        focusedBorderColor:
            layer.focusedBorderColor ?? result.focusedBorderColor,
        borderWidth: layer.borderWidth ?? result.borderWidth,
        dense: layer.dense ?? result.dense,
        contentPadding: layer.contentPadding ?? result.contentPadding,
        labelBehavior: layer.labelBehavior ?? result.labelBehavior,
        textStyle: layer.textStyle ?? result.textStyle,
        labelStyle: layer.labelStyle ?? result.labelStyle,
        hintStyle: layer.hintStyle ?? result.hintStyle,
      );
    }
    return result;
  }

  /// Parses `#RRGGBB`, `#AARRGGBB` or `0xAARRGGBB` color strings.
  static Color? parseColor(Object? raw) {
    if (raw == null) return null;
    var s = raw.toString().replaceFirst('#', '').replaceFirst('0x', '');
    if (s.length == 6) s = 'FF$s';
    final value = int.tryParse(s, radix: 16);
    return value == null ? null : Color(value);
  }

  /// Parses a text style map: `{"fontSize": 16, "color": "#333333",
  /// "fontWeight": "bold" | "w600", "italic": true, "letterSpacing": 1}`.
  static TextStyle? parseTextStyle(Object? raw) {
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    FontWeight? weight;
    final w = m['fontWeight']?.toString();
    if (w != null) {
      weight = switch (w) {
        'bold' => FontWeight.bold,
        'normal' => FontWeight.normal,
        'w100' => FontWeight.w100,
        'w200' => FontWeight.w200,
        'w300' => FontWeight.w300,
        'w400' => FontWeight.w400,
        'w500' => FontWeight.w500,
        'w600' => FontWeight.w600,
        'w700' => FontWeight.w700,
        'w800' => FontWeight.w800,
        'w900' => FontWeight.w900,
        _ => FontWeight.normal,
      };
    }
    return TextStyle(
      fontSize: (m['fontSize'] as num?)?.toDouble(),
      color: parseColor(m['color']),
      fontWeight: weight,
      fontStyle: m['italic'] == true ? FontStyle.italic : null,
      letterSpacing: (m['letterSpacing'] as num?)?.toDouble(),
    );
  }
}
