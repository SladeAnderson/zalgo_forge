import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utilities/zalgo.dart';

void main() => runApp(const ZalgoForgeApp());

class ZalgoForgeApp extends StatelessWidget {
  const ZalgoForgeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zalgo Forge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B2CBF),
          brightness: Brightness.dark,
        ),
      ),
      home: const ZalgoPage(),
    );
  }
}

class ZalgoPage extends StatefulWidget {
  const ZalgoPage({super.key});
  @override
  State<ZalgoPage> createState() => _ZalgoPageState();
}

class _ZalgoPageState extends State<ZalgoPage> {
  final TextEditingController _input = TextEditingController(
    text: 'from beyond the veil',
  );
  ZalgoOptions _options = ZalgoOptions.fromPreset(ZalgoPreset.uneasy);
  @override
  void initState() {
    super.initState();
    _input.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _input.removeListener(_onInputChanged);
    _input.dispose();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});
  String get _output => zalgoify(_input.text, _options);
  void _setOptions(ZalgoOptions next) => setState(() => _options = next);
  void _reroll() =>
      _setOptions(_options.copyWith(seed: Random().nextInt(1 << 30)));
  void _clean() => _input.text = stripZalgo(_input.text);
  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _output));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Copied'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget controls = _ControlsPanel(
      controller: _input,
      options: _options,
      onChanged: _setOptions,
      onClean: _clean,
    );
    final Widget preview = _PreviewPanel(
      text: _output,
      options: _options,
      onCopy: _copy,
      onReroll: _reroll,
    );
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(
          LogicalKeyboardKey.keyC,
          control: true,
          shift: true,
        ): _copy,
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): _reroll,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Zalgo Forge'),
            actions: <Widget>[
              IconButton(
                onPressed: _reroll,
                icon: const Icon(Icons.casino_outlined),
                tooltip: 'Reroll (Ctrl+R)',
              ),
              IconButton(
                onPressed: _copy,
                icon: const Icon(Icons.copy_all_outlined),
                tooltip: 'Copy (Ctrl+Shift+C)',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth >= 760) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(width: 400, child: controls),
                    const VerticalDivider(width: 1),
                    Expanded(child: preview),
                  ],
                );
              }
              return Column(
                children: <Widget>[
                  Flexible(flex: 5, child: controls),
                  const Divider(height: 1),
                  Flexible(flex: 4, child: preview),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
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
          _BigSlider(
            label: 'Chaos',
            valueLabel: '${(options.chaos * 100).round()}%',
            value: options.chaos,
            min: 0,
            max: 1,
            divisions: 100,
            onChanged: (double v) => onChanged(options.copyWith(chaos: v)),
          ),
          _BigSlider(
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
          _BigSlider(
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
              _Readout(icon: Icons.north, value: options.aboveCount),
              const SizedBox(width: 8),
              _Readout(icon: Icons.remove, value: options.strikeCount),
              const SizedBox(width: 8),
              _Readout(icon: Icons.south, value: options.belowCount),
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

class _BigSlider extends StatelessWidget {
  const _BigSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.leading,
    this.trailing,
  });
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Widget? leading;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(label, style: theme.textTheme.labelLarge),
            const Spacer(),
            Text(
              valueLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            if (leading != null) leading!,
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ],
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.icon, required this.value});
  final IconData icon;
  final int value;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text('0–$value', style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.text,
    required this.options,
    required this.onCopy,
    required this.onReroll,
  });
  final String text;
  final ZalgoOptions options;
  final VoidCallback onCopy;
  final VoidCallback onReroll;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                text,
                style: TextStyle(fontSize: 26, height: options.lineHeight),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: <Widget>[
                Text(
                  '${text.length} chars',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (text.length > 2000) ...<Widget>[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'may be rejected by chat apps',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: onReroll,
                  icon: const Icon(Icons.casino_outlined, size: 18),
                  label: const Text('Reroll'),
                ),
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_all_outlined, size: 18),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
