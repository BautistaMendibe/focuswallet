import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.navSummary),
        backgroundColor: const Color(0xFF009792),
      ),
      body: const Center(
        child: Text('Summary Screen - Coming Soon'),
      ),
    );
  }
} 