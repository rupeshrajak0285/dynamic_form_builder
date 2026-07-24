import '../controllers/dynamic_form_controller.dart';

/// Ergonomic typed accessors on the controller.
extension DynamicFormControllerX on DynamicFormController {
  /// Value of [id] as a String (null-safe).
  String? getString(String id) => getValue(id)?.toString();

  /// Value of [id] as an int, parsing strings when needed.
  int? getInt(String id) {
    final v = getValue(id);
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '');
  }

  /// Value of [id] as a double, parsing strings when needed.
  double? getDouble(String id) {
    final v = getValue(id);
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '');
  }

  /// Value of [id] as a bool (defaults to false).
  bool getBool(String id) => getValue(id) == true;

  /// Value of [id] as a list.
  List<Object?> getList(String id) =>
      List<Object?>.from(getValue(id) as List? ?? const []);

  /// Whether the form currently has any errors.
  bool get hasErrors => getErrors().isNotEmpty;
}
