import 'package:flutter/material.dart';

void main() => runApp(FocusWalletApp());

class FocusWalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusWallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(child: Text('¡Hola FocusWallet!')),
      ),
    );
  }
}
