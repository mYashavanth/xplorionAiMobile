import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/lib_assets/input_decoration.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const SizedBox(height: 15,),
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
            const SizedBox(
              height: 30,
            ),
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
              margin: const EdgeInsets.only(bottom: 20,top: 6),
              // padding: const EdgeInsets.only(left: 10),
              height: 54,
              decoration: inputContainerDecoration,
              child: TextField(
                enableInteractiveSelection: false,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: themeFontFamily2),
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
                    surfaceTintColor: Colors.transparent),
                onPressed: () {
                  Navigator.of(context).pushNamed('/verify_otp');
                },
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
