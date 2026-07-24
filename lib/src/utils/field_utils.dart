import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/field_config.dart';
import '../models/field_type.dart';

/// Shared helpers mapping JSON strings to Flutter types.
class FieldUtils {
  const FieldUtils._();

  /// Resolves a keyboard type from JSON (falls back per field type).
  static TextInputType keyboardType(FieldConfig f) {
    switch (f.keyboardType) {
      case 'number':
        return TextInputType.number;
      case 'decimal':
        return const TextInputType.numberWithOptions(decimal: true);
      case 'phone':
        return TextInputType.phone;
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      case 'multiline':
        return TextInputType.multiline;
      case 'text':
        return TextInputType.text;
    }
    switch (f.type) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.number:
        return TextInputType.number;
      case FieldType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.url:
        return TextInputType.url;
      case FieldType.textarea:
      case FieldType.richText:
      case FieldType.markdown:
      case FieldType.htmlEditor:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  /// Resolves the input action from JSON.
  static TextInputAction? inputAction(FieldConfig f) {
    switch (f.textInputAction) {
      case 'next':
        return TextInputAction.next;
      case 'done':
        return TextInputAction.done;
      case 'search':
        return TextInputAction.search;
      case 'send':
        return TextInputAction.send;
      case 'go':
        return TextInputAction.go;
    }
    return f.type == FieldType.search ? TextInputAction.search : null;
  }

  /// Input formatters per field type.
  static List<TextInputFormatter> formatters(FieldConfig f) => [
        if (f.type == FieldType.number)
          FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
        if (f.type == FieldType.decimal)
          FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]')),
        if (f.type == FieldType.phone)
          FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s()]')),
        if (f.maxLength != null) LengthLimitingTextInputFormatter(f.maxLength),
      ];

  /// Resolves a Material icon by common name (subset; apps can use custom
  /// builders for anything else).
  static IconData? icon(String? name) {
    if (name == null) return null;
    const icons = <String, IconData>{
      'person': Icons.person,
      'email': Icons.email,
      'phone': Icons.phone,
      'lock': Icons.lock,
      'search': Icons.search,
      'calendar': Icons.calendar_today,
      'time': Icons.access_time,
      'link': Icons.link,
      'location': Icons.location_on,
      'home': Icons.home,
      'visibility': Icons.visibility,
      'star': Icons.star,
      'camera': Icons.camera_alt,
      'image': Icons.image,
      'file': Icons.attach_file,
      'edit': Icons.edit,
      'money': Icons.attach_money,
      'flag': Icons.flag,
      'city': Icons.location_city,
      'qr': Icons.qr_code_scanner,
      'barcode': Icons.barcode_reader,
      'color': Icons.palette,
      'check': Icons.check,
    };
    return icons[name];
  }
}
