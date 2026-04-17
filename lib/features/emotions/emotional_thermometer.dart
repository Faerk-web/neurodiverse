import 'package:flutter/material.dart';

enum EnergyLevel { green, yellow, red }

class EmotionalThermometer extends StatefulWidget {
  const EmotionalThermometer({super.key, this.onEnergyChanged});

  final ValueChanged<EnergyLevel>? onEnergyChanged;

  @override
  State<EmotionalThermometer> createState() => _EmotionalThermometerState();
}

class _EmotionalThermometerState extends State<EmotionalThermometer> {
  double _energy = 70;
  bool _toolboxShownInCurrentRedZone = false;

  EnergyLevel get _level {
    if (_energy <= 30) return EnergyLevel.red;
    if (_energy <= 60) return EnergyLevel.yellow;
    return EnergyLevel.green;
  }

  @override
  Widget build(BuildContext context) {
    final level = _level;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Battery Check', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _energy / 100,
              minHeight: 16,
              borderRadius: BorderRadius.circular(12),
              color: switch (level) {
                EnergyLevel.green => Colors.green,
                EnergyLevel.yellow => Colors.orange,
                EnergyLevel.red => Colors.red,
              },
              backgroundColor: Colors.black12,
            ),
            const SizedBox(height: 8),
            Text('Energy: ${_energy.round()}% • ${level.name.toUpperCase()}'),
            Slider(
              value: _energy,
              min: 0,
              max: 100,
              divisions: 20,
              label: _energy.round().toString(),
              onChanged: (value) {
                setState(() => _energy = value);
                final newLevel = _level;
                widget.onEnergyChanged?.call(newLevel);

                if (newLevel == EnergyLevel.red && !_toolboxShownInCurrentRedZone) {
                  _toolboxShownInCurrentRedZone = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _showSensoryToolbox(context);
                    }
                  });
                }

                if (newLevel != EnergyLevel.red) {
                  _toolboxShownInCurrentRedZone = false;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSensoryToolbox(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sensory Toolbox'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your battery is low. Let\'s recharge safely:'),
            SizedBox(height: 8),
            Text('• 4 deep breaths with visual breathing card'),
            Text('• Put on noise-canceling headphones'),
            Text('• 2-minute pressure/stretch break'),
            Text('• Ask teacher for a calm corner pass'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('I can do this'),
          ),
        ],
      ),
    );
  }
}
