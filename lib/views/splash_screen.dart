import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'urlconfig.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _validateUserLogin(); // Call the validation function on splash screen load
  }

  Future<void> _validateUserLogin() async {
    try {
      // Retrieve token and username from secure storage
      String? token = await storage.read(key: 'userToken');
      String? username = await storage.read(key: 'username');
      print('token: $token, username: $username');

      if (token != null && username != null) {
        // Construct the API URL
        String url =
            '$baseurl/app/app-users/valiadte-app-user-token/$token/${username}';
        print('API URL: $url, ${Uri.parse(url)}');

        // Make the API call
        final response = await http.get(Uri.parse(url));
        print(response.body);

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          if (responseBody['errFlag'] == 0) {
            // Navigate to the home screen
            Navigator.pushReplacementNamed(context, '/home_page');
            return;
          }
        }
      }

      // If token is invalid or not found, navigate to SplashScreenTwo
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/splash_screen_two');
      });
    } catch (e) {
      // Handle errors (e.g., network issues, invalid JSON)
      print('Error validating user: $e');
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/splash_screen_two');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.00, 0.06),
            end: Alignment(1, -0.06),
            colors: [
              Color(0xFF0099FF),
              Color(0xFF54AB6A),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo in the center
            const Spacer(),

            Center(
              child: Image.asset(
                'assets/icons/logo_white.png',
                width: 100, // Adjust the size as needed
                height: 100,
              ),
            ),
            const Spacer(),
            // Welcome text and XplorionAI text with star
            Column(
              children: [
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontFamily: 'IBM Plex Sans',
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none, // Ensure the star is not clipped
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      'XplorionAi',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'IBM Plex Sans',
                      ),
                    ),
                    Positioned(
                      top: -20,
                      right: -40,
                      child: Image.asset(
                        'assets/icons/stars.png',
                        width: 60, // Adjust the size as needed
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50), // Add spacing at the bottom
          ],
        ),
      ),
    );
  }
}
