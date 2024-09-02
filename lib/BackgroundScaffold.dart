import 'dart:ui';

import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  //final Widget child;

  //const BackgroundScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E1C40),
                  Color(0xFF00D7FF)
                ], // Dégradé de couleurs
                begin: Alignment.center,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          BackdropFilter(
            // Application d'un effet de flou
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(
                  0), // Couleur transparente pour voir le fond flouté
            ),
          ),
        ],
      ),
    );
  }
}
