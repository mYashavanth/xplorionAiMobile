import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:xplorion_ai/views/urlconfig.dart';

class AccountSetup extends StatefulWidget {
  const AccountSetup({super.key});

  @override
  State<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  TextEditingController userNameController = TextEditingController();

  bool nameEntered = false;

  final ImagePicker picker = ImagePicker();

  XFile? profileImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Container(
        // color: const Color(0xFFF6F8FC),
        width: double.maxFinite,
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                width: double.maxFinite,
                child: Text(
                  "Lock in your profile.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontSize: 24,
                    fontFamily: themeFontFamily,
                    fontWeight: FontWeight.w700,
                    // height: 0.06,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(3),
                decoration: const ShapeDecoration(
                  // color: Color(0xFFE6E6E6),
                  gradient: themeGradientColor,
                  shape: OvalBorder(),
                ),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFE6E6E6),
                    shape: OvalBorder(),
                  ),
                  // decoration: const BoxDecoration(
                  //   color: Color(0xFFE6E6E6),
                  //   // shape: OvalBorder(),
                  // ),
                  child: Stack(
                    alignment: Alignment.center,
                    // fit: StackFit.expand,
                    children: [
                      profileImage == null
                          ? Center(
                              child: SvgPicture.asset(
                                  'assets/icons/profile_filled.svg'),
                            )
                          : Container(
                              decoration: ShapeDecoration(
                                shape: const OvalBorder(),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                    File(profileImage!.path),
                                  ),
                                ),
                              ),
                            ),
                      profileImage == null
                          ? const Positioned(
                              top: 103,
                              child: Center(
                                child: Text(
                                  'Add profile picture',
                                  style: TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 10,
                                    fontFamily: themeFontFamily2,
                                    fontWeight: FontWeight.w400,
                                    height: 0,
                                  ),
                                ),
                              ),
                            )
                          : const Text(''),
                      Positioned(
                        top: 120,
                        left: 103,
                        child: InkWell(
                          onTap: () async {
                            profileImage = await picker.pickImage(
                                source: ImageSource.gallery);
                            setState(() {});
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            // margin: EdgeInsets.all(2),
                            decoration: const ShapeDecoration(
                              color: Color(0xFF005CE7),
                              shape: OvalBorder(
                                side: BorderSide(width: 2, color: Colors.white),
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const SizedBox(
                width: double.maxFinite,
                height: 20,
                child: Text(
                  'Enter your username',
                  style: TextStyle(
                    color: Color(0xFF030917),
                    fontSize: 16,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w500,
                    height: 0.09,
                  ),
                ),
              ),
        
              Container(
                margin: const EdgeInsets.only(bottom: 20),
        
                height: 54,
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: TextField(
                  enableInteractiveSelection: false,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  keyboardType: TextInputType.text,
                  controller: userNameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    hintText: 'Rohan441',
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: nameEntered ? 1 : 0.5,
              child: InkWell(
                onTap: nameEntered
                    ? () {
                        saveUserName();
                      }
                    : null,
                child: Container(
                  // margin: const EdgeInsets.only(top: 70),
                  width: double.maxFinite,
                  height: 56,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  decoration: ShapeDecoration(
                    gradient: themeGradientColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32)),
                  ),
                  child: const Center(
                    child: Text(
                      'Continue',
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
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'By continuing, you agree to our ',
                  style: TextStyle(
                    color: Color(0xFF8B8D98),
                    fontSize: 10,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: const Text(
                    'Terms of Use',
                    style: TextStyle(
                      color: Color(0xFF2C64E3),
                      fontSize: 10,
                      fontFamily: themeFontFamily,
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  checkEligible() {
    var name = userNameController.text;

    if (name != '') {
      nameEntered = true;
      setState(() {});
    } else {
      nameEntered = false;
      setState(() {});
    }
  }

  Future saveUserName() async {
    var name = userNameController.text;

    if (name.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        content: Text('User name must contains atleast 8 characters'),
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(24),
          ),
        ),
      ));
      return;
    }

    String? userToken = await storage.read(key: 'userToken');

    try {
      // Create the body for the POST request
      final map = <String, dynamic>{};
      map['userToken'] = userToken;
      map['appUserName'] = name.toString();

      // Send the POST request
      final response = await http.post(
        Uri.parse('$baseurl/app/app-users/update/app_user_name'),
        body: map,
      );

      // Check the status code of the response
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the response body
        final responseData = jsonDecode(response.body);

        print(responseData);

        if (responseData['errFlag'] == 0)
        {
            Navigator.of(context).pushNamed('/welcome_page');
        }

        if (responseData['errFlag'] == 2)
        {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            content: Text('Username exists!, Choose another username'),
            duration: Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(24),
              ),
            ),
          ));
        }

      } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            content: Text('Couldnot create Username'),
            duration: Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(24),
              ),
            ),
          ));
      }
    } catch (e) {
      print('Error occurred: $e');
    }

  }
}
