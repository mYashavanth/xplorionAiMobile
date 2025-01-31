import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  bool copied = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new)),
        centerTitle: true,
        title: const Text(
          'Friends',
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
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Invite Friends',
                  style: TextStyle(
                    color: Color(0xFF191B1C),
                    fontSize: 18,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Use the link below to invite friends to edit your trip.',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    setState(
                      () {
                        copied = !copied;
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Copy trip link',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SvgPicture.asset('assets/icons/copy.svg')
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Visibility(
                  visible: copied,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.done,
                        color: Color(0xFF54AB6A),
                        size: 12,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Link Copied',
                        style: TextStyle(
                          color: Color(0xFF54AB6A),
                          fontSize: 12,
                          fontFamily: 'IBM Plex Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Friends',
                  style: TextStyle(
                    color: Color(0xFF191B1C),
                    fontSize: 18,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                buildFriendList('friend_owner.jpeg', 'Rohan', true),
                const SizedBox(
                  height: 10,
                ),
                buildFriendList('friend2male.jpeg', 'Suhas', false),
                const SizedBox(
                  height: 10,
                ),
                buildFriendList('friend3male.jpeg', 'Subhash', false),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          // Navigator.of(context).pushNamed('/account_setup');
        },
        child: Container(
          margin: const EdgeInsets.all(15),
          width: double.maxFinite,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
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
              'Save',
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

  Widget buildFriendList(img, name, owner) {
    String ownerString = 'Friend';
    if (owner) {
      ownerString = "Owner";
    }
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/$img"),
              fit: BoxFit.cover,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Color(0xFF191B1C),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              ownerString,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const Spacer(),
        owner
            ? const Text('')
            : TextButton(
                onPressed: () {
                  deleteFriend();
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(
                    color: Color(0xFFCF0000),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
      ],
    );
  }

  deleteFriend() {
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
                      child: SvgPicture.asset('assets/icons/remove_friend.svg'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Remove friend ?',
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
                    'You can re-add them later with an invite link.',
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
                                'Delete',
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
