import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/lib_assets/input_decoration.dart';

class VerifyOtp extends StatefulWidget {
  const VerifyOtp({super.key});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
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
              'Check your email',
              style: TextStyle(
                color: Color(0xFF030917),
                fontSize: 18,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'We sent a reset link to xplorionai@gmail.com, enter the 5 digit code that mentioned in the email',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            OtpTextField(
              textStyle: const TextStyle(
                color: Color(0xFF030917),
                fontSize: 24,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w500,
              ),
              fieldWidth: MediaQuery.of(context).size.width * 0.165,
              // fieldHeight: MediaQuery.of(context).size.width * 0.165,
              numberOfFields: 5,
              showFieldAsBox: true,
              borderRadius: BorderRadius.circular(10),
              borderWidth: 1,
              borderColor: const Color(0xFFE1E1E1),
              // hasCustomInputDecoration: true,
              // decoration: const InputDecoration(
              //   contentPadding: EdgeInsets.only(left: 8, right: 8),
              // ),
              contentPadding: const EdgeInsets.all(15),
              onSubmit: (value) {},
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 20),
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
                  Navigator.of(context).pushNamed('/set_password');
                },
                child: const Center(
                  child: Text(
                    'Verify code',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Haven’t got the email yet?',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                    // height: 0,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () {
                    //  Navigator.of(context).pushNamed('/login');
                    resendEmail();
                  },
                  child: const Text(
                    'Resend email',
                    style: TextStyle(
                      color: Color(0xFF2C64E3),
                      fontSize: 16,
                      fontFamily: themeFontFamily,
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  resendEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // backgroundColor: Color(0xFFECF2FF),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        content: const Center(
          child: Text(
            'Email sent succesfully',
            style: TextStyle(
              fontFamily: themeFontFamily2,
            ),
          ),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
