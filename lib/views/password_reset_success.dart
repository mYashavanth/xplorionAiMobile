import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';

class PasswordResetSuccess extends StatefulWidget {
  const PasswordResetSuccess({super.key});

  @override
  State<PasswordResetSuccess> createState() => _PasswordResetSuccessState();
}

class _PasswordResetSuccessState extends State<PasswordResetSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/Successmark.svg'),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Password reset \nsuccessfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 24,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Congratulations! Your password has\nbeen changed. Click continue to login',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        // padding: const EdgeInsets.all(10),
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
            Navigator.of(context).pushNamed('/login');
          },
          child: const Center(
            child: Text(
              'Continue',
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
    );
  }
}
