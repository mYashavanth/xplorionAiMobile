import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  bool isLoading = true;
  List<dynamic> allFriendsList = [];
  List<dynamic> taggedFriendsList = [];
  List<dynamic> mainFriendsList = [];

  final storage = const FlutterSecureStorage();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // A list of predefined colors for the avatars
  final List<Color> _avatarColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Fetches all data and updates the UI
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      await Future.wait([
        _fetchAllFriends(),
        _fetchTaggedFriendsForItinerary(),
      ]);
      _processFriendLists();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading friends: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // API call to get all friends for the user
  Future<void> _fetchAllFriends() async {
    final token = await storage.read(key: 'userToken');
    if (token == null) throw Exception('Authentication token not found.');

    final response = await http.get(
      Uri.parse('$baseurl/app/friends/all/$token'),
    );

    if (response.statusCode == 200) {
      if (mounted) allFriendsList = json.decode(response.body);
    } else {
      throw Exception('Failed to load all friends list.');
    }
  }

  // API call to get friends tagged to the specific itinerary
  Future<void> _fetchTaggedFriendsForItinerary() async {
    final token = await storage.read(key: 'userToken');
    if (token == null) throw Exception('Authentication token not found.');

    final response = await http.get(
      Uri.parse('$baseurl/app/friends/${widget.resIterneryId}/$token'),
    );

    if (response.statusCode == 200) {
      if (mounted) taggedFriendsList = json.decode(response.body);
    } else {
      throw Exception('Failed to load tagged friends.');
    }
  }

  // Processes lists to show all friends in the second list.
  void _processFriendLists() {
    final taggedEmails =
        taggedFriendsList.map((friend) => friend['friendEmail']).toSet();

    final fullTaggedFriends = allFriendsList
        .where((friend) => taggedEmails.contains(friend['friendEmail']))
        .toList();

    if (mounted) {
      setState(() {
        taggedFriendsList = fullTaggedFriends;
        mainFriendsList = allFriendsList;
      });
    }
  }

  // ACTION: Adds a new friend AND tags them to the current itinerary.
  Future<void> _addAndTagFriend() async {
    final token = await storage.read(key: 'userToken');
    if (token == null) return;

    try {
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
          await _tagFriend(_emailController.text, showSnackbar: false);
          _clearControllersAndRefresh();
        } else {
          _handleApiError(data['message']);
        }
      }
    } catch (e) {
      print('Error adding and tagging friend: $e');
    }
  }

  // ACTION: Adds a new friend to the main list ONLY.
  Future<void> _addFriendOnly() async {
    final token = await storage.read(key: 'userToken');
    if (token == null) return;

    try {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          _clearControllersAndRefresh();
        } else {
          _handleApiError(data['message']);
        }
      }
    } catch (e) {
      print('Error adding friend only: $e');
    }
  }

  // ACTION: Tags an existing friend to the itinerary.
  Future<void> _tagFriend(String friendEmail,
      {bool showSnackbar = true}) async {
    final token = await storage.read(key: 'userToken');
    if (token == null) return;
    try {
      final response = await http.post(
        Uri.parse('$baseurl/app/friends/share-iternary'),
        body: {
          'token': token,
          'friendEmail': friendEmail,
          'iternaryId': widget.resIterneryId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (showSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
        if (data['errFlag'] == 0) {
          _fetchData();
        }
      }
    } catch (e) {
      print('Error sharing itinerary: $e');
    }
  }

  // ACTION: PERMANENTLY removes a friend from the user's account.
  Future<void> _permanentlyRemoveFriend(String friendEmail) async {
    final token = await storage.read(key: 'userToken');
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseurl/app/friends/remove'),
        body: {'token': token, 'friendEmail': friendEmail},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        if (data['errFlag'] == 0) {
          _fetchData();
        }
      }
    } catch (e) {
      print('Error removing friend: $e');
    }
  }

  // --- HELPER METHODS ---
  void _clearControllersAndRefresh() {
    _nameController.clear();
    _emailController.clear();
    Navigator.pop(context);
    _fetchData();
  }

  void _handleApiError(String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Extracts initials from a friend's name.
  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.isEmpty || nameParts.first.isEmpty) {
      return '?';
    }
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }
    return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
  }

  /// Generates a consistent color for an avatar based on the friend's name.
  Color _getAvatarColor(String name) {
    // Use the hashcode of the name to pick a color from the list
    final index = name.hashCode % _avatarColors.length;
    return _avatarColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new)),
        centerTitle: true,
        title: const Text(
          'Manage Friends',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(15),
              children: [
                // Section 1: Add New Friend with two options
                const Text('Invite Friends',
                    style: TextStyle(
                      color: Color(0xFF191B1C),
                      fontSize: 18,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w500,
                    )),
                const Text('Add new friends and invite them to collaborate.',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                    )),
                const SizedBox(height: 20),
                _buildInviteButton(
                  text: 'Add & Tag to Itinerary',
                  icon: Icons.person_add,
                  isPrimary: true,
                  onTap: () => _showAddFriendDialog(
                    title: 'Add & Tag Friend',
                    onConfirm: _addAndTagFriend,
                  ),
                ),
                const SizedBox(height: 10),
                _buildInviteButton(
                  text: 'Add Friends',
                  icon: Icons.list_alt,
                  isPrimary: false,
                  onTap: () => _showAddFriendDialog(
                    title: 'Add Friend',
                    onConfirm: _addFriendOnly,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),

                // Section 2: Tagged Friends (READ-ONLY)
                const SizedBox(height: 20),
                const Text('Friends on this Itinerary',
                    style: TextStyle(
                      color: Color(0xFF191B1C),
                      fontSize: 18,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 10),
                taggedFriendsList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                            child: Text(
                                'No friends are tagged to this trip yet.',
                                style: TextStyle(color: Colors.grey))),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: taggedFriendsList.length,
                        itemBuilder: (context, index) {
                          final friend = taggedFriendsList[index];
                          return _buildFriendTile(
                            name: friend['friendName'],
                            email: friend['friendEmail'],
                            actionWidget: const SizedBox.shrink(),
                          );
                        },
                      ),
                const SizedBox(height: 20),
                const Divider(),

                // Section 3: User's Friend List (for adding or deleting)
                const SizedBox(height: 20),
                const Text('Your Friends List',
                    style: TextStyle(
                      color: Color(0xFF191B1C),
                      fontSize: 18,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 10),
                mainFriendsList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                            child: Text('Your friends list is empty.',
                                style: TextStyle(color: Colors.grey))),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mainFriendsList.length,
                        itemBuilder: (context, index) {
                          final friend = mainFriendsList[index];
                          // Check if this friend is already tagged in this itinerary
                          final isTagged = taggedFriendsList.any(
                              (taggedFriend) =>
                                  taggedFriend['friendEmail'] ==
                                  friend['friendEmail']);

                          return _buildFriendTile(
                            name: friend['friendName'],
                            email: friend['friendEmail'],
                            actionWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Conditionally show "Add" button or "Tagged" status
                                isTagged
                                    ? const Row(children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green, size: 20),
                                        SizedBox(width: 4),
                                        Text("Tagged",
                                            style:
                                                TextStyle(color: Colors.green))
                                      ])
                                    : TextButton(
                                        onPressed: () =>
                                            _tagFriend(friend['friendEmail']),
                                        child: const Text('Add',
                                            style: TextStyle(
                                                color: Color(0xFF005CE7))),
                                      ),
                                // Always show the permanent delete button
                                IconButton(
                                  onPressed: () => _showPermanentDeleteDialog(
                                      friend['friendEmail']),
                                  icon: const Icon(Icons.delete_outline,
                                      color: Color(0xFFCF0000)),
                                  tooltip: 'Permanently delete friend',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }

  // --- WIDGETS ---

  Widget _buildInviteButton(
      {required String text,
      required IconData icon,
      required bool isPrimary,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: ShapeDecoration(
          color: isPrimary ? const Color(0xFF005CE7).withOpacity(0.1) : null,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1, color: isPrimary ? Colors.transparent : Colors.black),
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: isPrimary ? const Color(0xFF005CE7) : Colors.black),
          const SizedBox(width: 10),
          Text(text,
              style: TextStyle(
                color: isPrimary ? const Color(0xFF005CE7) : Colors.black,
                fontSize: 16,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w600,
              )),
        ]),
      ),
    );
  }

  /// NEW WIDGET: Builds a dynamic avatar with initials and a unique color.
  Widget _buildFriendAvatar({required String name}) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: _getAvatarColor(name),
      child: Text(
        _getInitials(name),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildFriendTile(
      {required String name,
      required String email,
      required Widget actionWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        _buildFriendAvatar(name: name), // UPDATED: Use the new avatar widget
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              name,
              style: const TextStyle(
                color: Color(0xFF191B1C),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              email,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        const SizedBox(width: 8),
        actionWidget,
      ]),
    );
  }

  // --- DIALOGS ---

  void _showAddFriendDialog(
      {required String title, required Future<void> Function() onConfirm}) {
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
            child: Column(children: [
              Text(title,
                  style: const TextStyle(
                    color: Color(0xFF030917),
                    fontSize: 16,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w600,
                  )),
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
              Row(children: [
                Expanded(
                    child: _buildDialogButton('Cancel',
                        isPrimary: false, onTap: () => Navigator.pop(context))),
                const SizedBox(width: 8),
                Expanded(child: _buildDialogButton('Add', onTap: onConfirm)),
              ]),
            ]),
          ),
        );
      },
    );
  }

  void _showPermanentDeleteDialog(String friendEmail) {
    showDialog(
        context: context,
        builder: (context) => _buildConfirmationDialog(
              title: 'Remove friend permanently?',
              content:
                  'This will remove them from all your itineraries. This action cannot be undone.',
              confirmText: 'Delete',
              onConfirm: () {
                _permanentlyRemoveFriend(friendEmail);
                Navigator.pop(context);
              },
            ));
  }

  Widget _buildConfirmationDialog(
      {required String title,
      required String content,
      required String confirmText,
      required VoidCallback onConfirm}) {
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SvgPicture.asset('assets/icons/remove_friend.svg', height: 50),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
              fontFamily: themeFontFamily2,
            ),
          ),
          const Spacer(),
          Row(children: [
            Expanded(
                child: _buildDialogButton('Cancel',
                    isPrimary: false, onTap: () => Navigator.pop(context))),
            const SizedBox(width: 8),
            Expanded(child: _buildDialogButton(confirmText, onTap: onConfirm)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildDialogButton(String text,
      {bool isPrimary = true, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: ShapeDecoration(
          gradient: isPrimary ? themeGradientColor : null,
          color: isPrimary ? null : Colors.white,
          shape: RoundedRectangleBorder(
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(width: 1, color: Color(0xFF005CE7)),
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Center(
          child: Text(text,
              style: TextStyle(
                color: isPrimary ? Colors.white : const Color(0xFF005CE7),
                fontSize: 16,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w600,
              )),
        ),
      ),
    );
  }
}
