import 'package:flutter/material.dart';

import '../controllers/dynamic_form_controller.dart';
import '../models/field_config.dart';
import '../models/field_type.dart';
import '../models/option_item.dart';
import '../theme/dynamic_form_theme.dart';
import 'decoration_helper.dart';

/// Rebuild-scoped helper: listens to value+error+enabled+options of a field.
class _FieldScope extends StatelessWidget {
  const _FieldScope({required this.state, required this.builder});

  final dynamic state; // FieldRuntimeState
  final Widget Function(
          BuildContext, Object?, String?, bool, List<OptionItem>, bool loading)
      builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Object?>(
      valueListenable: state.value as ValueNotifier<Object?>,
      builder: (context, value, _) => ValueListenableBuilder<String?>(
        valueListenable: state.error as ValueNotifier<String?>,
        builder: (context, error, _) => ValueListenableBuilder<bool>(
          valueListenable: state.enabled as ValueNotifier<bool>,
          builder: (context, enabled, _) =>
              ValueListenableBuilder<List<OptionItem>>(
            valueListenable: state.options as ValueNotifier<List<OptionItem>>,
            builder: (context, options, _) => ValueListenableBuilder<bool>(
              valueListenable: state.loadingOptions as ValueNotifier<bool>,
              builder: (context, loading, _) =>
                  builder(context, value, error, enabled, options, loading),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renderer for dropdown / multiselect / country / state / city fields.
class DynamicDropdownField extends StatelessWidget {
  /// Creates a dropdown field.
  const DynamicDropdownField(
      {super.key, required this.field, required this.controller});

  /// Field configuration.
  final FieldConfig field;

  /// Owning form controller.
  final DynamicFormController controller;

  bool get _multi => field.type == FieldType.multiselect;

  Future<void> _pickMulti(BuildContext context, List<OptionItem> options,
      List<Object?> selected) async {
    final result = await showDialog<List<Object?>>(
      context: context,
      builder: (context) {
        final current = [...selected];
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(field.label ?? controller.l10n.message('select')),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final o in options)
                    CheckboxListTile(
                      value: current.contains(o.value),
                      title: Text(o.label),
                      enabled: o.enabled,
                      onChanged: (checked) => setState(() {
                        checked ?? false
                            ? current.add(o.value)
                            : current.remove(o.value);
                      }),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, current),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
    if (result != null) controller.setValue(field.id, result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = DynamicFormTheme.of(context);
    return _FieldScope(
      state: controller.state(field.id),
      builder: (context, value, error, enabled, options, loading) {
        if (loading) {
          return theme.loadingBuilder?.call(context) ??
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              );
        }
        if (_multi) {
          final selected = List<Object?>.from(value as List? ?? const []);
          final labels = options
              .where((o) => selected.contains(o.value))
              .map((o) => o.label)
              .join(', ');
          return InkWell(
            onTap:
                enabled ? () => _pickMulti(context, options, selected) : null,
            child: InputDecorator(
              decoration: buildFieldDecoration(context, field, controller,
                  errorText: error, suffix: const Icon(Icons.arrow_drop_down)),
              isEmpty: selected.isEmpty,
              child: Text(labels),
            ),
          );
        }
        final validValue = options.any((o) => o.value == value) ? value : null;
        return DropdownButtonFormField<Object?>(
          key: ValueKey(options.length),
          initialValue: validValue,
          focusNode: controller.state(field.id).focusNode,
          decoration: buildFieldDecoration(context, field, controller,
              errorText: error),
          items: [
            for (final o in options)
              DropdownMenuItem(
                  value: o.value, enabled: o.enabled, child: Text(o.label)),
          ],
          onChanged: enabled ? (v) => controller.setValue(field.id, v) : null,
        );
      },
    );
  }
}

/// Renderer for checkbox, switch and single radio fields (bool-valued).
class DynamicBoolField extends StatelessWidget {
  /// Creates a boolean field.
  const DynamicBoolField(
      {super.key, required this.field, required this.controller});

  /// Field configuration.
  final FieldConfig field;

  /// Owning form controller.
  final DynamicFormController controller;

  @override
  Widget build(BuildContext context) {
    final theme = DynamicFormTheme.of(context);
    final state = controller.state(field.id);
    return _FieldScope(
      state: state,
      builder: (context, value, error, enabled, options, loading) {
        final checked = value == true;
        void toggle(bool? v) => controller.setValue(field.id, v ?? false);
        Widget tile;
        switch (field.type) {
          case FieldType.switchField:
            tile = SwitchListTile(
              value: checked,
              title: Text(field.label ?? ''),
              subtitle:
                  field.helperText != null ? Text(field.helperText!) : null,
              onChanged: enabled ? toggle : null,
              focusNode: state.focusNode,
              contentPadding: EdgeInsets.zero,
            );
          case FieldType.radio:
            tile = RadioListTile<bool>(
              value: true,
              // ignore: deprecated_member_use
              groupValue: checked ? true : null,
              title: Text(field.label ?? ''),
              // ignore: deprecated_member_use
              onChanged: enabled ? (_) => toggle(!checked) : null,
              contentPadding: EdgeInsets.zero,
            );
          default:
            tile = CheckboxListTile(
              value: checked,
              title: Text(field.label ?? ''),
              subtitle:
                  field.helperText != null ? Text(field.helperText!) : null,
              onChanged: enabled ? toggle : null,
              focusNode: state.focusNode,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            tile,
            if (error != null)
              theme.errorBuilder?.call(context, error) ??
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(error,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12)),
                  ),
          ],
        );
      },
    );
  }
}

/// Renderer for checkboxGroup, radioGroup, chips, toggleButtons, segmented.
class DynamicGroupField extends StatelessWidget {
  /// Creates a group selection field.
  const DynamicGroupField(
      {super.key, required this.field, required this.controller});

  /// Field configuration.
  final FieldConfig field;

  /// Owning form controller.
  final DynamicFormController controller;

  bool get _multi =>
      field.type == FieldType.checkboxGroup ||
      (field.type == FieldType.chips && (field.ex<bool>('multiple') ?? false));

  @override
  Widget build(BuildContext context) {
    final theme = DynamicFormTheme.of(context);
    return _FieldScope(
      state: controller.state(field.id),
      builder: (context, value, error, enabled, options, loading) {
        final selected = _multi
            ? List<Object?>.from(value as List? ?? const [])
            : <Object?>[if (value != null) value];

        void select(Object? v, bool nowSelected) {
          if (_multi) {
            final next = [...selected];
            nowSelected ? next.add(v) : next.remove(v);
            controller.setValue(field.id, next);
          } else {
            controller.setValue(field.id, nowSelected ? v : null);
          }
        }

        Widget body;
        switch (field.type) {
          case FieldType.checkboxGroup:
            body = Column(
              children: [
                for (final o in options)
                  CheckboxListTile(
                    value: selected.contains(o.value),
                    title: Text(o.label),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: enabled && o.enabled
                        ? (v) => select(o.value, v ?? false)
                        : null,
                  ),
              ],
            );
          case FieldType.radioGroup:
            body = Column(
              children: [
                for (final o in options)
                  RadioListTile<Object?>(
                    value: o.value,
                    // ignore: deprecated_member_use
                    groupValue: value,
                    title: Text(o.label),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    // ignore: deprecated_member_use
                    onChanged: enabled && o.enabled
                        ? (v) => controller.setValue(field.id, v)
                        : null,
                  ),
              ],
            );
          case FieldType.toggleButtons:
            body = ToggleButtons(
              isSelected: [for (final o in options) selected.contains(o.value)],
              onPressed: enabled
                  ? (i) => select(
                      options[i].value, !selected.contains(options[i].value))
                  : null,
              children: [
                for (final o in options)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(o.label)),
              ],
            );
          case FieldType.segmented:
            body = SegmentedButton<Object?>(
              segments: [
                for (final o in options)
                  ButtonSegment(
                      value: o.value, label: Text(o.label), enabled: o.enabled),
              ],
              selected: selected.toSet(),
              multiSelectionEnabled: _multi,
              emptySelectionAllowed: true,
              onSelectionChanged: enabled
                  ? (set) => controller.setValue(
                      field.id, _multi ? set.toList() : set.firstOrNull)
                  : null,
            );
          default: // chips
            body = Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final o in options)
                  FilterChip(
                    label: Text(o.label),
                    selected: selected.contains(o.value),
                    onSelected:
                        enabled && o.enabled ? (v) => select(o.value, v) : null,
                  ),
              ],
            );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (field.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(field.label!,
                    style: theme.labelStyle ??
                        Theme.of(context).textTheme.titleSmall),
              ),
            body,
            if (error != null)
              theme.errorBuilder?.call(context, error) ??
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(error,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12)),
                  ),
          ],
        );
      },
    );
  }
}

