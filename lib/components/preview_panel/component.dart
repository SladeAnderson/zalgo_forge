import 'package:flutter/material.dart';

import '../../utilities/zalgo.dart';
import '../imu_eye/component.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({
    super.key,
    required this.text,
    required this.options,
    required this.onCopy,
    required this.onReroll,
    required this.showImu,
  }); // <-- is as constructor

  final String text;            // <--
  final ZalgoOptions options;   // <-- these are props
  final VoidCallback onCopy;    // <--
  final VoidCallback onReroll;  // <--
  final bool showImu;           // <--

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,

        children: <Widget>[
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned.fill(
                  // Lets taps through so the text stays selectable.
                  child: IgnorePointer(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: showImu ? const ImuEye() : const SizedBox.shrink(),
                    ),
                  ),
                ),

                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    text,
                    style: TextStyle(
                      fontSize: 26,
                      height: options.lineHeight,
                      // Keeps the text readable over the eye.
                      shadows: showImu
                          ? const <Shadow>[
                              Shadow(blurRadius: 6, color: Color(0xFF000000)),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
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
