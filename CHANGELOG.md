# Changelog

## 0.2.0

- **Edit mode / prefilled forms**: `DynamicForm(initialData: record)`, JSON
  root `"data"` map, and `setFormData(record, asInitial: true)`. Prefilled
  forms start clean, `reset()` restores the record, and the dirty baseline
  survives runtime JSON changes.

- **Field UI styles from JSON**: `style` / `decoration` at theme, form and
  field level with variants `outlined`, `rounded`, `filled`, `underline`,
  `none` plus borderRadius, fill/border colors, contentPadding,
  labelBehavior and text/label/hint styles.
- **Dirty tracking**: `controller.isDirty`, listenable `controller.dirty`,
  `markClean()`; auto-clean on attach, reset and successful submit.
- **Discard guard**: JSON `"confirmDiscard": true` shows a localized
  unsaved-changes dialog on back navigation; custom `discardTitle` /
  `discardMessage`, code override via `DynamicForm(confirmDiscard: ...)`,
  fully custom dialog via `DynamicFormThemeData.discardDialogBuilder`.

## 0.1.0

Initial release.

- 50+ JSON-driven field types (text family, date/time, selection, sliders,
  rating, stepper, color picker, OTP/PIN, autocomplete, layout fields,
  expansion/group nesting, pluggable adapter types).
- `DynamicFormController` with full value / validation / focus /
  visibility / structure-mutation API and `listen()`.
- JSON-configurable validators (required, email, phone, url, number,
  decimal, min, max, minLength, maxLength, regex, matchField,
  passwordStrength) + custom validator registry.
- Conditional logic (`visibleWhen` / `enabledWhen` / `requiredWhen`) with
  and/or/not and 12 comparison operators.
- Async options loading with `dependsOn` chains (country → state → city).
- Multi-step wizard forms with per-step validation.
- Per-field `ValueNotifier` rebuilds + lazy `ListView.builder` rendering.
- Theming hooks (`DynamicFormTheme`) and full renderer override via
  `FieldFactory`.
- Localized messages: en, hi, ar (RTL), es, fr, de + custom translations.
