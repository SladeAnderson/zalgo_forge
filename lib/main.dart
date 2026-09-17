import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  static const titleText = "Zalgo Forge";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Text(titleText),
        ),
        

        drawer: Drawer(
          key: Key("sdf"),
          backgroundColor: Colors.blue,
          
        )
        
      ),
    );
  }
}