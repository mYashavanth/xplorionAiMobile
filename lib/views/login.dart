import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/lib_assets/input_decoration.dart';
import 'package:http/http.dart' as http;
import 'urlconfig.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final storage = const FlutterSecureStorage();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool eligibleForLogin = false;

  bool obscureTextPassword = true;
  bool visibleBoolPassword = false;
  bool wrongPassword = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

          await FirebaseAnalytics.instance.logLogin(
              loginMethod: 'google',
              parameters: {
                'email': email,
                'googleToken': googleToken,
                'username': username
              });

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
          'Log In',
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
        color: Colors.white,
        padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png', // Replace with your asset path
                  width: 240, // Adjust width as needed
                  // height: 100, // Adjust height as needed
                  // fit: BoxFit.cover, // Adjust fit as needed
                ),
              ],
            ),
            const Text(
              'Email address',
              style: TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
                // height: 0.08,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              // padding: const EdgeInsets.only(left: 20),
              height: 54,
              decoration: inputContainerDecoration,
              child: TextField(
                // enableInteractiveSelection: false,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: themeFontFamily2),
                keyboardType: TextInputType.text,
                controller: emailController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 20),
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
            const Text(
              'Password',
              style: TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
                // height: 0.08,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: wrongPassword
                        ? const Color(0xFFFF0000)
                        : const Color(0xFFCDCED7),
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(left: 20, right: 10),
              height: 54,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                // enableInteractiveSelection: false,
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
                    // height: 0.10,
                  ),
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        padding: const EdgeInsets.all(0),
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
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Visibility(
                  visible: wrongPassword,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 17,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'wrong password',
                        style: TextStyle(
                          color: Color(0xFFFF3636),
                          fontSize: 12,
                          fontFamily: themeFontFamily,
                          fontWeight: FontWeight.w400,
                          height: 0.11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 30,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/forgot_password');
                      wrongPassword = !wrongPassword;
                      setState(() {});
                    },
                    child: const Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Opacity(
              opacity: eligibleForLogin ? 1 : 0.5,
              child: Container(
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
                  onPressed: eligibleForLogin
                      ? () {
                          performLogin();
                        }
                      : null,
                  child: const Center(
                    child: Text(
                      'Log In',
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
                  width: MediaQuery.of(context).size.width * 0.35,
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
                  'OR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    fontFamily: themeFontFamily,
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                const Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
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
            //           width: 24,
            //           height: 24,
            //           clipBehavior: Clip.antiAlias,
            //           decoration: const BoxDecoration(color: Color(0xFF1877F2)),
            //           child: SvgPicture.asset('assets/icons/FacebookLogo.svg')),
            //       const SizedBox(width: 12),
            //       const Text(
            //         'Continue with Facebook',
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 16,
            //           fontFamily: themeFontFamily,
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
                    margin: const EdgeInsets.only(bottom: 30),
                    width: 358,
                    height: 56,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 24,
                            height: 24,
                            // clipBehavior: Clip.antiAlias,
                            // decoration: BoxDecoration(),
                            child:
                                SvgPicture.asset('assets/icons/AppleLogo.svg')),
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
                  'New to XplorionAi?',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed('/sign_up');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color(0xFF2C64E3),
                        fontSize: 16,
                        fontFamily: themeFontFamily,
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  checkEligible() {
    var email = emailController.text;
    var password = passwordController.text;

    if (email != '' && password != '') {
      eligibleForLogin = true;
      setState(() {});
    } else {
      eligibleForLogin = false;
      setState(() {});
    }
  }

  Future performLogin() async {
    RegExp emailRegExp = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    RegExp passRegExp =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

    var email = emailController.text;
    var password = passwordController.text;

    if (email == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter Mobile Number'),
        duration: Duration(seconds: 3),
      ));
      return;
    }

    if (!emailRegExp.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        content: Text('Please enter a valid email Id'),
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24))),
      ));
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
            'Password must contains : \n          At least 8 characters \n          Upper case letters (A-Z)\n          Lower case letters(a-z) \n          Special characters (ex. !@#\$&*~)\n          Numbers(0-9)'),
        duration: Duration(seconds: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24))),
      ));
      return;
    }

    final map = <String, dynamic>{};
    map['email'] = email;
    map['password'] = password;

    final response = await http.post(
      Uri.parse('$baseurl/app/users/login'),
      body: map,
    );

    if (context.mounted) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print("Response: $jsonData");
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

          await storage.write(key: 'username', value: jsonData['username']);

          await storage.write(key: 'email', value: email);
        }

        if (jsonData['showInterestsPage'] == 0) {
          Navigator.pushReplacementNamed(context, '/home_page');
        } else {
          Navigator.of(context).pushNamed('/choose_your_interests');
        }
      } else {
        const snackBar = SnackBar(
          content: Text('Couldnot Login, Try after sometime'),
          showCloseIcon: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }
  }
}
