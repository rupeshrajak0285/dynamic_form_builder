import 'package:flutter/widgets.dart';

import 'condition.dart';
import 'field_style.dart';
import 'field_type.dart';
import 'option_item.dart';
import 'validator_config.dart';

/// Async loader signature for dynamic options (remote APIs, databases…).
///
/// Receives the field id and the current form data so dependent lookups
/// (state list depending on selected country) are possible.
typedef OptionsLoader = Future<List<OptionItem>> Function(
    String fieldId, Map<String, dynamic> formData);

/// Immutable configuration of a single form field, parsed from JSON.
class FieldConfig {
  /// Creates a field configuration.
  const FieldConfig({
    required this.id,
    required this.type,
    this.name,
    this.label,
    this.hint,
    this.helperText,
    this.initialValue,
    this.defaultValue,
    this.required = false,
    this.enabled = true,
    this.readOnly = false,
    this.visible = true,
    this.autofocus = false,
    this.obscureText = false,
    this.maxLength,
    this.minLength,
    this.regex,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.validators = const [],
    this.options = const [],
    this.optionsUrl,
    this.visibleWhen,
    this.enabledWhen,
    this.requiredWhen,
    this.fields = const [],
    this.styleConfig,
    this.extra = const {},
  });

  /// Parses a field (and recursively its children) from JSON.
  factory FieldConfig.fromJson(Map<String, dynamic> json) {
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

    Condition? cond(Object? raw) =>
        raw is Map ? Condition.fromJson(Map<String, dynamic>.from(raw)) : null;

    // `decoration` and `style` maps are merged into one style config
    // (style wins on conflicts).
    final styleRaw = <String, dynamic>{
      if (json['decoration'] is Map)
        ...Map<String, dynamic>.from(json['decoration'] as Map),
      if (json['style'] is Map)
        ...Map<String, dynamic>.from(json['style'] as Map),
    };

    final known = {
      'style',
      'decoration',
      'id',
      'key',
      'name',
      'type',
      'label',
      'hint',
      'helperText',
      'initialValue',
      'defaultValue',
      'required',
      'enabled',
      'readOnly',
      'visible',
      'autofocus',
      'obscureText',
      'maxLength',
      'minLength',
      'regex',
      'keyboardType',
      'textInputAction',
      'prefixIcon',
      'suffixIcon',
      'padding',
      'margin',
      'width',
      'height',
      'validators',
      'items',
      'options',
      'optionsUrl',
      'visibleWhen',
      'enabledWhen',
      'requiredWhen',
      'fields',
    };

    return FieldConfig(
      id: json['id']?.toString() ?? json['key']?.toString() ?? '',
      name: json['name']?.toString(),
      type: FieldType.fromString(json['type']?.toString() ?? 'text'),
      label: json['label'] as String?,
      hint: json['hint'] as String?,
      helperText: json['helperText'] as String?,
      initialValue: json['initialValue'],
      defaultValue: json['defaultValue'],
      required: json['required'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
      readOnly: json['readOnly'] as bool? ?? false,
      visible: json['visible'] as bool? ?? true,
      autofocus: json['autofocus'] as bool? ?? false,
      obscureText: json['obscureText'] as bool? ?? false,
      maxLength: (json['maxLength'] as num?)?.toInt(),
      minLength: (json['minLength'] as num?)?.toInt(),
      regex: json['regex'] as String?,
      keyboardType: json['keyboardType'] as String?,
      textInputAction: json['textInputAction'] as String?,
      prefixIcon: json['prefixIcon'] as String?,
      suffixIcon: json['suffixIcon'] as String?,
      padding: edge(json['padding']),
      margin: edge(json['margin']),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      validators: (json['validators'] as List? ?? const [])
          .map(ValidatorConfig.fromJson)
          .toList(),
      options: ((json['items'] ?? json['options']) as List? ?? const [])
          .map(OptionItem.fromJson)
          .toList(),
      optionsUrl: json['optionsUrl'] as String?,
      visibleWhen: cond(json['visibleWhen']),
      enabledWhen: cond(json['enabledWhen']),
      requiredWhen: cond(json['requiredWhen']),
      fields: (json['fields'] as List? ?? const [])
          .map((e) => FieldConfig.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      styleConfig:
          styleRaw.isEmpty ? null : FieldStyleConfig.fromJson(styleRaw),
      extra: Map<String, dynamic>.from(json)
        ..removeWhere((k, _) => known.contains(k)),
    );
  }

  /// Unique field id — the key used in form data and the controller API.
  final String id;

  /// Optional form-submission name (defaults to [id]).
  final String? name;

  /// Rendered field type.
  final FieldType type;

  /// Floating label text.
  final String? label;

  /// Placeholder hint.
  final String? hint;

  /// Helper text under the field.
  final String? helperText;

  /// Value shown when the form first builds (wins over [defaultValue]).
  final Object? initialValue;

  /// Value restored on [reset] when no initial value exists.
  final Object? defaultValue;

  /// Statically required (see also [requiredWhen]).
  final bool required;

  /// Statically enabled (see also [enabledWhen]).
  final bool enabled;

  /// Read-only rendering.
  final bool readOnly;

  /// Statically visible (see also [visibleWhen]).
  final bool visible;

  /// Autofocus on build.
  final bool autofocus;

  /// Obscure input (defaults to true for password/pin types).
  final bool obscureText;

  /// Maximum input length.
  final int? maxLength;

  /// Minimum input length (validated).
  final int? minLength;

  /// Regex pattern (both input filter hint and validator shorthand).
  final String? regex;

  /// Keyboard type name: text, number, decimal, phone, email, url, multiline.
  final String? keyboardType;

  /// Input action name: next, done, search, send, go.
  final String? textInputAction;

  /// Material icon name for the prefix icon.
  final String? prefixIcon;

  /// Material icon name for the suffix icon.
  final String? suffixIcon;

  /// Inner padding around the field.
  final EdgeInsets? padding;

  /// Outer margin around the field.
  final EdgeInsets? margin;

  /// Fixed width.
  final double? width;

  /// Fixed height.
  final double? height;

  /// JSON-configured validators.
  final List<ValidatorConfig> validators;

  /// Static options for selection fields.
  final List<OptionItem> options;

  /// Remote options URL (resolved by the app's registered [OptionsLoader]).
  final String? optionsUrl;

  /// Condition controlling visibility.
  final Condition? visibleWhen;

  /// Condition controlling enablement.
  final Condition? enabledWhen;

  /// Condition controlling required-ness.
  final Condition? requiredWhen;

  /// Child fields (group, expansion, steps).
  final List<FieldConfig> fields;

  /// Per-field appearance override (parsed from `style` / `decoration`).
  final FieldStyleConfig? styleConfig;

  /// Type-specific extras (min, max, divisions, rows, length, colors…).
  final Map<String, dynamic> extra;

  /// Convenience typed accessor into [extra].
  T? ex<T>(String key) {
    final v = extra[key];
    if (v is T) return v;
    if (T == double && v is num) return v.toDouble() as T;
    if (T == int && v is num) return v.toInt() as T;
    return null;
  }

  /// Copies this config overriding selected properties.
  FieldConfig copyWith({
    bool? required,
    bool? enabled,
    bool? visible,
    List<OptionItem>? options,
    List<ValidatorConfig>? validators,
  }) =>
      FieldConfig(
        id: id,
        name: name,
        type: type,
        label: label,
        hint: hint,
        helperText: helperText,
        initialValue: initialValue,
        defaultValue: defaultValue,
        required: required ?? this.required,
        enabled: enabled ?? this.enabled,
        readOnly: readOnly,
        visible: visible ?? this.visible,
        autofocus: autofocus,
        obscureText: obscureText,
        maxLength: maxLength,
        minLength: minLength,
        regex: regex,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        padding: padding,
        margin: margin,
        width: width,
        height: height,
        validators: validators ?? this.validators,
        options: options ?? this.options,
        optionsUrl: optionsUrl,
        visibleWhen: visibleWhen,
        enabledWhen: enabledWhen,
        requiredWhen: requiredWhen,
        fields: fields,
        styleConfig: styleConfig,
        extra: extra,
      );
}
