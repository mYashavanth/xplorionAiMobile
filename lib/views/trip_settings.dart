import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/lib_assets/input_decoration.dart';

class TripSettings extends StatefulWidget {
  const TripSettings({super.key});

  @override
  State<TripSettings> createState() => _TripSettingsState();
}

class _TripSettingsState extends State<TripSettings> {
  TextEditingController tripNameController = TextEditingController();
  TextEditingController manageFriendsController = TextEditingController();

  String startDate = '22nd May';
  String endDate = '24th May';
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
          'Trip Settings',
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
        //     onPressed: () {},
        //     icon: const Icon(Icons.file_upload_outlined),
        //   ),
        // ],
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
                    controller: tripNameController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(left: 20, right: 20),
                      hintText: 'Trip name',
                      hintStyle: TextStyle(
                        color: Color(0xFF959FA3),
                        fontSize: 14,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Dates or trip length',
                  style: TextStyle(
                    color: Color(0xFF191B1C),
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.only(left: 12),
                  height: 50,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFCDCED7),
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      // showModalBottomSheet(
                      //     isScrollControlled: true,
                      //     context: context,
                      //     builder: (context) {
                      //       return StatefulBuilder(builder:
                      //           (BuildContext context, StateSetter modalSetState) {
                      //         return dateModal(modalSetState);
                      //       });
                      //     });
                    },
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
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF030917),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          '$startDate  -  $endDate',
                          style: const TextStyle(
                            color: Color(0xFF030917),
                            fontSize: 14,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w400,
                            // height: 0.12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                // const Text(
                //   'Manage interests',
                //   style: TextStyle(
                //     color: Color(0xFF191B1C),
                //     fontSize: 16,
                //     fontFamily: 'IBM Plex Sans',
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
                // Container(
                //   margin: const EdgeInsets.only(bottom: 20, top: 6),
                //   // padding: const EdgeInsets.only(left: 10),
                //   height: 54,
                //   decoration: inputContainerDecoration,
                //   child: TextField(
                //     enableInteractiveSelection: false,
                //     style: const TextStyle(
                //         color: Colors.black,
                //         fontSize: 18,
                //         fontFamily: themeFontFamily2),
                //     keyboardType: TextInputType.text,
                //     controller: manageFriendsController,
                //     decoration: const InputDecoration(
                //       contentPadding: EdgeInsets.only(left: 20, right: 20),
                //       hintText: 'Manage interests',
                //       hintStyle: TextStyle(
                //         color: Color(0xFF959FA3),
                //         fontSize: 14,
                //         fontFamily: themeFontFamily2,
                //         fontWeight: FontWeight.w400,
                //       ),
                //       border: InputBorder.none,
                //     ),
                //     onChanged: (value) {},
                //   ),
                // ),
                // const SizedBox(
                //   height: 10,
                // ),
                const Text(
                  'Manage friends',
                  style: TextStyle(
                    color: Color(0xFF191B1C),
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.only(left: 12),
                  height: 50,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFFCDCED7)),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        // padding: const EdgeInsets.all(5),
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
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'Friends',
                        style: TextStyle(
                          color: Color(0xFF030917),
                          fontSize: 14,
                          fontFamily: themeFontFamily2,
                          fontWeight: FontWeight.w400,
                          // height: 0.12,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/friends');
                        },
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: (){},
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side:
                            const BorderSide(width: 1, color: Color(0xFFFF1B1B)),
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
                        const SizedBox(
                          width: 10,
                        ),
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
              'Save changes',
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
}
