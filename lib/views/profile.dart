import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/widgets/bottom_navbar.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Load the username when the widget is initialized
  }

  Future<void> _loadUsername() async {
    try {
      // Fetch the username from secure storage
      String? username = await storage.read(key: 'username');  // Assuming 'username' is the key
      setState(() {
        userName = username; // Update the state with the fetched username
      });
    } catch (e) {
      print('Error fetching username from secure storage: $e');
    }
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
        title: const Text("Profile",
            style: TextStyle(
              fontSize: 20,
              fontFamily: themeFontFamily,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Container(
              height: 92.18,
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      image: const DecorationImage(
                        image: AssetImage("assets/images/katrina.jpeg"),
                        fit: BoxFit.cover,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      userName != null
                          ? Text(
                        'Welcome\n$userName',
                        style: const TextStyle(
                          color: Color(0xFF191B1C),
                          fontSize: 18,
                          fontFamily: themeFontFamily2,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                          : const Text(
                        'Hi, Katrina',
                        style: TextStyle(
                          color: Color(0xFF191B1C),
                          fontSize: 18,
                          fontFamily: themeFontFamily2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // buildlinearProgressBar(),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // const Text(
                      //   '78% Completed',
                      //   style: TextStyle(
                      //     color: Color(0xFF888888),
                      //     fontSize: 14,
                      //     fontFamily: 'IBM Plex Sans',
                      //     fontWeight: FontWeight.w400,
                      //     // height: 0.10,
                      //   ),
                      // ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/your_profile');
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Itineraries',
              style: TextStyle(
                color: Color(0xFF030917),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            buildProfileRowWidget('about.svg', 'Edit Preferences','es'),
            buildProfileRowWidget('save_outline.svg', 'Saved','sd'),
            buildProfileRowWidget('ongoing.svg', 'Ongoing','og'),
            buildProfileRowWidget('completed.svg', 'Completed','cp'),
            buildProfileRowWidget('share.svg', 'Shared','sh'),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Your voice',
              style: TextStyle(
                color: Color(0xFF030917),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            buildProfileRowWidget('feedback.svg', 'Feedback','fb'),
            buildProfileRowWidget('rate_star_outline.svg', 'Rate Us','ru'),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'More',
              style: TextStyle(
                color: Color(0xFF030917),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            buildProfileRowWidget('about.svg', 'About','at'),
            buildProfileRowWidget('terms_of_use.svg', 'Terms of use','tu'),
            buildProfileRowWidget('privacy_policy.svg', 'Privacy Policy','pp'),
            buildProfileRowWidget('log_out.svg', 'Log out','lt'),
          ],
        ),
      ),
      bottomNavigationBar: const TripssistNavigationBar(2),
    );
  }

  Widget buildProfileRowWidget(svg, title, page) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: InkWell(
         onTap: (){

           if(page == 'es')
           {
                Navigator.of(context).pushNamed('/edit_your_interests');
           }
           else
           {
                redirect(title);
           }
      },
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              padding: const EdgeInsets.all(5),
              decoration: const ShapeDecoration(
                color: Color(0xFFEFEFEF),
                shape: OvalBorder(),
              ),
              child: Center(
                child: SvgPicture.asset('assets/icons/$svg'),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF030917),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () {
                redirect(title);
              },
              icon: const Icon(
                Icons.arrow_forward_ios_outlined,
                size: 20,
                color: Color(0xFF000000),
              ),
            ),
          ],
        ),
      ),
    );
  }

  redirect(route) {
    if(route == 'LogOut')
    {
      return logOut();
    }
    Navigator.of(context).pushNamed('/$route');
  }

  Widget buildlinearProgressBar() {
    return Container(
      height: 10,
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: ShapeDecoration(
        color: const Color(0xFFECF2FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 10,
            width: MediaQuery.of(context).size.width * 0.4,
            decoration: ShapeDecoration(
              // color: const Color(0xFFECF2FF),
              gradient: themeGradientColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  logOut() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Container(
              height: 260,
              // width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFDF3F3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset('assets/icons/logout_red.svg'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Confirm Logout ?',
                    style: TextStyle(
                      color: Color(0xFF030917),
                      fontSize: 16,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Are you sure you want to log out?',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 56,
                            width: 70,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 1, color: Color(0xFF005CE7)),
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Color(0xFF005CE7),
                                  fontSize: 16,
                                  fontFamily: themeFontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 56,
                            width: 70,
                            decoration: ShapeDecoration(
                              gradient: themeGradientColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: themeFontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
