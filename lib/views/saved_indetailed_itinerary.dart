import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:xplorion_ai/widgets/home_page_widgets.dart';
import 'package:http/http.dart' as http;

class SavedInDetailedItinerary extends StatefulWidget {
  const SavedInDetailedItinerary({super.key});

  @override
  State<SavedInDetailedItinerary> createState() =>
      _SavedInDetailedItineraryState();
}

class _SavedInDetailedItineraryState extends State<SavedInDetailedItinerary>
    with TickerProviderStateMixin {
  List<bool> slideCardAddColorBool = [false, false, false, false];

  late Slidable slide;
  late Future<List<Widget>>? futureIterneryData;
  @override
  @override
  void initState() {
    super.initState();
    // The API call will be assigned after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        futureIterneryData = fetchIndetailIterneryData(args['collectionId']);
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the listeners when the widget is disposed

    super.dispose();
  }

  List<Widget> iterneryData = [];

  Future<List<Widget>> fetchIndetailIterneryData(String collectionId) async {
    // Your API call logic here
    const FlutterSecureStorage storage = FlutterSecureStorage();
    String? userToken = await storage.read(key: 'userToken');
    final response = await http.get(Uri.parse(
        '$baseurl/app/collection/iternery/all/$collectionId/$userToken'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<Widget>((item) {
        var daysData = item[0]['itinerary']['itinerary']['days'];
        int daysDataLen = daysData.length;
        return singleCardPlanForSavedItinarary(
            context,
            item[0]['cityStateCountry'],
            daysDataLen.toString(),
            item[0]['itinerary']['itinerary']['days'][0]['day'],
            item[0]['itinerary']['travel_companion'],
            item[0]['itinerary']['image_for_main_place']);
      }).toList();
    } else {
      throw Exception('Failed to load itineraries');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        centerTitle: true,
        title: Text(
          args['titleCollection'],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
            height: 0,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.more_horiz_outlined),
        //   ),
        // ],
      ),
      body: futureIterneryData == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Widget>>(
              future: futureIterneryData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('No itineraries found'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No itineraries found'));
                }

                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: ListView(
                      children: snapshot.data!,
                    ),
                  ),
                );
              },
            ),
    );
  }

  /*Widget build(BuildContext context) {

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    fetchIndetailIterneryData(args['collectionId']);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
        centerTitle: true,
        title: Text(
          args['titleCollection'],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
            height: 0,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_outlined),
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: iterneryData,
          ),
        ),
      ),
    );
  }  */

  /* void deleteSavedItinerary() {
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
                      child: SvgPicture.asset('assets/icons/delete.svg'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Delete this Itinerary ?',
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
                    'You will not be able to recover it once deleted.',
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
  } */

  void edit(context) {}

  /*Widget buildSliderCard(index) {
    return singleCardPlanForSavedItinarary(context, index);
  }*/

  Widget singleCardPlanForSavedItinarary(
      context, cityStateTitle, days, startDate, travelCompanion, imageUrl) {
    return Column(
      children: [
        Container(
          height: 146,
          decoration: const BoxDecoration(),
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 144,
            // clipBehavior: Clip.antiAlias,
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Color(0xFFCDCED7),
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(24),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 116,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.57,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            cityStateTitle,
                            style: const TextStyle(
                              color: Color(0xFF030917),
                              fontSize: 16,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // const Spacer(),

                          // MenuAnchor(
                          //   alignmentOffset: const Offset(-140, 0),
                          //   style: MenuStyle(
                          //     backgroundColor: getMaterialStateColor(),
                          //     shadowColor: getMaterialStateColor(),
                          //     surfaceTintColor: getMaterialStateColor(),
                          //     shape: getMaterialStateShape(),
                          //   ),
                          //   builder: (context, controller, child) {
                          //     return GestureDetector(
                          //       onTap: () {
                          //         if (controller.isOpen) {
                          //           controller.close();
                          //         } else {
                          //           controller.open();
                          //         }
                          //         //setState(() {});
                          //       },
                          //       child: const Icon(
                          //         Icons.more_vert,
                          //         color: Color(0xFF8B8D98),
                          //       ),
                          //     );
                          //   },
                          //   menuChildren: const [
                          //     /*MenuItemButton(

                          //       onPressed: () => setState(() {

                          //       }),
                          //       child: Container(
                          //         color: Colors.white,
                          //         // width: 185,
                          //         // height: 22,
                          //         padding: const EdgeInsets.all(0),
                          //         child: const Row(
                          //           mainAxisSize: MainAxisSize.min,
                          //           mainAxisAlignment: MainAxisAlignment.start,
                          //           crossAxisAlignment: CrossAxisAlignment.center,
                          //           children: [
                          //             Icon(
                          //               Icons.edit,
                          //               color: Color(0xFF888888),
                          //             ),
                          //             // SizedBox(
                          //             //   child: SvgPicture.asset(
                          //             //       'assets/icons/${menuItemIcons[index]}',
                          //             //       width: 20),
                          //             // ),
                          //             SizedBox(width: 12),
                          //             Text(
                          //               'Edit itinerary',
                          //               style: TextStyle(
                          //                 color: Color(0xFF888888),
                          //                 fontSize: 14,
                          //                 fontFamily: themeFontFamily2,
                          //                 fontWeight: FontWeight.w500,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //     MenuItemButton(
                          //       onPressed: () => setState(() {}),
                          //       child: Container(
                          //         color: Colors.white,
                          //         // width: 185,
                          //         // height: 22,
                          //         padding: const EdgeInsets.all(0),
                          //         child: const Row(
                          //           mainAxisSize: MainAxisSize.min,
                          //           mainAxisAlignment: MainAxisAlignment.start,
                          //           crossAxisAlignment: CrossAxisAlignment.center,
                          //           children: [
                          //             Icon(
                          //               Icons.delete,
                          //               color: Color(0xFF888888),
                          //             ),
                          //             // SizedBox(
                          //             //   child: SvgPicture.asset(
                          //             //       'assets/icons/${menuItemIcons[index]}',
                          //             //       width: 20),
                          //             // ),
                          //             SizedBox(width: 12),
                          //             Text(
                          //               'Delete itinerary',
                          //               style: TextStyle(
                          //                 color: Color(0xFF888888),
                          //                 fontSize: 14,
                          //                 fontFamily: themeFontFamily2,
                          //                 fontWeight: FontWeight.w500,
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ), */
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '$startDate ($days days)',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 13,
                          height: 13.96,
                          child: SvgPicture.asset('assets/icons/bag.svg'),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          travelCompanion,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 14,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w400,
                            // height: 0.12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.54,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 47,
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
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
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
                                      color: Color(0xFF8B8D98),
                                      shape: OvalBorder(
                                        side: BorderSide(
                                          width: 1,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    child: const Image(
                                      image: AssetImage(
                                          'assets/icons/add_person.png'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 55,
                            height: 29,
                            padding: const EdgeInsets.all(0),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFECF2FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'View',
                                style: TextStyle(
                                  color: Color(0xFF005CE7),
                                  fontSize: 12,
                                  fontFamily: 'Sora',
                                  fontWeight: FontWeight.w600,
                                  // height: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
