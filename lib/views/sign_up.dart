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

  Future<void> _signInWithGoogle() async {
    try {
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
        final String? displayName = user.displayName;

        if (email != null && displayName != null) {
          print("User email: $email");
          print("User display name: $displayName");

          await _sendLoginDataToBackend(email, 'Test@123', displayName);
        } else {
          print("Failed to retrieve user email or display name");
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
      String email, String password, String username) async {
    try {
      final map = <String, dynamic>{};
      map['email'] = email;
      map['password'] = password;
      map['username'] = username;

      final response = await http.post(
        Uri.parse('$baseurl/app/users/register'),
        body: map,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Backend response: $responseData");

        if (responseData['errFlag'] == 0) {
          await storage.write(key: 'userToken', value: responseData['token']);
          await storage.write(key: 'username', value: responseData['username']);

          if (responseData['showInterestsPage'] == 0) {
            Navigator.of(context).pushNamed('/home_page');
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

  bool eligibleForSignup = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        // color: const Color,
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
                // height: 0.08,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20, top: 8),
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
                enableInteractiveSelection: false,
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
                  suffixIcon: IconButton(
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
              // padding: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.only(left: 20, right: 10),
              height: 54,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                enableInteractiveSelection: false,
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
                    // height: 0.10,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      visibleBoolConfirmPassword = !visibleBoolConfirmPassword;
                      obscureTextConfirmPassword = !obscureTextConfirmPassword;

                      setState(() {});
                    },
                    icon: Icon(
                      visibleBoolConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ),
                onChanged: (value) {
                  checkEligible();
                },
              ),
            ),
            // Visibility(
            //   visible: wrongPassword,
            //   child: const Row(
            //     children: [
            //       Icon(
            //         Icons.error,
            //         color: Colors.red,
            //         size: 17,
            //       ),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(
            //         'wrong password',
            //         style: TextStyle(
            //           color: Color(0xFFFF3636),
            //           fontSize: 12,
            //           fontFamily: 'Inter',
            //           fontWeight: FontWeight.w400,
            //           height: 0.11,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(
              height: 20,
            ),
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

            // Google Sign-In Button
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

            // const SizedBox(
            //   height: 20,
            // ),
            //
            // // facebook sign in
            // Container(
            //   width: 358,
            //   height: 56,
            //   padding: const EdgeInsets.all(16),
            //   decoration: ShapeDecoration(
            //     color: const Color(0xFF1877F2),
            //     shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(32)),
            //   ),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Container(
            //         width: 24,
            //         height: 24,
            //         clipBehavior: Clip.antiAlias,
            //         decoration: const BoxDecoration(color: Color(0xFF1877F2)),
            //         child: SvgPicture.asset('assets/icons/FacebookLogo.svg'),
            //       ),
            //       const SizedBox(width: 12),
            //       const Text(
            //         'Continue with Facebook',
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 16,
            //           fontFamily: themeFontFamily2,
            //           fontWeight: FontWeight.w400,
            //           height: 0,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            const SizedBox(
              height: 20,
            ),

            //apple sign in

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

            //new to tripssist
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
                    // height: 0,
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

  checkEligible() {
    var name = nameController.text;
    var email = emailController.text;
    var password = passwordController.text;
    var confirmPassword = confirmPasswordController.text;

    if (email != '' && password != '' && name != '' && confirmPassword != '') {
      eligibleForSignup = true;
      setState(() {});
    } else {
      eligibleForSignup = false;
      setState(() {});
    }
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
