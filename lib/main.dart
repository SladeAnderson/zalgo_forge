import 'package:flutter/material.dart';

import 'components/zalgo_page/component.dart';

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