/// Renderer for autocomplete / typeahead fields.
class DynamicAutocompleteField extends StatelessWidget {
  /// Creates an autocomplete field.
  const DynamicAutocompleteField(
      {super.key, required this.field, required this.controller});

  /// Field configuration.
  final FieldConfig field;

  /// Owning form controller.
  final DynamicFormController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state(field.id);
    return _FieldScope(
      state: state,
      builder: (context, value, error, enabled, options, loading) =>
          Autocomplete<OptionItem>(
        displayStringForOption: (o) => o.label,
        initialValue: TextEditingValue(text: value?.toString() ?? ''),
        optionsBuilder: (text) {
          if (text.text.isEmpty) return const Iterable<OptionItem>.empty();
          final q = text.text.toLowerCase();
          return options.where((o) => o.label.toLowerCase().contains(q));
        },
        onSelected: (o) => controller.setValue(field.id, o.value),
        fieldViewBuilder: (context, textController, focusNode, onSubmit) =>
            TextField(
          controller: textController,
          focusNode: focusNode,
          enabled: enabled,
          decoration: buildFieldDecoration(context, field, controller,
              errorText: error, suffix: const Icon(Icons.arrow_drop_down)),
          onChanged: (v) {
            // Free text is kept until an option is chosen.
            controller.setValue(field.id, v.isEmpty ? null : v);
          },
          onSubmitted: (_) => onSubmit(),
        ),
      ),
    );
  }
}
