import 'package:flutter/material.dart';

import '../../domain/entities/card_entity.dart';

class CardTile extends StatelessWidget {
  final CardEntity card;
  final double size;
  final VoidCallback onTap;

  const CardTile({
    super.key,
    required this.card,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const jungleGradients = [
      Color(0xFF93E1A0),
      Color(0xFF3AA871),
      Color(0xFF1E5F4C),
    ];
    const woodGradients = [
      Color(0xFFF4E3C1),
      Color(0xFFE3C9A8),
    ];

    if (card.isPlaceholder) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0xFFE6F4D7).withValues(alpha: 0.8),
          border: Border.all(
            color: cs.onSurface.withValues(alpha: 0.1),
            width: 1.2,
          ),
        ),
      );
    }

    final isFaceUp = card.isRevealed || card.isMatched;

    return GestureDetector(
      onTap: card.isMatched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isFaceUp ? jungleGradients : woodGradients,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: isFaceUp ? 14 : 6,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isFaceUp ? Colors.white.withValues(alpha: 0.35) : Colors.black26,
            width: 1.4,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 280),
                opacity: isFaceUp ? 0.25 : 0.08,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: isFaceUp ? 0.35 : 0.15),
                        Colors.transparent,
                      ],
                      radius: 1.1,
                      center: Alignment.topLeft,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Icon(
                Icons.pets_rounded,
                size: 20,
                color: Colors.white.withValues(alpha: isFaceUp ? 0.6 : 0.15),
              ),
            ),
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 230),
                scale: isFaceUp ? 1 : 0.2,
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isFaceUp ? 1 : 0,
                  child: Text(
                    card.symbol,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
