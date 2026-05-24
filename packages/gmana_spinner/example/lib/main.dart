// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:gmana_spinner/gmana_spinner.dart';

void main() {
  runApp(const SpinnerExampleApp());
}

class SpinnerExampleApp extends StatelessWidget {
  const SpinnerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'gmana_spinner',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB))),
      home: const SpinnerGalleryPage(),
    );
  }
}

class SpinnerGalleryPage extends StatelessWidget {
  const SpinnerGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('gmana_spinner')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: MediaQuery.sizeOf(context).width >= 720 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _SpinnerTile(label: 'Circular', child: GCircularSpinner(color: colorScheme.primary)),
          _SpinnerTile(label: 'Linear', child: GLinearSpinner(color: colorScheme.primary, minHeight: 6)),
          _SpinnerTile(label: 'Dots', child: GDotSpinner(color: colorScheme.primary, size: 42)),
          _SpinnerTile(label: 'Wave Dots', child: GWaveDotSpinner(size: 64, color: colorScheme.primary)),
          _SpinnerTile(
            label: 'Bars',
            child: GBarWaveSpinner(color: colorScheme.primary, type: GBarWaveSpinnerType.center),
          ),
          _SpinnerTile(
            label: 'Wave',
            child: GWaveSpinner(
              color: colorScheme.primary,
              trackColor: colorScheme.outlineVariant,
              waveColor: colorScheme.primaryContainer,
              child: Icon(Icons.hourglass_bottom, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinnerTile extends StatelessWidget {
  const _SpinnerTile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 80, child: Center(child: child)),
            const SizedBox(height: 12),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
