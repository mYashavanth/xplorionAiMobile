import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // No background color
        centerTitle: true,
        title: const Text(
          'About Us',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black, // Black text for contrast
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent AppBar
        iconTheme: const IconThemeData(color: Colors.black), // Black icons
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 20),
            // const Text(
            //   'About Us',
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Color(0xFF0099FF), // Primary color
            //     fontFamily: 'Roboto',
            //   ),
            // ),
            const SizedBox(height: 20),
            const Text(
              'At Xplorion AI, we believe that the best trips aren’t always the ones you spend months planning—they’re the ones you stumble upon, guided by curiosity, spontaneity, and just the right recommendation at the right moment.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'We built Xplorion to be your personal travel buddy, powered by AI and your location, helping you explore the world around you like a local—even if you’re just a few blocks from home. Whether you’re on a weekend escape, a cross-country adventure, or simply looking for something fun nearby, Xplorion curates tailored suggestions that match your mood, interests, and vibe.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No more endless scrolling, no more generic lists.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF54AB6A), // Secondary color
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Just real-time, intelligent, and exciting travel ideas—in your pocket.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'We’re here to help you explore smarter, wander freer, and create stories worth sharing.',
              style: TextStyle(
                height: 1.5,
                color: Color(0xFF333333),
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Because the world is full of amazing places—Xplorion just helps you find them.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0099FF), // Primary color
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 100),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
