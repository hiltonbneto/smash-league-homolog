import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smash_league/screens/Super8Screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(int.parse("0xFF009da7")),
      appBar: AppBar(
        title: Text(
          "Smash League",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(int.parse("0xFF009da7")),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.person),
        //     color: Colors.white,
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            _buildButton("LIGAS", Colors.orange, context, () {}),
            const SizedBox(height: 15),
            _buildButton("SUPER 8", Colors.blue, context, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Super8Screen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, Color color, BuildContext context, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.montserrat(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}