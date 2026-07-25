// Demo app for json_form_engine: a registration form exercising text,
// selection, conditional logic, sliders, validation and dynamic options.
import 'package:json_form_engine/json_form_engine.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

/// Root demo app.
class DemoApp extends StatelessWidget {
  /// Creates the demo app.
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'json_form_engine demo',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
          inputDecorationTheme:
              const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: const HomePage(),
      );
}

/// Landing page so the form is pushed as a route (demonstrates the
/// unsaved-changes discard guard on back navigation).
class HomePage extends StatelessWidget {
  /// Creates the home page.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('json_form_engine')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.assignment),
              label: const Text('New Registration'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const DemoFormPage()),
              ),
            ),
            const SizedBox(height: 12),
            // Edit mode: same JSON form prefilled with an existing record.
            OutlinedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Edit Existing Record'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const DemoFormPage(
                    initialData: {
                      'name': 'Rupesh Rajak',
                      'email': 'rupeshrajak438@gmail.com',
                      'age': 28,
                      'country': 'IN',
                      'interests': ['Flutter', 'Odoo'],
                      'experience': 6.0,
                      'newsletter': true,
                      'terms': true,
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _registrationJson = {
  'id': 'registration',
  'title': 'Registration',
  // Back with unsaved changes → confirmation dialog. Set false to disable.
  'confirmDiscard': true,
  'fields': [
    {'type': 'sectionHeader', 'id': 'sec_account', 'label': 'Account'},
    {
      'type': 'text',
      'id': 'name',
      'label': 'Full Name',
      'prefixIcon': 'person',
      'validators': [
        'required',
        {'type': 'minLength', 'value': 3},
      ],
    },
    {
      'type': 'email',
      'id': 'email',
      'label': 'Email',
      'prefixIcon': 'email',
      'validators': ['required', 'email'],
    },
    {
      'type': 'password',
      'id': 'password',
      'label': 'Password',
      'prefixIcon': 'lock',
      'validators': ['required', 'passwordStrength'],
    },
    {
      'type': 'password',
      'id': 'confirm',
      'label': 'Confirm Password',
      'prefixIcon': 'lock',
      'validators': [
        'required',
        {'type': 'matchField', 'value': 'password'},
      ],
    },
    {'type': 'sectionHeader', 'id': 'sec_profile', 'label': 'Profile'},
    {
      'type': 'number',
      'id': 'age',
      'label': 'Age',
      'validators': [
        {'type': 'min', 'value': 13, 'message': 'Must be 13 or older'},
      ],
    },
    {
      'type': 'dropdown',
      'id': 'country',
      'label': 'Country',
      'items': [
        {'label': 'India', 'value': 'IN'},
        {'label': 'USA', 'value': 'US'},
        {'label': 'Germany', 'value': 'DE'},
      ],
    },
    {
      'type': 'dropdown',
      'id': 'state',
      'label': 'State',
      'optionsUrl': 'demo://states',
      'dependsOn': ['country'],
      'visibleWhen': {
        'field': 'country',
        'operator': 'isNotEmpty',
      },
    },
    {
      'type': 'text',
      'id': 'license',
      'label': 'Driving License No.',
      'helperText': 'Enabled once age is 18+',
      'enabledWhen': {
        'field': 'age',
        'operator': 'greaterThanOrEqual',
        'value': 18,
      },
    },
    {'type': 'sectionHeader', 'id': 'sec_prefs', 'label': 'Preferences'},
    {
      'type': 'chips',
      'id': 'interests',
      'label': 'Interests',
      'multiple': true,
      'items': ['Flutter', 'Odoo', 'AI', 'Design'],
    },
    {
      'type': 'slider',
      'id': 'experience',
      'label': 'Years of experience',
      'min': 0,
      'max': 30,
      'divisions': 30,
    },
    {'type': 'rating', 'id': 'satisfaction', 'label': 'Rate this demo'},
    {'type': 'date', 'id': 'dob', 'label': 'Date of Birth'},
    {'type': 'colorPicker', 'id': 'favColor', 'label': 'Favorite Color'},
    {'type': 'sectionHeader', 'id': 'sec_media', 'label': 'Media'},
    {
      'type': 'image',
      'id': 'profilePhoto',
      'label': 'Profile Photo',
      'source': 'both', // bottom sheet: Gallery / Camera
      'imageQuality': 80,
    },
    {
      'type': 'image',
      'id': 'gallery',
      'label': 'Gallery Photos',
      'source': 'gallery',
      'multiple': true,
      'maxImages': 4,
    },
    {
      'type': 'file',
      'id': 'resume',
      'label': 'Resume (PDF)',
      'extensions': ['pdf'],
    },
    {
      'type': 'switch',
      'id': 'newsletter',
      'label': 'Subscribe to newsletter',
    },
    {
      'type': 'checkbox',
      'id': 'terms',
      'label': 'I accept the terms and conditions',
      'validators': ['required'],
    },
  ],
};

const _statesByCountry = {
  'IN': ['Maharashtra', 'Karnataka', 'Delhi'],
  'US': ['California', 'Texas', 'New York'],
  'DE': ['Bavaria', 'Berlin', 'Hesse'],
};

/// Page hosting the demo form.
class DemoFormPage extends StatefulWidget {
  /// Creates the page; pass [initialData] to open in edit mode.
  const DemoFormPage({super.key, this.initialData});

  /// Existing record to prefill (edit mode).
  final Map<String, dynamic>? initialData;

  @override
  State<DemoFormPage> createState() => _DemoFormPageState();
}

class _DemoFormPageState extends State<DemoFormPage> {
  late final DynamicFormController controller;
  String _variant = 'outlined';

  /// The same form JSON restyled at runtime — values survive the re-parse.
  Map<String, dynamic> get _json => {
        ..._registrationJson,
        'style': {
          'variant': _variant,
          if (_variant == 'filled') 'fillColor': '#EEF0FB',
          if (_variant == 'rounded') 'borderColor': '#3F51B5',
        },
      };

  @override
  void initState() {
    super.initState();
    controller = DynamicFormController(
      optionsLoader: (fieldId, formData) async {
        // Simulated remote API for the dependent state dropdown.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final states =
            _statesByCountry[formData['country']] ?? const <String>[];
        return [for (final s in states) OptionItem(label: s, value: s)];
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.initialData == null ? 'Registration' : 'Edit Registration'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Field style',
            initialValue: _variant,
            onSelected: (v) => setState(() => _variant = v),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'outlined', child: Text('Outlined')),
              PopupMenuItem(value: 'rounded', child: Text('Rounded')),
              PopupMenuItem(value: 'filled', child: Text('Filled')),
              PopupMenuItem(value: 'underline', child: Text('Underline')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DynamicForm(
          controller: controller,
          json: _json,
          initialData: widget.initialData,
          showSubmitButton: true,
          onSubmit: (data) => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Submitted'),
              content: SingleChildScrollView(child: Text('$data')),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Reset',
        onPressed: controller.reset,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
