import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zalgo_forge/models/ZalgoPreset.model.dart';

import '../../utilities/zalgo.dart';
import '../controls_panel/component.dart';
import '../imu_eye/component.dart';
import '../preview_panel/component.dart';

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

  List<ZalgoPreset> _presets = <ZalgoPreset>[...ZalgoPreset.builtIns];

  String? _selectedPresetID = ZalgoPreset.uneasy.id;

 

  void _setOptions(ZalgoOptions next) => setState(() {
    if (next.chaos != _options.chaos || 
      next.balance != _options.balance ||
      next.strike != _options.strike) {
      _selectedPresetID = null;
    }
    _options = next;
  });

  void _selectPreset(ZalgoPreset preset) => setState(() {
    _selectedPresetID = preset.id;
    _options = _options.copyWith(
      chaos: preset.chaos,
      balance: preset.balance,
      strike: preset.strike,
    );
  });

  void _addPreset(String name) {
    final ZalgoPreset preset = ZalgoPreset(
      DateTime.now().microsecondsSinceEpoch.toString(), 
      name, _options.chaos, _options.balance, _options.strike
    );

    setState(() {
      _presets = <ZalgoPreset>[..._presets, preset ];
      _selectedPresetID = preset.id;
    });

    _savePresets();
  }

  void _deletePreset(ZalgoPreset preset) {
    setState(() {
      _presets = _presets.where((ZalgoPreset p) => p.id != preset.id).toList();
      if (_selectedPresetID == preset.id) _selectedPresetID = null;
    });

    _savePresets();
  }

  Future<void> _savePresets() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> custom = _presets
      .where((ZalgoPreset p) => !ZalgoPreset.builtIns.contains(p))
      .map((ZalgoPreset p) => jsonEncode(p.toJson()))
      .toList();

    await prefs.setStringList('presets', custom);
  }

  Future<void> _loadPresets() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> saved = prefs.getStringList('presets') ?? <String>[];

    setState(() {
      _presets = <ZalgoPreset>[
        ...ZalgoPreset.builtIns,
        ...saved.map((String s) => ZalgoPreset.fromJson(jsonDecode(s))),
      ];
    });
  }

  void _reroll() =>
    _setOptions(_options.copyWith(seed: Random().nextInt(1 << 30)));

  void _clean() => _input.text = stripZalgo(_input.text);

  @override
  void initState() {
    super.initState();
    _input.addListener(_onInputChanged);
    _loadPresets();
  }

  @override
  void dispose() {
    _input.removeListener(_onInputChanged);
    _input.dispose();
    super.dispose();
  }

  void _onInputChanged() => setState(() {});

  String get _output => zalgoify(_input.text, _options);

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
    final Widget controls = ControlsPanel(
      controller: _input,
      options: _options,
      onChanged: _setOptions,
      onClean: _clean,
      presets: _presets,
      onSavePreset: _addPreset,
      selectedPresetId: _selectedPresetID,
      onPresetSelected: _selectPreset,
      onPresetDeleted: _deletePreset,
    );

    final Widget preview = PreviewPanel(
      text: _output,
      options: _options,
      onCopy: _copy,
      onReroll: _reroll,
      showImu: summonsImu(_input.text),
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
