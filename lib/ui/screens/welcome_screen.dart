import 'package:flutter/material.dart';

import '../widgets/app_background.dart';
import 'how_to_play_screen.dart';
import 'name_entry_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
        child: Column(
          children: [
            const Spacer(),
            Text(
              'Welcome to',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white70),
            ),
            Text(
              'FlipMatch',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
            ),
            Text(
              'Memory Game',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 4,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 130,
                    width: 130,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE4F4FF),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🦉', style: TextStyle(fontSize: 72)),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Train your memory and beat challenging levels',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[800],
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _WelcomeButton(
              label: 'Let\'s Play',
              background: const Color(0xFFFF8A5C),
              foreground: Colors.white,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NameEntryScreen()),
                );
              },
            ),
            const SizedBox(height: 14),
            _WelcomeButton(
              label: 'How to Play',
              background: const Color(0xFF61A8FF),
              foreground: Colors.white,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                );
              },
            ),
            const Spacer(),
            const Text(
              'Offline • Multiplayer • Many Habitats',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _WelcomeButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shadowColor: background.withValues(alpha: 0.5),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
