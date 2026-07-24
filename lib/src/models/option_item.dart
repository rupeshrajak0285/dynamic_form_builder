/// A selectable option for dropdowns, radio groups, chips, etc.
class OptionItem {
  /// Creates an option.
  const OptionItem({
    required this.label,
    required this.value,
    this.enabled = true,
    this.icon,
    this.extra = const {},
  });

  /// Parses an option from JSON. Accepts `{"label": ..., "value": ...}`
  /// or a bare scalar used as both label and value.
  factory OptionItem.fromJson(Object? json) {
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      return OptionItem(
        label: map['label']?.toString() ?? map['value']?.toString() ?? '',
        value: map['value'],
        enabled: map['enabled'] as bool? ?? true,
        icon: map['icon'] as String?,
        extra: Map<String, dynamic>.from(map['extra'] as Map? ?? const {}),
      );
    }
    return OptionItem(label: json.toString(), value: json);
  }

  /// Display label.
  final String label;

  /// Value written into form data when selected.
  final Object? value;

  /// Whether this option can be selected.
  final bool enabled;

  /// Optional icon name (resolved by the field renderer / custom builder).
  final String? icon;

  /// Arbitrary extra data (e.g. country dial codes).
  final Map<String, dynamic> extra;

  @override
  bool operator ==(Object other) =>
      other is OptionItem && other.value == value && other.label == label;

  @override
  int get hashCode => Object.hash(label, value);
}
