import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NewEntryPage extends StatelessWidget {
  const NewEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        titleTextStyle: const TextStyle(
          color: AppTheme.yellowForeground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: const Center(child: Text('New entry')),
    );
  }
}
