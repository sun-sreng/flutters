// ignore_for_file: public_member_api_docs

import 'package:gmana_flutter/gmana_flutter.dart';
import 'package:material_ui/material_ui.dart';

class SpinnerGalleryPage extends StatefulWidget {
  const SpinnerGalleryPage({super.key});

  @override
  State<SpinnerGalleryPage> createState() => _SpinnerGalleryPageState();
}

class _SpinnerGalleryPageState extends State<SpinnerGalleryPage> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading spinners'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _simulateSave,
            child: const Text('Demo overlay'),
          ),
        ],
      ),
      body: GSpinnerOverlay(
        isLoading: _saving,
        semanticsLabel: 'Saving',
        message: Text(
          'Saving your changes',
          style: TextStyle(color: colorScheme.onInverseSurface),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: MediaQuery.sizeOf(context).width >= 720 ? 3 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            // GCircularSpinner and GLinearSpinner default to the package's
            // legacy purple; the theme above is what pulls them into line
            // with the rest.
            const _SpinnerTile(label: 'Circular', child: GCircularSpinner()),
            const _SpinnerTile(
              label: 'Linear',
              child: GLinearSpinner(minHeight: 6),
            ),
            const _SpinnerTile(label: 'Dots', child: GDotSpinner(size: 42)),
            const _SpinnerTile(
              label: 'Wave Dots',
              child: GWaveDotSpinner(size: 64),
            ),
            const _SpinnerTile(
              label: 'Bars',
              child: GBarWaveSpinner(type: GBarWaveSpinnerType.center),
            ),
            const _SpinnerTile(label: 'Pulse', child: GPulseSpinner()),
            const _SpinnerTile(label: 'Ring', child: GRingSpinner()),
            const _SpinnerTile(label: 'Dual Ring', child: GDualRingSpinner()),
            const _SpinnerTile(
              label: 'Chasing Dots',
              child: GChasingDotsSpinner(),
            ),
            const _SpinnerTile(
              label: 'Fading Cubes',
              child: GFadingCubeSpinner(),
            ),
            const _SpinnerTile(label: 'Ripple', child: GRippleSpinner()),
            const _SpinnerTile(label: 'Orbit', child: GOrbitSpinner()),
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
      ),
    );
  }

  Future<void> _simulateSave() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _saving = false);
  }
}

class _SpinnerTile extends StatelessWidget {
  final String label;

  final Widget child;
  const _SpinnerTile({required this.label, required this.child});

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
