import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/lib_assets/input_decoration.dart';
import 'package:xplorion_ai/views/friends.dart';
import 'package:xplorion_ai/views/urlconfig.dart';

class TripSettings extends StatefulWidget {
  final String resIterneryId;
  final String? iterneryTitle;

  const TripSettings({
    super.key,
    required this.resIterneryId,
    required this.iterneryTitle,
  });

  @override
  State<TripSettings> createState() => _TripSettingsState();
}

class _TripSettingsState extends State<TripSettings> {
  final TextEditingController tripNameController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    tripNameController.text = widget.iterneryTitle ?? '';
  }

  Future<void> deleteItinerary() async {
    final userToken = await storage.read(key: 'userToken');
    final url = '$baseurl/remove-itinerary/${widget.resIterneryId}/$userToken';

    try {
      print(url);
      final response = await http.get(Uri.parse(url));
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // Close the dialog
        Navigator.of(context).pop(); // Go back to the previous screen
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home_page', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete trip')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void showDeleteConfirmationDialog() {
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
                    child: SvgPicture.asset('assets/icons/logout_red.svg'),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Confirm Delete?',
                  style: TextStyle(
                    color: Color(0xFF030917),
                    fontSize: 16,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Are you sure you want to delete this trip?',
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
                        onTap: deleteItinerary,
                        child: Container(
                          height: 56,
                          decoration: ShapeDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0099FF), Color(0xFF54AB6A)],
                            ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        title: const Text(
          'Trip Settings',
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
                const Text(
                  'Trip name',
                  style: TextStyle(
                    color: Color(0xFF191B1C),
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20, top: 6),
                  height: 54,
                  decoration: inputContainerDecoration,
                  child: TextField(
                    controller: tripNameController,
                    enabled: false,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: themeFontFamily2,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20, right: 20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Manage friends',
                  style: TextStyle(
                    color: Color(0xFF191B1C),
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Navigator.of(context).pushNamed('/friends');
                    Navigator.push(
                        this.context,
                        MaterialPageRoute(
                          builder: (buildContext) => Friends(
                            resIterneryId: widget.resIterneryId,
                            iterneryTitle: widget.iterneryTitle,
                          ),
                        ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.only(left: 12),
                    height: 50,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFCDCED7)),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFEFEFEF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            child: SvgPicture.asset('assets/icons/friends.svg'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Friends',
                          style: TextStyle(
                            color: Color(0xFF030917),
                            fontSize: 14,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 28,
                          color: const Color(0xFF888888),
                        ),
                        // IconButton(
                        //   onPressed: () {
                        //     // Navigator.of(context).pushNamed('/friends');
                        //   },
                        //   icon: const Icon(Icons.arrow_forward_ios_rounded),
                        // ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: showDeleteConfirmationDialog,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFFF1B1B)),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Delete trip',
                          style: TextStyle(
                            color: Color(0xFFFF1B1B),
                            fontSize: 16,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SvgPicture.asset('assets/icons/delete_outline.svg'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
