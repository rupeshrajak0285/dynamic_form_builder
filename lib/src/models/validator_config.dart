/// JSON-configurable validator description.
///
/// ```json
/// {"type": "minLength", "value": 8, "message": "Too short"}
/// ```
class ValidatorConfig {
  /// Creates a validator config.
  const ValidatorConfig({
    required this.type,
    this.value,
    this.message,
    this.params = const {},
  });

  /// Parses a validator from JSON. Accepts a map or a bare string
  /// (`"required"` is shorthand for `{"type": "required"}`).
  factory ValidatorConfig.fromJson(Object? json) {
    if (json is String) return ValidatorConfig(type: json);
    final map = Map<String, dynamic>.from(json as Map? ?? const {});
    return ValidatorConfig(
      type: map['type']?.toString() ?? 'custom',
      value: map['value'],
      message: map['message'] as String?,
      params: Map<String, dynamic>.from(map)
        ..remove('type')
        ..remove('value')
        ..remove('message'),
    );
  }

  /// Validator type: required, email, phone, url, number, decimal, min, max,
  /// minLength, maxLength, regex, matchField, passwordStrength, custom.
  final String type;

  /// Primary parameter (e.g. the minimum for `min`).
  final Object? value;

  /// Custom error message overriding the localized default.
  final String? message;

  /// Additional named parameters.
  final Map<String, dynamic> params;
}
