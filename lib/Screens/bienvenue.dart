import 'package:flutter/material.dart';
import 'dart:async';

import 'authentication_screen.dart';

///  Created by abdoulaye.douyon on 02/09/2024.
class Bienvenue extends StatefulWidget {
  //Bienvenue({required Key key}) : super(key: key);

  @override
  _BienvenueState createState() => _BienvenueState();
}

class _BienvenueState extends State<Bienvenue> {
  @override
  void initState() {
    super.initState();
    // Naviguer vers la page principale après 3 secondes
    Timer( const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1C40),
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Column(
          children: <Widget>[
            Image.asset(
              "assets/images/logoDeme.png", // Chem in vers le logo
              height: 200,
            ),
            const SizedBox(height: 100),
            const Text(
              "Bienvenue",
              style: TextStyle(
                fontSize: 24,
                //fontWeight: FontWeight.bold,
                color: Color(0xffF79621),
              ),
            ),
            const SizedBox(height: 100),
            const Text(
              "N'hésitez pas à soumettre "
                  "vos tickets et à collaborer "
                  "avec vos formateurs "
                  "pour une résolution rapide "
                  "et efficace.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                //fontWeight: FontWeight.bold,
                color: Colors.white,

              ),
            ),
          ],
        ),
      ),
    );
  }
}