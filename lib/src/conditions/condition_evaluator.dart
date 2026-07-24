import '../models/condition.dart';

/// Evaluates [Condition] trees against current form data.
class ConditionEvaluator {
  const ConditionEvaluator._();

  /// Returns whether [condition] holds for [data].
  static bool evaluate(Condition condition, Map<String, dynamic> data) {
    if (condition.and != null) {
      return condition.and!.every((c) => evaluate(c, data));
    }
    if (condition.or != null) {
      return condition.or!.any((c) => evaluate(c, data));
    }
    if (condition.not != null) {
      return !evaluate(condition.not!, data);
    }
    return _leaf(condition, data);
  }

  static bool _leaf(Condition c, Map<String, dynamic> data) {
    final actual = data[c.field];
    final expected = c.value;
    switch (c.operator) {
      case 'equals':
      case 'eq':
      case '==':
        return _eq(actual, expected);
      case 'notEquals':
      case 'ne':
      case '!=':
        return !_eq(actual, expected);
      case 'greaterThan':
      case 'gt':
      case '>':
        return _cmp(actual, expected, (r) => r > 0);
      case 'greaterThanOrEqual':
      case 'gte':
      case '>=':
        return _cmp(actual, expected, (r) => r >= 0);
      case 'lessThan':
      case 'lt':
      case '<':
        return _cmp(actual, expected, (r) => r < 0);
      case 'lessThanOrEqual':
      case 'lte':
      case '<=':
        return _cmp(actual, expected, (r) => r <= 0);
      case 'contains':
        if (actual is Iterable) return actual.contains(expected);
        return actual?.toString().contains(expected.toString()) ?? false;
      case 'startsWith':
        return actual?.toString().startsWith(expected.toString()) ?? false;
      case 'endsWith':
        return actual?.toString().endsWith(expected.toString()) ?? false;
      case 'isEmpty':
        return actual == null ||
            (actual is String && actual.isEmpty) ||
            (actual is Iterable && actual.isEmpty);
      case 'isNotEmpty':
        return !_leaf(
            Condition.leaf(field: c.field!, operator: 'isEmpty'), data);
      case 'in':
        return (expected as Iterable?)?.any((e) => _eq(actual, e)) ?? false;
      default:
        return false;
    }
  }

  static bool _eq(Object? a, Object? b) {
    if (a is num && b is num) return a == b;
    if (a is num || b is num) {
      final na = num.tryParse(a.toString());
      final nb = num.tryParse(b.toString());
      if (na != null && nb != null) return na == nb;
    }
    return a == b;
  }

  static bool _cmp(Object? a, Object? b, bool Function(int) test) {
    final na = a is num ? a : num.tryParse(a?.toString() ?? '');
    final nb = b is num ? b : num.tryParse(b?.toString() ?? '');
    if (na == null || nb == null) return false;
    return test(na.compareTo(nb));
  }
}
