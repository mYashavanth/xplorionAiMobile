import 'dart:io';

import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

class YourProfile extends StatefulWidget {
  const YourProfile({super.key});

  @override
  State<YourProfile> createState() => _YourProfileState();
}

class _YourProfileState extends State<YourProfile> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  XFile? profileImage;

  @override
  void initState() {
    userNameController.text = 'Potato';
    nameController.text = 'Suhas M Mahindra';
    emailController.text = 'Potato@gmail.com';
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        title: const Text(
          'Your Profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                height: 28,
              ),
              const SizedBox(
                width: double.maxFinite,
                height: 20,
                child: Text(
                  'User name',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 16,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16, top: 8),
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
                    // checkEligible();
                  },
                ),
              ),
              const SizedBox(
                width: double.maxFinite,
                height: 20,
                child: Text(
                  'Name',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 16,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16, top: 8),
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
                  controller: nameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    hintText: 'Rohan',
                    hintStyle: TextStyle(
                      color: Color(0xFF959FA3),
                      fontSize: 14,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // checkEligible();
                  },
                ),
              ),
              const SizedBox(
                width: double.maxFinite,
                height: 20,
                child: Text(
                  'Email Id',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 16,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16, top: 8),
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
                  controller: emailController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    hintText: 'email@gmail.com',
                    hintStyle: TextStyle(
                      color: Color(0xFF959FA3),
                      fontSize: 14,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // checkEligible();
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
            InkWell(
              onTap: () {},
              child: Container(
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
                    'Update profile',
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
            // const SizedBox(
            //   height: 10,
            // ),
          ],
        ),
      ),
    );
  }
}
