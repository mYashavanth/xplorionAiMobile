import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/widgets/gradient_text.dart';
import 'urlconfig.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SplashScreenTwo extends StatefulWidget {
  const SplashScreenTwo({super.key});

  @override
  State<SplashScreenTwo> createState() => _SplashScreenTwoState();
}

class _SplashScreenTwoState extends State<SplashScreenTwo> {
  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // _validateUserLogin();
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
            '$baseurl/app/app-users/valiadte-app-user-token/$token/$username';

        // Make the API call
        final response = await http.get(Uri.parse(url));
        print(response.body);

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          if (responseBody['errFlag'] == 0) {
            // Navigate to the home screen
            Navigator.pushReplacementNamed(context, '/home_page');
          } else {
            // Navigate to the login screen
            return;
          }
        } else {
          // Navigate to the login screen
          return;
        }
      }

      // If token is invalid or not found, proceed to the splash screen
    } catch (e) {
      // Handle errors (e.g., network issues, invalid JSON)
      print('Error validating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          transform: Matrix4.translationValues(0.0, -35.0, 0.0),
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: Column(
                            children: [
                              imageCard('sps/r11.jpeg', height * 0.125),
                              imageCard('sps/r12.jpeg', height * 0.168),
                              imageCard('sps/r13.jpeg', height * 0.176),
                              imageCard('sps/r14.jpeg', height * 0.155),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          transform: Matrix4.translationValues(0.0, -45.0, 0.0),
                          child: Column(
                            children: [
                              imageCard('sps/r21.jpeg', height * 0.120),
                              imageCard('sps/r22.jpeg', height * 0.175),
                              imageCard('sps/r23.jpeg', height * 0.145),
                              imageCard('sps/r24.jpeg', height * 0.155),
                              // imageCard('sps_image8.png', 134),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          transform: Matrix4.translationValues(0.0, -55.0, 0.0),
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          child: Column(
                            children: [
                              imageCard('sps/r31.jpeg', height * 0.115),
                              imageCard('sps/r32.jpeg', height * 0.179),
                              imageCard('sps/r33.jpeg', height * 0.188),
                              imageCard('sps/r22.jpeg', height * 0.135),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 180,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.0), // Fully transparent
                            Colors.white.withOpacity(0.6), // Light white
                            Colors.white.withOpacity(0.8), // Light white
                            Colors.white.withOpacity(0.9), // Light white
                            Colors.white, // Fully white
                            Colors.white, // Fully white
                          ],
                          stops: const [
                            0.0,
                            0.1,
                            0.2,
                            0.3,
                            0.5,
                            1.0,
                          ], // Adjusts the position of the color stops
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 147.14,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/icons/location_tripssist_logo.png"),
                              // fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const SizedBox(
                    height: 40,
                    child: Text(
                      'Welcome to XplorionAi',
                      style: TextStyle(
                        color: Color(0xFF005CE7),
                        fontSize: 24,
                        fontFamily: themeFontFamily,
                        fontWeight: FontWeight.w700,
                        // height: 0.07,
                      ),
                    ),
                    // GradientText(
                    //   'Welcome to ExplorionAI',
                    //   gradient: LinearGradient(
                    //     begin: Alignment(-1.00, 0.06),
                    //     end: Alignment(1, -0.06),
                    //     colors: [
                    //       Color(0xFF0099FF),
                    //       Color(0xFF54AB6A),
                    //     ],
                    //   ),
                    //   style: TextStyle(
                    //     color: Colors.green,
                    //     fontSize: 24,
                    //     fontFamily: 'Sora',
                    //     fontWeight: FontWeight.w700,
                    //     height: 1,
                    //   ),
                    // ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 48,
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                      gradient: themeGradientColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/sign_up');
                      },
                      child: const Center(
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600,
                            height: 0.16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 48,
                    width: double.maxFinite,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFF005CE7)),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          // backgroundColor: Colors.transparent,
                          shadowColor: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Center(
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            color: Color(0xFF005CE7),
                            fontSize: 16,
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600,
                            // height: 0.16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget imageCard(image, double height) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.maxFinite,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/$image"),
          fit: BoxFit.cover,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
