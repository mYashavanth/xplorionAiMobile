import 'package:flutter/material.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/lib_assets/input_decoration.dart';

class SetPassword extends StatefulWidget {
  const SetPassword({super.key});

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool obscureTextPassword = true;
  bool obscureTextConfirmPassword = true;
  bool visibleBoolPassword = false;
  bool visibleBoolConfirmPassword = false;
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
          'Set Password',
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
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set a new password',
                style: TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 18,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              const Text(
                'Create a new password. Ensure it differs from previous ones for security',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14,
                  fontFamily: 'IBM Plex Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Password',
                style: TextStyle(
                  color: Color(0xFF191B1C),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                decoration: inputContainerDecoration,
                margin: const EdgeInsets.only(bottom: 20),
                height: 54,
                child: TextField(
                  enableInteractiveSelection: false,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: themeFontFamily2),
                  keyboardType: TextInputType.text,
                  controller: passwordController,
                  obscureText: obscureTextPassword,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none,
                    hintText: 'Enter your new password',
                    hintStyle: const TextStyle(
                      color: Color(0xFF959FA3),
                      fontSize: 14,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                      height: 0.10,
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
                  onChanged: (value) {},
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                height: 10,
                child: const Text(
                  'Confirm new password',
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
                height: 54,
                child: TextField(
                  enableInteractiveSelection: false,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: themeFontFamily2),
                  keyboardType: TextInputType.text,
                  controller: confirmPasswordController,
                  obscureText: obscureTextConfirmPassword,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20),
                    border: InputBorder.none,
                    hintText: 'Re-enter your new password',
                    hintStyle: const TextStyle(
                      color: Color(0xFF959FA3),
                      fontSize: 14,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                      height: 0.10,
                    ),
                    suffixIcon: IconButton(
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
                    Navigator.of(context)
                        .pushNamed('/password_reset_successful');
                  },
                  child: const Center(
                    child: Text(
                      'Update password',
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
        ]),
      ),
    );
  }
}
