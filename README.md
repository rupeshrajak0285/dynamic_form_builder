# dynamic_form_builder

JSON-driven dynamic form builder for Flutter. Generate complete, validated,
conditional, multi-step forms from JSON — with a powerful controller API,
50+ field types, theming, localization (en/hi/ar/es/fr/de + custom), and
**zero third-party dependencies**.

[![CI](https://github.com/rupeshrajak0285/dynamic_form_builder/actions/workflows/ci.yml/badge.svg)](https://github.com/rupeshrajak0285/dynamic_form_builder/actions)
[![pub package](https://img.shields.io/pub/v/dynamic_form_builder.svg)](https://pub.dev/packages/dynamic_form_builder)

## Why

- **Server-driven UI** — change forms without shipping an app update.
- **One controller for everything** — values, validation, focus, visibility,
  runtime add/remove of fields.
- **Performance-first** — every field listens to its own `ValueNotifier`s;
  typing in one field never rebuilds another. Fields render lazily via
  `ListView.builder`, so 1000+ field forms stay smooth.
- **Extensible by design** — every renderer, validator and field type can be
  overridden or added at runtime (Factory + Strategy patterns).

## Quick start

```dart
import 'package:dynamic_form_builder/dynamic_form_builder.dart';

final controller = DynamicFormController();

DynamicForm(
  controller: controller,
  json: const {
    'id': 'registration',
    'fields': [
      {'type': 'text', 'id': 'name', 'label': 'Full Name',
       'validators': ['required']},
      {'type': 'email', 'id': 'email', 'label': 'Email',
       'validators': ['required', 'email']},
      {'type': 'dropdown', 'id': 'country', 'label': 'Country',
       'items': [
         {'label': 'India', 'value': 'IN'},
         {'label': 'USA', 'value': 'US'},
       ]},
    ],
  },
  showSubmitButton: true,
  onSubmit: (data) => print(data),
  onChanged: (data) => print(data),
)
```

`json` accepts a JSON **string** or a decoded **map** — local asset, remote
API response, or built at runtime. Passing a new value re-parses the form and
preserves values of surviving field ids (runtime JSON changes).

## Field types

| Category | Types |
|---|---|
| Text | `text`, `textarea`, `password`, `email`, `number`, `decimal`, `phone`, `url`, `search`, `otp`, `pin`, `readOnly` |
| Date & time | `date`, `time`, `datetime` (stored as ISO-8601 strings) |
| Selection | `dropdown`, `multiselect`, `checkbox`, `checkboxGroup`, `radio`, `radioGroup`, `switch`, `chips`, `toggleButtons`, `segmented`, `country`, `state`, `city`, `autocomplete`, `typeahead` |
| Numeric | `slider`, `rangeSlider`, `rating`, `stepper` |
| Misc | `colorPicker`, `hidden`, `label`, `divider`, `spacer`, `sectionHeader`, `expansion`, `group`, `custom` |
| Pluggable | `image`, `camera`, `file`, `signature`, `qrScanner`, `barcodeScanner`, `richText`, `markdown`, `htmlEditor` |

**Pluggable types** keep the core dependency-free: the JSON schema, controller
and validation all work out of the box, and you register the widget backed by
the plugin of *your* choice once at startup:

```dart
FieldFactory.register(FieldType.image, (context, field, controller) {
  return MyImagePickerTile(   // e.g. wrapping package:image_picker
    onPicked: (path) => controller.setValue(field.id, path),
  );
});
```

Custom JSON types work the same way:

```dart
FieldFactory.registerCustom('map_picker', (context, field, controller) => ...);
// JSON: {"type": "custom", "id": "loc", "customType": "map_picker"}
```

## Common field properties

`id`, `key`, `name`, `label`, `hint`, `helperText`, `initialValue`,
`defaultValue`, `required`, `enabled`, `readOnly`, `visible`, `validators`,
`maxLength`, `minLength`, `regex`, `prefixIcon`, `suffixIcon`,
`keyboardType`, `textInputAction`, `autofocus`, `obscureText`, `padding`,
`margin`, `width`, `height` — plus type-specific extras (`min`, `max`,
`divisions`, `rows`, `length`, `multiple`, `colors`, `expanded`, …) available
via `field.ex<T>('name')`.

## Controller

```dart
final controller = DynamicFormController(locale: 'hi');

controller.getValue('name');
controller.setValue('name', 'John');
controller.clearField('name');
controller.reset();
controller.validate();                 // bool
controller.submit();                   // Map? (null when invalid)
controller.getFormData();
controller.setFormData({'name': 'A'});
controller.addField(FieldConfig.fromJson({...}), index: 2);
controller.removeField('name');
controller.hideField('state');  controller.showField('state');
controller.enableField('x');    controller.disableField('x');
controller.focusField('email'); controller.unfocus();
controller.getErrors();         controller.clearErrors();
final cancel = controller.listen('name', (value) => ...); cancel();
controller.dispose();
```

Typed helpers: `getString`, `getInt`, `getDouble`, `getBool`, `getList`,
`hasErrors`. Dirty state: `isDirty`, `dirty` (ValueListenable),
`markClean()`.

## Validation (JSON-configurable)

```json
{
  "type": "password", "id": "password",
  "validators": [
    "required",
    {"type": "passwordStrength"},
    {"type": "minLength", "value": 8, "message": "Too short"}
  ]
}
```

Built-in: `required`, `email`, `phone`, `url`, `number`, `decimal`, `min`,
`max`, `minLength`, `maxLength`, `regex`, `matchField`, `passwordStrength`.

Custom validators, usable from JSON by name:

```dart
ValidatorRegistry.register('gstin', (cfg) => CustomValidator(cfg,
    (value, formData) => isGstin('$value') ? null : 'Invalid GSTIN'));
```

## Conditional logic

```json
{"type": "dropdown", "id": "state",
 "visibleWhen": {"field": "country", "operator": "equals", "value": "IN"}}

{"type": "text", "id": "license",
 "enabledWhen": {"field": "age", "operator": "greaterThanOrEqual", "value": 18}}

{"type": "text", "id": "gst",
 "requiredWhen": {"and": [
   {"field": "country", "operator": "equals", "value": "IN"},
   {"field": "business", "operator": "equals", "value": true}
 ]}}
```

Operators: `equals`, `notEquals`, `greaterThan`, `greaterThanOrEqual`,
`lessThan`, `lessThanOrEqual`, `contains`, `startsWith`, `endsWith`,
`isEmpty`, `isNotEmpty`, `in` — composable with `and`, `or`, `not`.

## Dynamic / async options

```dart
DynamicFormController(
  optionsLoader: (fieldId, formData) async {
    final res = await api.get('/options/$fieldId?country=${formData['country']}');
    return [for (final o in res) OptionItem(label: o['name'], value: o['id'])];
  },
)
```

Fields opt in with `"optionsUrl": "..."` (or empty options on selection
types). Add `"dependsOn": ["country"]` to clear + reload when a parent field
changes — the classic country → state → city chain.

## Multi-step / wizard forms

Use `steps` instead of `fields`; each step validates before advancing:

```json
{"steps": [
  {"title": "Account", "fields": [ ... ]},
  {"title": "Profile", "fields": [ ... ]}
]}
```

Nested sections: `{"type": "expansion", "fields": [...]}` and
`{"type": "group", "fields": [...]}` — children keep flat ids, so the whole
controller API works on them.

## Field UI styles (JSON-driven)

Five built-in input looks, switchable from JSON at three levels — app theme
default, form root, and per field (most specific wins):

```json
{
  "style": {"variant": "rounded", "borderColor": "#3F51B5"},
  "fields": [
    {"type": "text", "id": "name", "label": "Name"},
    {"type": "email", "id": "email",
     "style": {"variant": "filled", "fillColor": "#EEF0FB",
               "textStyle": {"fontSize": 16, "fontWeight": "w600"}}}
  ]
}
```

Variants: `outlined`, `rounded` (pill), `filled`, `underline`, `none`.
Per-style knobs: `borderRadius`, `fillColor`, `borderColor`,
`focusedBorderColor`, `borderWidth`, `dense`, `contentPadding`,
`labelBehavior` (`auto`/`always`/`never`), `textStyle` / `labelStyle` /
`hintStyle` (`fontSize`, `color`, `fontWeight`, `italic`, `letterSpacing`).
Colors are `#RRGGBB` / `#AARRGGBB`. The field-level key can be `style` or
`decoration` — both are accepted. App-wide default:
`DynamicFormThemeData(defaultFieldStyle: ...)`. Because style lives in the
JSON, changing it at runtime restyles the form while preserving values.

## Edit mode (prefilled forms)

Open the same JSON form prefilled with an existing record — three ways:

```dart
// 1. From code — wins over everything:
DynamicForm(controller: c, json: formJson,
    initialData: {'name': 'Rupesh', 'country': 'IN'})

// 2. From the JSON itself — server ships definition + record together:
// {"fields": [...], "data": {"name": "Rupesh", "country": "IN"}}

// 3. Programmatically, after an async fetch:
controller.setFormData(record, asInitial: true);
```

Edit-mode semantics are handled correctly everywhere:

- The prefilled form starts **clean** — the discard guard only triggers
  after the user actually edits something.
- Typing a field back to its record value makes the form clean again
  (deep-compared baseline).
- `controller.reset()` restores the **record**, not the field defaults.
- Runtime JSON changes preserve both the values and the dirty baseline.
- Passing a new `initialData` map instance re-prefills at runtime
  (switching the edit target).

## Dirty tracking & discard guard

The controller tracks unsaved changes (deep-compared against the last clean
baseline): `controller.isDirty`, the listenable `controller.dirty`, and
`controller.markClean()` (called automatically on attach, `reset()` and a
successful `submit()`).

Enable the back-navigation guard from JSON — when the user edited something
and navigates back, a confirmation dialog asks before discarding:

```json
{
  "confirmDiscard": true,
  "discardTitle": "Discard changes?",
  "discardMessage": "You have unsaved changes.",
  "fields": [ ... ]
}
```

- `"confirmDiscard": false` (or omitted) disables it — fully dynamic.
- Code override wins: `DynamicForm(confirmDiscard: true/false, ...)`.
- Title/message fall back to the localized defaults (all 6 locales).
- Fully custom dialog:
  `DynamicFormThemeData(discardDialogBuilder: (context) async => ...)` —
  return `true` to leave, `false`/`null` to stay.

## Theming

```dart
DynamicFormTheme(
  data: DynamicFormThemeData(
    fieldSpacing: 20,
    decorationBuilder: (context, field, decoration) =>
        decoration.copyWith(border: const OutlineInputBorder()),
    errorBuilder: (context, message) => MyErrorBanner(message),
    loadingBuilder: (context) => const MySpinner(),
  ),
  child: DynamicForm(...),
)
```

Material 3 by default; the form inherits your app `ThemeData`
(light/dark/high-contrast follow automatically). Every renderer can be
replaced wholesale via `FieldFactory.register`.

## Localization

Built-in message locales: `en`, `hi`, `ar` (RTL), `es`, `fr`, `de`.

```dart
DynamicFormController(locale: 'ar');
FormLocalizations.addTranslations('ta', {'required': 'இது தேவை'});
```

## State management

The package is self-contained (plain `ChangeNotifier` + `ValueNotifier`), so
it plugs into anything:

```dart
// Provider
ChangeNotifierProvider(create: (_) => DynamicFormController());

// Riverpod
final formControllerProvider =
    Provider.autoDispose((ref) {
  final c = DynamicFormController();
  ref.onDispose(c.dispose);
  return c;
});

// Bloc — forward changes into your bloc
controller.onChanged = (id, value, data) =>
    context.read<FormBloc>().add(FormFieldChanged(id, value));

// GetX
class FormCtrl extends GetxController {
  final form = DynamicFormController();
  @override void onClose() { form.dispose(); super.onClose(); }
}
```

## Accessibility

Semantic labels from JSON `label`s, full keyboard navigation
(`textInputAction: next` + focus API), screen-reader friendly Material
widgets, and high-contrast support via your app theme.

## Example

See [`example/lib/main.dart`](example/lib/main.dart) for a complete
registration demo: conditional state dropdown fed by a simulated API,
age-gated license field, chips, sliders, rating, color picker and multi-rule
validation.

## License

MIT © Rupesh Rajak
