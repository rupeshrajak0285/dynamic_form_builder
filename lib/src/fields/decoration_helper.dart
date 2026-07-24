import 'package:flutter/material.dart';

import '../controllers/dynamic_form_controller.dart';
import '../models/field_config.dart';
import '../models/field_style.dart';
import '../theme/dynamic_form_theme.dart';
import '../utils/field_utils.dart';

/// Resolves the effective [FieldStyleConfig] for a field by merging, in
/// order of increasing precedence: the app theme default, the form-level
/// `style`, and the field's own `style` / `decoration`.
FieldStyleConfig resolveFieldStyle(
  BuildContext context,
  FieldConfig field,
  DynamicFormController controller,
) {
  final theme = DynamicFormTheme.of(context);
  return FieldStyleConfig.merge([
    theme.defaultFieldStyle,
    controller.config?.style,
    field.styleConfig,
  ]);
}

InputBorder _border(
    FieldStyleVariant variant, double radius, Color? color, double width) {
  final side = color == null
      ? BorderSide(width: width)
      : BorderSide(color: color, width: width);
  switch (variant) {
    case FieldStyleVariant.underline:
      return UnderlineInputBorder(borderSide: side);
    case FieldStyleVariant.filled:
      return OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none);
    case FieldStyleVariant.none:
      return InputBorder.none;
    case FieldStyleVariant.outlined:
    case FieldStyleVariant.rounded:
      return OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius), borderSide: side);
  }
}

/// Builds the standard [InputDecoration] for a field, honoring JSON props,
/// JSON style variants and the app-level
/// [DynamicFormThemeData.decorationBuilder] hook.
InputDecoration buildFieldDecoration(
  BuildContext context,
  FieldConfig field,
  DynamicFormController controller, {
  String? errorText,
  Widget? suffix,
}) {
  final theme = DynamicFormTheme.of(context);
  final style = resolveFieldStyle(context, field, controller);

  var decoration = InputDecoration(
    labelText: field.label,
    hintText: field.hint,
    helperText: field.helperText,
    errorText: errorText,
    isDense: style.dense ?? theme.dense,
    prefixIcon: FieldUtils.icon(field.prefixIcon) != null
        ? Icon(FieldUtils.icon(field.prefixIcon))
        : null,
    suffixIcon: suffix ??
        (FieldUtils.icon(field.suffixIcon) != null
            ? Icon(FieldUtils.icon(field.suffixIcon))
            : null),
  );

  if (style.isNotEmpty) {
    final variant = style.variant;
    if (variant != null) {
      final radius = style.borderRadius ??
          switch (variant) {
            FieldStyleVariant.rounded => 28.0,
            FieldStyleVariant.filled => 12.0,
            _ => 8.0,
          };
      final width = style.borderWidth ?? 1;
      final base = _border(variant, radius, style.borderColor, width);
      final focused = _border(
          variant,
          radius,
          style.focusedBorderColor ?? Theme.of(context).colorScheme.primary,
          width + 1);
      final error =
          _border(variant, radius, Theme.of(context).colorScheme.error, width);
      decoration = decoration.copyWith(
        border: base,
        enabledBorder: base,
        focusedBorder:
            variant == FieldStyleVariant.none ? InputBorder.none : focused,
        errorBorder:
            variant == FieldStyleVariant.none ? InputBorder.none : error,
        focusedErrorBorder:
            variant == FieldStyleVariant.none ? InputBorder.none : error,
        filled: variant == FieldStyleVariant.filled || style.fillColor != null,
      );
    }
    decoration = decoration.copyWith(
      fillColor: style.fillColor,
      filled: style.fillColor != null ? true : decoration.filled,
      contentPadding: style.contentPadding,
      labelStyle: style.labelStyle,
      hintStyle: style.hintStyle,
      floatingLabelBehavior: switch (style.labelBehavior) {
        'always' => FloatingLabelBehavior.always,
        'never' => FloatingLabelBehavior.never,
        'auto' => FloatingLabelBehavior.auto,
        _ => null,
      },
    );
  }

  if (theme.decorationBuilder != null) {
    decoration = theme.decorationBuilder!(context, field, decoration);
  }
  return decoration;
}
