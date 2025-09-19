import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xplorion_ai/views/urlconfig.dart';

class Friends extends StatefulWidget {
  final String resIterneryId;
  final String? iterneryTitle;
  const Friends(
      {super.key, required this.resIterneryId, required this.iterneryTitle});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  bool copied = false;
  List<dynamic> friendsList = [];
  bool isLoading = true;
  final storage = const FlutterSecureStorage();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    setState(() {
      isLoading = true;
    });
    try {
      final token = await storage.read(key: 'userToken');
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseurl/app/friends/all/$token'),
      );

      if (response.statusCode == 200) {
        setState(() {
          friendsList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // Handle error
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  Future<void> addFriend() async {
    try {
      final token = await storage.read(key: 'userToken');
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$baseurl/app/friends/add'),
        body: {
          'token': token,
          'friendName': _nameController.text,
          'friendEmail': _emailController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['errFlag'] == 0) {
          // Success
          fetchFriends(); // Refresh the list
          shareItineraryWithFriend();
          Navigator.pop(context); // Close the dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        } else {
          // Handle error
          Navigator.pop(context); // Close the dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      // Handle error
      print('Error adding friend: $e');
    }
  }

  Future<void> shareItineraryWithFriend() async {
    try {
      final token = await storage.read(key: 'userToken');
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$baseurl/app/friends/share-iternary'),
        body: {
          'token': token,
          'friendEmail': _emailController.text,
          'iternaryId': widget.resIterneryId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data++++++++++++++++++++++++++++++++: $data');
        if (data['errFlag'] == 0) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          print(
              'Itinerary shared successfully+++++++++++++++++++++++++++++++++++ ${data['message']}');
        } else {
          // Handle error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          print('Failed to share itinerary: ${data['message']}');
        }
      }
    } catch (e) {
      // Handle error
      print('Error sharing itinerary: $e');
    }
  }

  Future<void> removeFriend(String friendEmail) async {
    try {
      final token = await storage.read(key: 'userToken');
      if (token == null) return;

      final response = await http.post(
        Uri.parse('$baseurl/app/friends/remove'),
        body: {
          'token': token,
          'friendEmail': friendEmail,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['errFlag'] == 0) {
          // Success
          fetchFriends(); // Refresh the list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      }
    } catch (e) {
      // Handle error
      print('Error removing friend: $e');
    }
  }

  void showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Add Friend',
                  style: TextStyle(
                    color: Color(0xFF030917),
                    fontSize: 16,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Friend Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Friend Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: addFriend,
                        child: Container(
                          height: 56,
                          decoration: ShapeDecoration(
                            gradient: themeGradientColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Add',
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
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add),
        //     onPressed: showAddFriendDialog,
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
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
                        'Share the adventure! Invite friends to join your itinerary by email.',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 14,
                          fontFamily: themeFontFamily2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          showAddFriendDialog();
                          // Clipboard.setData(
                          //         const ClipboardData(text: "www.example.com"))
                          //     .then((_) {
                          //   setState(() {
                          //     copied = true;
                          //   });
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //         content: Text("Link copied to clipboard")),
                          //   );
                          // });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
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
                                'Add Friend',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: themeFontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // SvgPicture.asset('assets/icons/copy.svg')
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: showAddFriendDialog,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Visibility(
                        visible: copied,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.done,
                              color: Color(0xFF54AB6A),
                              size: 12,
                            ),
                            SizedBox(width: 4),
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
                      const SizedBox(height: 20),
                      const Text(
                        'Friends',
                        style: TextStyle(
                          color: Color(0xFF191B1C),
                          fontSize: 18,
                          fontFamily: themeFontFamily2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...friendsList.map((friend) {
                        return Column(
                          children: [
                            buildFriendList(
                              'traveler.png', // You might want to change this based on actual data
                              friend['friendName'],
                              friend['friendEmail'],
                              false, // Assuming all are friends, not owners
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                  )
                ],
              ),
      ),
      //   bottomNavigationBar: InkWell(
      //     onTap: () {
      //       // Navigator.of(context).pushNamed('/account_setup');
      //     },
      //     child: Container(
      //       margin: const EdgeInsets.all(15),
      //       width: double.maxFinite,
      //       height: 56,
      //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      //       decoration: ShapeDecoration(
      //         gradient: const LinearGradient(
      //           begin: Alignment(-1.00, 0.06),
      //           end: Alignment(1, -0.06),
      //           colors: [
      //             Color(0xFF0099FF),
      //             Color(0xFF54AB6A),
      //           ],
      //         ),
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(32),
      //         ),
      //       ),
      //       child: const Center(
      //         child: Text(
      //           'Save',
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 16,
      //             fontFamily: themeFontFamily,
      //             fontWeight: FontWeight.w600,
      //             height: 0.16,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
    );
  }

  Widget buildFriendList(img, name, email, owner) {
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
        const SizedBox(width: 10),
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
                  deleteFriend(email);
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

  deleteFriend(String friendEmail) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: 260,
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
                const SizedBox(height: 20),
                const Text(
                  'Remove friend?',
                  style: TextStyle(
                    color: Color(0xFF030917),
                    fontSize: 16,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          removeFriend(friendEmail);
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
      },
    );
  }
}
