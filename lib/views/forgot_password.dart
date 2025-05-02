import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/lib_assets/input_decoration.dart';
import 'package:xplorion_ai/views/urlconfig.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  Future<void> resetPassword() async {
    final String endpoint = '$baseurl/app/app-users/forgot-password';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        body: {
          'email': emailController.text,
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String message =
            responseData['message'] ?? 'Something went wrong';
        final int errFlag = responseData['errFlag'] ?? 0;

        // Show a SnackBar with the message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errFlag == 0
                ? "We've sent you an email with instructions to reset your password. Follow the Instructions, and you'll be back on your journey in no time! 🗺️✨"
                : message),
            backgroundColor: errFlag == 0 ? Colors.green : Colors.red,
          ),
        );
      } else {
        // Handle non-200 status codes
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reset password. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        title: const Text(
          'Forgot Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Forgot your password?',
              style: TextStyle(
                color: Color(0xFF030917),
                fontSize: 18,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Please enter your email to reset your password',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
                fontFamily: 'IBM Plex Sans',
                fontWeight: FontWeight.w400,
                height: 0.12,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Email address',
              style: TextStyle(
                color: Color(0xFF191B1C),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20, top: 6),
              height: 54,
              decoration: inputContainerDecoration,
              child: TextField(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: themeFontFamily2,
                ),
                keyboardType: TextInputType.text,
                controller: emailController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20, right: 20),
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(
                    color: Color(0xFF959FA3),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {},
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(top: 20),
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
                  surfaceTintColor: Colors.transparent,
                ),
                onPressed: resetPassword,
                child: const Center(
                  child: Text(
                    'Reset password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: themeFontFamily,
                      fontWeight: FontWeight.w600,
                      height: 0.16,
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
