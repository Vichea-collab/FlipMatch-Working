import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool useSafeArea;

  const AppBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF7EC8F3),
                    Color(0xFF74D3C7),
                    Color(0xFFA3E4B0),
                  ],
                ),
              ),
            ),
          ),
          const _AnimalSilhouette(
            icon: Icons.face_retouching_natural_rounded,
            size: 200,
            top: 40,
            left: -10,
          ),
          const _AnimalSilhouette(
            icon: Icons.emoji_nature_rounded,
            size: 160,
            top: 110,
            right: 20,
          ),
          const _AnimalSilhouette(
            icon: Icons.pets_rounded,
            size: 140,
            bottom: 160,
            left: 30,
          ),
          const _AnimalSilhouette(
            icon: Icons.catching_pokemon_rounded,
            size: 200,
            bottom: 30,
            right: -30,
          ),
          if (useSafeArea)
            content
          else
            Align(alignment: Alignment.center, child: content),
        ],
      ),
    );
  }
}

class _AnimalSilhouette extends StatelessWidget {
  final IconData icon;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _AnimalSilhouette({
    required this.icon,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(
        icon,
        size: size,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}
