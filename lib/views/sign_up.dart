import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/lib_assets/input_decoration.dart';
import 'urlconfig.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final storage = const FlutterSecureStorage();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool obscureTextPassword = true;
  bool obscureTextConfirmPassword = true;
  bool visibleBoolPassword = false;
  bool visibleBoolConfirmPassword = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool eligibleForSignup = false;
  bool safetyAgreementChecked = false; // New variable for the checkbox

  Future<void> _signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final String? email = user.email;
        final String? username = user.displayName; // Get the username
        final String? googleToken = googleAuth.idToken; // Get the Google token

        if (email != null && googleToken != null && username != null) {
          print("User email: $email");
          print("Google Token: $googleToken");
          print("Username: $username");

          // Send the data to the backend
          await _sendLoginDataToBackend(email, googleToken, username);
        } else {
          print("Failed to retrieve required user details");
        }
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: $e'),
          showCloseIcon: true,
        ),
      );
    }
  }

  Future<void> _sendLoginDataToBackend(
      String email, String googleToken, String username) async {
    try {
      final map = <String, dynamic>{
        'email': email,
        'googleToken': googleToken,
        'username': username,
      };

      final response = await http.post(
        Uri.parse('$baseurl/app/app-users/login-with-google'),
        body: map,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Backend response: $responseData");

        if (responseData['errFlag'] == 0) {
          await storage.write(key: 'userToken', value: responseData['token']);
          await storage.write(key: 'username', value: responseData['username']);
          await storage.write(key: 'email', value: email);

          if (responseData['showInterestsPage'] == 0) {
            Navigator.pushReplacementNamed(context, '/home_page');
          } else {
            Navigator.of(context).pushNamed('/choose_your_interests');
          }
        } else {
          final errorMessage = responseData['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              showCloseIcon: true,
            ),
          );
        }
      } else {
        print("Backend error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend error: ${response.statusCode}'),
            showCloseIcon: true,
          ),
        );
      }
    } catch (e) {
      print("Error sending login data to backend: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send login data to backend: $e'),
          showCloseIcon: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Sign Up',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
            height: 0,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: ListView(
          children: [
            const Text(
              'Enter your name',
              style: TextStyle(
                color: Color(0xFF191B1C),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20, top: 8),
              height: 54,
              decoration: inputContainerDecoration,
              child: TextField(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: themeFontFamily2,
                ),
                keyboardType: TextInputType.text,
                controller: nameController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20, right: 10),
                  hintText: 'Input your full name',
                  hintStyle: TextStyle(
                    color: Color(0xFF959FA3),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  checkEligible();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              height: 10,
              child: const Text(
                'Email address',
                style: TextStyle(
                  color: Color(0xFF191B1C),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                  height: 0.08,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 54,
              decoration: inputContainerDecoration,
              child: TextField(
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: themeFontFamily2),
                keyboardType: TextInputType.text,
                controller: emailController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20, right: 10),
                  hintText: 'Enter email address',
                  hintStyle: TextStyle(
                    color: Color(0xFF959FA3),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  checkEligible();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              height: 10,
              child: const Text(
                'Password',
                style: TextStyle(
                  color: Color(0xFF191B1C),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                  height: 0.08,
                ),
              ),
            ),
            Container(
              decoration: inputContainerDecoration,
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.only(left: 20, right: 10),
              height: 54,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: themeFontFamily2),
                keyboardType: TextInputType.text,
                controller: passwordController,
                obscureText: obscureTextPassword,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  border: InputBorder.none,
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(
                    color: Color(0xFF959FA3),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          visibleBoolPassword = !visibleBoolPassword;
                          obscureTextPassword = !obscureTextPassword;

                          setState(() {});
                        },
                        icon: Icon(
                          visibleBoolPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                onChanged: (value) {
                  checkEligible();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              height: 10,
              child: const Text(
                'Confirm Password',
                style: TextStyle(
                  color: Color(0xFF191B1C),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                  height: 0.08,
                ),
              ),
            ),
            Container(
              decoration: inputContainerDecoration,
              padding: const EdgeInsets.only(left: 20, right: 10),
              height: 54,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: themeFontFamily2),
                keyboardType: TextInputType.text,
                controller: confirmPasswordController,
                obscureText: obscureTextConfirmPassword,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  border: InputBorder.none,
                  hintText: 'Enter the same password',
                  hintStyle: const TextStyle(
                    color: Color(0xFF959FA3),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          visibleBoolConfirmPassword =
                              !visibleBoolConfirmPassword;
                          obscureTextConfirmPassword =
                              !obscureTextConfirmPassword;

                          setState(() {});
                        },
                        icon: Icon(
                          visibleBoolConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                onChanged: (value) {
                  checkEligible();
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: safetyAgreementChecked,
                  onChanged: (value) {
                    setState(() {
                      safetyAgreementChecked = value ?? false;
                      checkEligible();
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showSafetyAgreementBottomSheet(context);
                    },
                    child: const Text(
                      'I agree to the terms and conditions of this safety sign-off.',
                      style: TextStyle(
                        color: Color(0xFF191B1C),
                        fontSize: 14,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Opacity(
              opacity: eligibleForSignup ? 1 : 0.5,
              child: InkWell(
                onTap: eligibleForSignup
                    ? () {
                        performSignUp();
                      }
                    : null,
                child: Container(
                  width: double.maxFinite,
                  height: 48,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(-1.00, 0.06),
                      end: Alignment(1, -0.06),
                      colors: [
                        Color(0xFF0099FF),
                        Color(0xFF54AB6A),
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign Up',
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
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF888888),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.50,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'OR SIGN UP WITH',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                const Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF888888),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.50,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: _signInWithGoogle,
              child: Container(
                width: double.maxFinite,
                height: 56,
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFF888888)),
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset('assets/icons/GoogleLogo.svg'),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: Color(0xFF1F1F1F),
                        fontSize: 16,
                        fontFamily: themeFontFamily,
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Platform.isIOS
                ? Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: 358,
                    height: 56,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset('assets/icons/AppleLogo.svg'),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continue with Apple',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(''),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/login');
                  },
                  child: const Text(
                    'Sign In',
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
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  void checkEligible() {
    var name = nameController.text;
    var email = emailController.text;
    var password = passwordController.text;
    var confirmPassword = confirmPasswordController.text;

    if (email.isNotEmpty &&
        password.isNotEmpty &&
        name.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        safetyAgreementChecked) {
      eligibleForSignup = true;
    } else {
      eligibleForSignup = false;
    }
    setState(() {});
  }

  void _showSafetyAgreementBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'XplorionAi Travel Safety\nSign-Off & Liability Waiver',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: themeFontFamily,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Background color
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '1. Service Description & Purpose',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeFontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'XplorionAi is an AI-powered travel advisory tool designed to provide informational travel recommendations, such as travel routes, local attractions, and safety tips. Please note that XplorionAi does not offer or book accommodation options. All advice is generated by automated algorithms for informational purposes only. Users are strongly encouraged to independently verify all travel details and consult professional sources when making travel arrangements or decisions.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '2. Assumption of Risk & Due Diligence',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeFontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'By using this Service, I acknowledge and agree that:\n\n'
                  'I am solely responsible for conducting my own comprehensive research and due diligence regarding every aspect of my trip, including travel safety, local laws, environmental conditions, and other critical factors.\n\n'
                  'I recognize that travel inherently involves numerous risks, which may include—but are not limited to—the following:\n\n'
                  '• Personal Safety Risks: Incidents such as theft, extortion, kidnapping, crime, or sexual abuse.\n\n'
                  '• Travel-Related Risks: Situations including loss or theft of personal belongings (such as luggage), flight cancellations or delays, missed connections, itinerary changes, miscommunications, and fraudulent schemes—including currency scams or other fraudulent activities intended to defraud travelers.\n\n'
                  '• Document & Cyber Risks: Loss or theft of travel documents, or breaches that could lead to identity theft.\n\n'
                  '• Environmental & External Risks: Adverse weather conditions, natural disasters, political instability, strikes, or other unforeseeable events.\n\n'
                  '• Transportation & Accident Risks: Road accidents, transportation mishaps, or any incidents occurring during transit.\n\n'
                  'I understand that certain outcomes—especially those arising from deliberate or intentional actions—fall outside the scope of travel-related incidents covered by this policy. I further acknowledge that the Service does not extend to outcomes resulting from self-initiated or intentional acts.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '3. Disclaimer of Warranties & Limitation of Liability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeFontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'The travel information and recommendations provided by XplorionAi are supplied "as is" and without any express or implied warranties. This includes, but is not limited to, any warranties of accuracy, reliability, merchantability, fitness for a particular purpose, or non-infringement.\n\n'
                  'Under no circumstances shall XplorionAi, its affiliates, or its representatives be liable for any direct, indirect, incidental, consequential, or special damages. This includes, without limitation, damages for injury, death, property loss, or any harm—whether physical, financial, or emotional—that may result from the use of the Service.\n\n'
                  'I expressly acknowledge that I assume full responsibility for any accident, injury, loss (including loss of luggage, travel documents, or personal belongings), delays, cancellations, or any adverse event occurring during my travel. I hereby waive any right to bring legal action against XplorionAi on the basis of such events.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '4. Indemnification',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeFontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'I agree to indemnify, defend, and hold harmless XplorionAi and its affiliates from and against any claims, liabilities, damages, losses, or expenses arising directly or indirectly from my use of the Service, my travel decisions, or any incidents related to theft, extortion, kidnapping, crime, sexual abuse, loss of property, or any other travel-related issues.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '5. Emergency Medical Treatment Consent',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeFontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Should an emergency occur during my travels, I authorize local emergency medical services to provide any necessary treatment. I understand and accept that all costs related to such emergency care will be solely my responsibility.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '6. Governing Law and Venue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeFontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'This Agreement shall be governed by and construed in accordance with the laws of Karnataka, India. Any disputes arising out of or related to this Agreement shall be exclusively resolved in the courts located in Bengaluru, Karnataka, India.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '7. Severability',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeFontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'If any provision of this Agreement is found to be invalid or unenforceable, the remaining provisions shall continue in full force and effect. Any invalid or unenforceable provision shall be modified only to the extent necessary to preserve the intent of the Agreement.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '8. Privacy & Minimal Data Collection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeFontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'During this initial beta phase, XplorionAi collects only your email address for account management and service communications. We do not collect any photographs, videos, or other personally identifiable information (PII) beyond what is necessary. Our data practices strictly adhere to robust privacy standards and comply with all applicable data protection laws, ensuring that your information is handled securely and responsibly.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '9. Confirmation & Acceptance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: themeFontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'By proceeding to use the XplorionAi Travel App, I affirm that I have carefully read, understood, and voluntarily accept the terms of this Travel Safety Sign-Off & Liability Waiver. I acknowledge that:\n\n'
                  '• It is solely my responsibility to verify all travel-related information and safeguard my personal safety.\n\n'
                  '• I assume all risks associated with travel, including—but not limited to—the risks outlined above.\n\n'
                  '• I will not hold XplorionAi, its affiliates, or its agents liable for any negative outcomes resulting from my travel or reliance on the provided information.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future performSignUp() async {
    RegExp emailRegExp = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    RegExp passRegExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

    var name = nameController.text;
    var email = emailController.text;
    var password = passwordController.text;
    var confirmPassword = confirmPasswordController.text;

    if (name == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        content: Text('Please enter name'),
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
        ),
      ));
      return;
    }
    if (email == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        content: Text('Please enter email id'),
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
        ),
      ));
      return;
    }

    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          content: Text('Please enter a valid email Id'),
          duration: Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
          ),
        ),
      );
      return;
    }

    if (!passRegExp.hasMatch(password)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.fromLTRB(25, 15, 15, 15),
        margin: EdgeInsets.all(10),
        content: Text(
            'Password must contains : \n          At least 8 characters \n              Upper case letters (A-Z)\n              Lower case letters(a-z) \n              Special characters (ex. !@#\$&*~)\n              Numbers(0-9)'),
        duration: Duration(seconds: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24))),
      ));

      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          content: Text('Password do not match'),
          duration: Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(24),
            ),
          ),
        ),
      );
      return;
    }

    final map = <String, dynamic>{};
    map['username'] = name;
    map['email'] = email;
    map['password'] = password;

    final response = await http.post(
      Uri.parse('$baseurl/app/users/register'),
      body: map,
    );

    if (context.mounted) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['errFlag'] == 1) {
          var errorMessage = jsonData['message'];
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
            showCloseIcon: true,
          ));
          return;
        }

        if (jsonData['errFlag'] == 0) {
          await storage.write(key: 'userToken', value: jsonData['token']);

          await storage.write(key: 'username', value: name);
          await storage.write(key: 'email', value: email);
        }
      } else {
        const snackBar = SnackBar(
          content: Text('Couldnot be registered, Try after sometime'),
          showCloseIcon: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }

    Navigator.of(context).pushNamed('/choose_your_interests');
  }
}
