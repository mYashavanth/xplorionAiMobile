import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:xplorion_ai/widgets/bottom_navbar.dart';
import 'package:xplorion_ai/widgets/home_page_widgets.dart';
import 'package:http/http.dart' as http;

class ContinuePlanning extends StatefulWidget {
  const ContinuePlanning({super.key});

  @override
  State<ContinuePlanning> createState() => _ContinuePlanningState();
}

class _ContinuePlanningState extends State<ContinuePlanning> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  List<Widget> createdIternery = [];

  Future<void> fetchItineraries() async {
    String? userToken = await storage.read(key: 'userToken');
    final response =
        await http.get(Uri.parse('$baseurl/itinerary/all/${userToken!}'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      int dataLen = data.length;

      setState(() {
        createdIternery = [];

        for (int i = 0; i < dataLen; i++) {
          var place = data[i]['cityStateCountry'];
          var itineraryString = data[i]['itinerary'];
          var travelCompanion = data[i]['travelCompanion'];
          int noOfDays = itineraryString['itinerary']['days'].length;
          String dayWithDate = itineraryString['itinerary']['days'][0]['day'];

          createdIternery.add(singleCardPlan(
              context,
              itineraryString['image_for_main_place'],
              place,
              noOfDays,
              dayWithDate,
              travelCompanion,
              data[i]['_id']));
          createdIternery.add(const SizedBox(
            height: 14,
          ));
        }
      });
    }
  }

  @override
  void initState() {
    fetchItineraries();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var meadiaWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Continue planning',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w600,
            // height: 0,
          ),
        ),
        // actions: [
        //   Container(
        //     width: 33,
        //     height: 33,
        //     decoration: const ShapeDecoration(
        //       image: DecorationImage(
        //         image: AssetImage("assets/images/profile_photo.jpeg"),
        //         fit: BoxFit.fill,
        //       ),
        //       shape: OvalBorder(),
        //     ),
        //   ),
        //   const SizedBox(
        //     width: 10,
        //   )
        // ],
      ),
      body: Padding(
        padding:
            EdgeInsets.fromLTRB(meadiaWidth * 0.04, 0, meadiaWidth * 0.04, 0),
        child: SingleChildScrollView(
          child: Column(
            children: createdIternery,
          ),
        ),
      ),
      // bottomNavigationBar: const TripssistNavigationBar(0),
    );
  }

  Widget planWidget() {
    return Container(
      height: 408,
      width: double.maxFinite,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            width: double.maxFinite,
            child: Stack(
              children: [
                Stack(
                  children: [
                    Image.network(
                        width: double.maxFinite,
                        height: 220,
                        fit: BoxFit.cover,
                        'https://s3-alpha-sig.figma.com/img/4d92/1c3a/d224d23ff8a7d12a6a9cfda75a6a9065?Expires=1718582400&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4&Signature=B97S2GDk5joQzpVhKJ5fRm5h5ih7QXdlcQ7pV1BfbcESz2Kpu6UdFI7ekf3VzSY2RB7EISXKIiU4-qj3ME3OmMxLwmwM2tZhKrCpy7aEA5~hBUcI0bq6u~Fo1~gFS6F~3sKoCY6WOphjTiKxCPpsPLKc-mdLIPuSzcybpt9HIeXOMijfX4vVOEOwWWeYYnWV-CP1MNCq0shw2A1J7XW14DneloTU95bXvHQP7cY8URxfa8VKWaXXd59dbIPiD5TwA4dOseZA~phE~Jh3Xp5ulilthbfNpFMdR2bvgGBD7SYGYKp2lej~x-A0xy57f9E1N5UQS9Yi9f2e99zq384vrQ__'),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.3,
                        child: Container(
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'May 22 - May 24',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w500,
                          // height: 0,
                        ),
                      ),
                      Text(
                        'Kochin, Kerala',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          // height: 0,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kochi (Cochin) for 5 days for a group of friends',
                  style: TextStyle(
                    color: Color(0xFF030917),
                    fontSize: 16,
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w500,
                    // height: 0.09,
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                const Text(
                  '22 May, 2024 (5 days)',
                  style: TextStyle(
                    color: Color(0xFF8B8D98),
                    fontSize: 14,
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w400,
                    // height: 0.12,
                  ),
                ),
                const SizedBox(
                  height: 7,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/bag.svg',
                      width: 13,
                      height: 13.5,
                      // fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    const Text(
                      'with friends',
                      style: TextStyle(
                        color: Color(0xFF8B8D98),
                        fontSize: 14,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w400,
                        // height: 0.12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 7,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 68,
                      height: 28,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const ShapeDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/friend_photo.jpeg"),
                                  fit: BoxFit.fill,
                                ),
                                shape: OvalBorder(
                                  side: BorderSide(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 19,
                            top: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const ShapeDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/profile_photo.jpeg"),
                                  fit: BoxFit.fill,
                                ),
                                shape: OvalBorder(
                                  side: BorderSide(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 38,
                            top: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const ShapeDecoration(
                                color: Color(0xFF8B8D98),
                                shape: OvalBorder(
                                  side: BorderSide(
                                    width: 1,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              child: const Image(
                                image:
                                    AssetImage('assets/icons/add_person.png'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 100,
                      height: 40,
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 24, vertical: 4),
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(-1.00, 0.06),
                          end: Alignment(1, -0.06),
                          colors: [Color(0xFF54AB6A), Color(0xFF0099FF)],
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Center(
                        child: Text(
                          'View plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600,
                            // height: 0.20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
