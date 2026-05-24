// Example code.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gmana_form/gmana_form.dart';

void main() {
  runApp(const GmanaFormExampleApp());
}

class GmanaFormExampleApp extends StatelessWidget {
  const GmanaFormExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'gmana_form',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const ExampleFormPage(),
    );
  }
}

class ExampleFormPage extends StatefulWidget {
  const ExampleFormPage({super.key});

  @override
  State<ExampleFormPage> createState() => _ExampleFormPageState();
}

class _ExampleFormPageState extends State<ExampleFormPage> {
  final _form = GFormController();

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _submit(Map<String, String> values) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome, ${values['name']?.trim()}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('gmana_form')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: GForm(
              controller: _form,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Create account',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const GTextField(
                    config: GTextFieldConfig(
                      name: 'name',
                      label: 'Name',
                      hint: 'Enter your full name',
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GEmailField(
                    name: 'email',
                    label: 'Email',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  GNumberField(
                    name: 'age',
                    label: 'Age',
                    hint: 'Enter your age',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  GPasswordField(
                    name: 'password',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  GConfirmPasswordField(
                    name: 'confirmPassword',
                    passwordName: 'password',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: GFormSubmitButton.text(
                      onSubmit: _submit,
                      label: 'Submit',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}