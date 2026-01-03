import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
import 'name_entry_screen.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final instructions = [
      'Flip cards to reveal symbols',
      'Match identical animals to score points',
      'Clear all pairs before time runs out',
      'Use fewer moves for higher scores',
      'Levels become harder as you progress',
    ];

    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              'How to Play',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...instructions.map(
              (line) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Expanded(
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const NameEntryScreen()),
                  );
                },
                child: const Text('Got it! Let\'s Start'),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Offline • Multiplayer • Many Habitats',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
