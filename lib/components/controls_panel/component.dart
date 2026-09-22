import 'package:flutter/material.dart';

import '../../utilities/zalgo.dart';
import '../big_slider/component.dart';
import '../readout/component.dart';

class ControlsPanel extends StatelessWidget {
  const ControlsPanel({
    super.key,
    required this.controller,
    required this.options,
    required this.onChanged,
    required this.onClean,
  });

  final TextEditingController controller;
  final ZalgoOptions options;
  final ValueChanged<ZalgoOptions> onChanged;
  final VoidCallback onClean;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: 'Source text',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: 'Strip existing marks',
                icon: const Icon(Icons.cleaning_services_outlined),
                onPressed: onClean,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Presets', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ZalgoPreset.values.map((ZalgoPreset preset) {
              return ChoiceChip(
                label: Text(preset.label),
                selected: options.matchingPreset == preset,
                onSelected: (_) => onChanged(
                  options.copyWith(
                    chaos: preset.chaos,
                    balance: preset.balance,
                    strike: preset.strike,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          BigSlider(
            label: 'Chaos',
            valueLabel: '${(options.chaos * 100).round()}%',
            value: options.chaos,
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: (double v) => onChanged(options.copyWith(chaos: v)),
          ),
          BigSlider(
            label: 'Balance',
            valueLabel: _balanceLabel(options.balance),
            value: options.balance,
            min: -1,
            max: 1,
            divisions: 20,
            leading: const Icon(Icons.south, size: 16),
            trailing: const Icon(Icons.north, size: 16),
            onChanged: (double v) => onChanged(options.copyWith(balance: v)),
          ),
          BigSlider(
            label: 'Strike-through',
            valueLabel: '${(options.strike * 100).round()}%',
            value: options.strike,
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: (double v) => onChanged(options.copyWith(strike: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Corrupt spaces too'),
            subtitle: const Text('Marks land on whitespace as well'),
            value: options.corruptSpaces,
            onChanged: (bool v) =>
                onChanged(options.copyWith(corruptSpaces: v)),
          ),
          const SizedBox(height: 8),
          Text('Marks per character', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Readout(icon: Icons.north, value: options.aboveCount),
              const SizedBox(width: 8),
              Readout(icon: Icons.remove, value: options.strikeCount),
              const SizedBox(width: 8),
              Readout(icon: Icons.south, value: options.belowCount),
            ],
          ),
        ],
      ),
    );
  }

  static String _balanceLabel(double balance) {
    if (balance.abs() < 0.05) return 'even';
    final int pct = (balance.abs() * 100).round();
    return balance > 0 ? 'above $pct%' : 'below $pct%';
  }
}
