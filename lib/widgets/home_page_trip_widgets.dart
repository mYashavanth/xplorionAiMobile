import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/lib_assets/input_decoration.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:http/http.dart' as http;

Future<void> _openMap(double latitude, double longitude) async {
  String googleMapsUrl =
      'geo:$latitude,$longitude?q=$latitude,$longitude'; // Launch Google Maps on Android with geo: scheme
  String appleMapsUrl =
      'http://maps.apple.com/?q=$latitude,$longitude'; // Launch Apple Maps on iOS with maps: scheme

  if (Platform.isAndroid) {
    // Android - Open Google Maps
    if (await canLaunchUrlString(googleMapsUrl)) {
      await launchUrlString(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  } else if (Platform.isIOS) {
    // iOS - Open Apple Maps
    if (await canLaunchUrlString(appleMapsUrl)) {
      await launchUrlString(appleMapsUrl);
    } else {
      throw 'Could not open Apple Maps.';
    }
  } else {
    throw 'Unsupported platform.';
  }
}

Future<void> addCollection(
    String collectionName, String token, BuildContext context) async {
  if (collectionName.isEmpty || token.isEmpty) {
    print(" Collection Name and Token Is emprty ");
  }

  // Define the API endpoint
  final String apiUrl = '$baseurl/app/collection/add';

  final Map<String, dynamic> requestBody = {
    'collectionName': collectionName,
    'token': token
  };

  try {
    // Make the POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      body: requestBody,
    );

    // Check the response
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      print('Collection added successfully: ${response.body}');
      if (responseBody['errFlag'] == 0) {
        // Collection added successfully
        print('Collection ID: ${responseBody['collectionId']}');
      } else {
        // Handle error case
        print('Error adding collection: ${responseBody['message']}');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error adding collection: ${responseBody['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print(
          'Failed to add collection: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}

Future<void> addIterneryToCollection(
    String collectionId, String iterneryId, String token) async {
  if (collectionId.isEmpty || iterneryId.isEmpty || token.isEmpty) {
    print(" Collection Name and iterneryId Is empty ");
  }

  // Define the API endpoint
  final String apiUrl = '$baseurl/app/collection/add-iternery-to-collection';

  final Map<String, dynamic> requestBody = {
    'iterneryId': iterneryId,
    'collectionId': collectionId,
    'token': token
  };

  try {
    // Make the POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      body: requestBody,
    );

    // Check the response
    if (response.statusCode == 200) {
      print('Iternery to Collection added successfully: ${response.body}');
    } else {
      print(
          'Failed to add collection: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}

Widget buildMenuItemsCard(index, title, menuBoolList, StateSetter setState,
    generateItineraryForDay, scrollToTripItinerary) {
  return GestureDetector(
    onTap: () {
      print('Clicked on menu item: $title at index: $index');
      print('boolList: $menuBoolList, ${menuBoolList[index]}');
      if (index < (menuBoolList.length - 4)) {
        generateItineraryForDay(dayNo: index + 1).then((_) => setState(() {
              for (var i = 0; i < menuBoolList.length; i++) {
                menuBoolList[i] = i == index;
              }
            }));
      } else {
        setState(() {
          for (var i = 0; i < menuBoolList.length; i++) {
            menuBoolList[i] = i == index;
          }
        });
      }
      scrollToTripItinerary();
    },
    child: Container(
      //  width: 61,
      height: 40,
      padding: const EdgeInsets.all(2),
      margin: const EdgeInsets.only(right: 8),
      decoration: ShapeDecoration(
        gradient:
            menuBoolList[index] ? themeGradientColor : noneThemeGradientColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: menuBoolList[index]
                ? Colors.transparent
                : const Color(0xFFCDCED7),
          ),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 8, right: 8),
        decoration: ShapeDecoration(
          color: menuBoolList[index] ? const Color(0xFFECF2FF) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color:
                  menuBoolList[index] ? const Color(0xFF005CE7) : Colors.black,
              fontSize: 14,
              fontFamily: themeFontFamily2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    ),
  );
}

class DayItineraryView extends StatefulWidget {
  final String weatherSvg;
  final String dayNum;
  final Function setState;
  final Map dayActivityDataArray;
  final BuildContext contextP;
  final List<bool> transpotationModeBool;
  final String weatherText;
  final Future<void> Function(String) redoItinerary;
  final Future<void> Function(String, String) redoIndividualItinerary;
  final Future<void> Function(String, String, String) updateMarkAsVisitedData;
  final List markAsVisitedList;

  const DayItineraryView({
    Key? key,
    required this.weatherSvg,
    required this.dayNum,
    required this.setState,
    required this.dayActivityDataArray,
    required this.contextP,
    required this.transpotationModeBool,
    required this.weatherText,
    required this.redoItinerary,
    required this.redoIndividualItinerary,
    required this.markAsVisitedList,
    required this.updateMarkAsVisitedData,
  }) : super(key: key);

  @override
  _DayItineraryViewState createState() => _DayItineraryViewState();
}

class _DayItineraryViewState extends State<DayItineraryView> {
  bool isLoading = false;

  Future<void> handleRedo() async {
    setState(() {
      isLoading = true;
    });

    await widget.redoItinerary(widget.dayNum); // Call the API

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List data = widget.dayActivityDataArray['data'];
    List<bool> day1SliderShowActivity =
        widget.dayActivityDataArray['showActivity'];
    List<int> day1SliderCurrentPos = widget.dayActivityDataArray['sliderPos'];
    String place = widget.dayActivityDataArray['place'];

    return Column(
      children: [
        Container(
          height: 90,
          padding: const EdgeInsets.all(12),
          decoration: ShapeDecoration(
            color: const Color(0xFFF6F9FF),
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 0.50, color: Color(0xFFB9CDF5)),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/${widget.weatherSvg}'),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.weatherText,
                  style: const TextStyle(
                    color: Color(0xFF005CE7),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SvgPicture.asset('assets/icons/board_flight.svg'),
            const SizedBox(width: 20),
            Text(
              'Day ${widget.dayNum} Itinerary',
              style: const TextStyle(
                color: Color(0xFF030917),
                fontSize: 20,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: isLoading ? null : handleRedo, // Disable tap when loading
              child: Container(
                height: 32,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0xFFEFEFEF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Row(
                  children: [
                    isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : SvgPicture.asset('assets/icons/redo.svg'),
                    const SizedBox(width: 6),
                    const Text(
                      'Redo',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: themeFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        //const SizedBox(
        //  height: 20,
        //),
        /*Row(
        children: [
          Container(
            height: 27,
            padding: const EdgeInsets.only(left: 12, right: 12),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFF005CE7)),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Center(
              child: SvgPicture.asset('assets/icons/navigation.svg'),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '69th main road, SBI staff colony, Vijayanagar, Bengaluru ',
                    style: TextStyle(
                      color: Color(0xFF030917),
                      fontSize: 16,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                      // height: 0.09,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  // recognizer:,
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: Color(0xFF005CE7),
                      fontSize: 16,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF005CE7),
                      // height: 0.09,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ), */
        const SizedBox(height: 20),
        Column(
          children: buildMultipleDayActivity(
            widget.setState,
            data,
            place,
            day1SliderCurrentPos,
            day1SliderShowActivity,
            widget.contextP,
            widget.transpotationModeBool,
            widget.redoIndividualItinerary,
            widget.dayNum,
            widget.markAsVisitedList,
            widget.updateMarkAsVisitedData,
          ),
        ),
        const SizedBox(height: 20),
        // buildDayActivity(
        //     setState, data[0], day1SliderCurrentPos, day1SliderShowActivity, 0),
      ],
    );
  }
}

List<Widget> buildMultipleDayActivity(
    setState,
    data,
    place,
    day1SliderCurrentPos,
    day1SliderShowActivity,
    contextP,
    transpotationModeBool,
    redoIndividualItinerary,
    dayNum,
    markAsVisitedList,
    updateMarkAsVisitedData) {
  List<Widget> column = [];
  for (var i = 0; i < data.length; i++) {
    column.add(
      buildDayActivity(
          setState,
          data[i],
          place,
          day1SliderCurrentPos,
          day1SliderShowActivity,
          i,
          contextP,
          transpotationModeBool,
          redoIndividualItinerary,
          dayNum,
          markAsVisitedList,
          updateMarkAsVisitedData),
    );
  }

  return column;
}

Widget buildDayActivity(
    setState,
    data,
    place,
    List<int> day1SliderCurrentPos,
    List<bool> day1SliderShowActivity,
    index,
    context,
    transpotationModeBool,
    redoIndividualItinerary,
    dayNum,
    markAsVisitedList,
    updateMarkAsVisitedData) {
  var currentPos = day1SliderCurrentPos[0];
  List<Widget> imageSliders = data[2];
  String vehicle = data[0];
  String activityNum = (index + 1).toString();
  String activityTimeAndTitle = data[1].toString();
  int visited = data[3];
  bool open = data[5];
  String ratings = data[6].toString();
  String onlineDescriptionAboutLocality = data[7].toString();
  String address = data[8].toString();
  double lat = data[9] ?? 0.0;
  double long = data[10] ?? 0.0;
  String kms = data[11].toString();
  String duration = data[12].toString();
  String originDestination = data[13].toString();
  String priceDescription = data[14].toString();
  String currentlyOpen = data[15].toString();
  String distance_units = data[16].toString();

  if (currentlyOpen == 'true') {
    open = true;
  } else {
    open = false;
  }

  Widget visitedWidget = Text('');
  // print(
  //     '++++++++++++++++++++++++++++++++++++++++++++++data++++++++++++++++++++++++=');
  // print(data[3]);
  // print(
  //     '++++++++++++++++++++++++++++++++++++++++++++++data++++++++++++++++++++++++=');
  // print(
  //     '++++++++++++++++++++++++++++++++++++++++++++++markvisited++++++++++++++++++++++++=');
  // print(markAsVisitedList);
  // print(
  //     '++++++++++++++++++++++++++++++++++++++++++++++markvisited++++++++++++++++++++++++=');
  visitedWidget = InkWell(
    onTap: () {
      print('Clicked on mark as visited');
      print('dayNum: $dayNum, index: $index');
      if (markAsVisitedList.any((item) =>
          item["day_no"] == dayNum.toString() &&
          item["indexId"] == index.toString())) {
        updateMarkAsVisitedData(
          index.toString(),
          '1',
          dayNum.toString(),
        );
      } else {
        updateMarkAsVisitedData(
          index.toString(),
          '0',
          dayNum.toString(),
        );
      }
    },
    child: Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        gradient: markAsVisitedList.any((item) =>
                item["day_no"] == dayNum.toString() &&
                item["indexId"] == index.toString())
            ? const LinearGradient(
                begin: Alignment(-1.00, 0.06),
                end: Alignment(1, -0.06),
                colors: [
                  Color(0xFF0099FF),
                  Color(0xFF54AB6A),
                ],
              )
            : null,
        color: markAsVisitedList.any((item) =>
                item["day_no"] == dayNum.toString() &&
                item["indexId"] == index.toString())
            ? null
            : const Color(0xFFECF2FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          markAsVisitedList.any((item) =>
                  item["day_no"] == dayNum.toString() &&
                  item["indexId"] == index.toString())
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Visited',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: themeFontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Mark as visited',
                  style: TextStyle(
                    color: Color(0xFF005CE7),
                    fontSize: 12,
                    fontFamily: themeFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ],
      ),
    ),
  );

  Widget vehicleIcon =
      const Icon(Icons.directions_car, color: Color(0xFF888888));

  if (vehicle == 'bus') {
    vehicleIcon = const Icon(Icons.directions_bus, color: Color(0xFF888888));
  } else if (vehicle == 'walk') {
    vehicleIcon = const Icon(Icons.directions_walk, color: Color(0xFF888888));
  }

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: kms.isNotEmpty
            ? [
                vehicleIcon,
                Text(
                  '$duration Mins • $kms $distance_units',
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     showModalBottomSheet(
                //       isScrollControlled: true,
                //       shape: const RoundedRectangleBorder(
                //         borderRadius: BorderRadius.only(
                //           topLeft: Radius.circular(8),
                //           topRight: Radius.circular(8),
                //         ),
                //       ),
                //       context: context,
                //       builder: (context) {
                //         return StatefulBuilder(
                //           builder: (
                //             context,
                //             StateSetter modalSetState,
                //           ) {
                //             return buildChangeTransportationModeBottomSheet(
                //                 transpotationModeBool, modalSetState, context);
                //           },
                //         );
                //         // return Container();
                //       },
                //     );
                //   },
                //   child: const Icon(Icons.arrow_drop_down),
                // ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    if (originDestination != '') {
                      // Extract latitudes and longitudes using RegExp
                      RegExp regExp = RegExp(r'\(([^,]+), ([^)]+)\)');
                      Iterable<RegExpMatch> matches =
                          regExp.allMatches(originDestination);

                      // Convert matches to list of coordinates
                      List<List<double>> coordinates = matches.map((match) {
                        double latitude = double.parse(match.group(1)!);
                        double longitude = double.parse(match.group(2)!);
                        return [latitude, longitude];
                      }).toList();

                      // Assign source and destination
                      List<double> source = coordinates[0];
                      List<double> destination = coordinates[1];

                      final double sourceLat =
                          source[0]; //37.7749; Source latitude
                      final double sourceLng =
                          source[1]; //-122.4194; Source longitude
                      final double destLat =
                          destination[0]; //34.0522; // Destination latitude
                      final double destLng =
                          destination[1]; // Destination longitude

                      Uri mapUri;

                      if (Platform.isIOS) {
                        // Use Apple Maps for iOS
                        mapUri = Uri.parse(
                          "https://maps.apple.com/?saddr=$sourceLat,$sourceLng&daddr=$destLat,$destLng",
                        );
                      } else {
                        // Use Google Maps for Android
                        mapUri = Uri.parse(
                          "https://www.google.com/maps/dir/?api=1&origin=$sourceLat,$sourceLng&destination=$destLat,$destLng&travelmode=driving",
                        );
                      }

                      if (await canLaunchUrl(mapUri)) {
                        await launchUrl(mapUri,
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw Exception("Could not launch map application");
                      }
                    }
                  },
                  child: const Text(
                    'Directions',
                    style: TextStyle(
                      color: Color(0xFF214EB0),
                      fontSize: 12,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Container(
                          color: index.isOdd ? Colors.grey : Colors.transparent,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            : [],
      ),
      const SizedBox(
        height: 20,
      ),
      Row(
        children: [
          Container(
            height: 27,
            padding: const EdgeInsets.only(left: 12, right: 12),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFF005CE7)),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: Center(
              child: Text(
                activityNum,
                style: const TextStyle(
                  color: Color(0xFF005CE7),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                  // height: 0,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              activityTimeAndTitle,
              style: const TextStyle(
                color: Color(0xFF030917),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      /*const SizedBox(
        height: 20,
      ),
      const Text(
        'Start your day with a hearty South Indian breakfast at Mavalli Tiffin Room (MTR), known for its dosas, idlis, and strong filter coffee.',
        style: TextStyle(
          color: Color(0xFF030917),
          fontSize: 16,
          fontFamily: themeFontFamily2,
          fontWeight: FontWeight.w400,
        ),
      ), */
      const SizedBox(
        height: 20,
      ),

      // Visibility(
      //   visible: !day1SliderShowActivity[index],
      //   child:
      //    Container(
      //     height: 54,
      //     padding: const EdgeInsets.all(10),
      //     decoration: ShapeDecoration(
      //       color: Colors.white,
      //       shape: RoundedRectangleBorder(
      //         side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
      //         borderRadius: BorderRadius.circular(8),
      //       ),
      //     ),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Text(
      //           data[4],
      //           style: const TextStyle(
      //             color: Color(0xFF030917),
      //             fontSize: 16,
      //             fontFamily: themeFontFamily2,
      //             fontWeight: FontWeight.w500,
      //           ),
      //         ),
      //         Container(
      //           width: 30,
      //           height: 30,
      //           // padding: const EdgeInsets.all(8),
      //           decoration: ShapeDecoration(
      //             color: const Color(0xFFEFEFEF),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(50),
      //             ),
      //           ),
      //           child: Center(
      //             child: IconButton(
      //               padding: const EdgeInsets.all(0),
      //               onPressed: () {
      //                 setState(() {
      //                   day1SliderShowActivity[index] =
      //                       !day1SliderShowActivity[index];
      //                 });
      //               },
      //               icon: const Icon(Icons.keyboard_arrow_down_outlined),
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),

      Visibility(
        // maintainAnimation: true,
        // maintainState: true,
        visible: !day1SliderShowActivity[index],
        // Visibility Widget child is in bottom of this widget
        replacement: Container(
          // height: 590,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      // height: 200,
                      // aspectRatio: 1,
                      // enlargeCenterPage: true,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      initialPage: 0,
                      // autoPlay: true,
                      onPageChanged: (i, reason) {
                        setState(
                          () {
                            day1SliderCurrentPos[index] = i;
                          },
                        );
                      },
                    ),
                    items: imageSliders,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      width: 30,
                      height: 30,
                      // padding: const EdgeInsets.all(8),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Center(
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            setState(() {
                              day1SliderShowActivity[index] =
                                  !day1SliderShowActivity[index];
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_up_rounded),
                        ),
                      ),
                    ),
                  ),
                  imageSliders.isEmpty || imageSliders.length == 1
                      ? const Text('')
                      : SizedBox(
                          height: 200,
                          width: double.maxFinite,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: imageSliders.map(
                                (url) {
                                  int indexS = imageSliders.indexOf(url);
                                  return Container(
                                    width: currentPos == indexS ? 14 : 8.0,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(50),
                                      ),
                                      // shape: BoxShape.circle,
                                      color: currentPos == indexS
                                          ? const Color(0xFFFFFFFF)
                                          : const Color(0xFFA5A5A5),
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          ),
                        ),
                ],
              ),
              //

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 270,
                          child: Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            data[4],
                            style: const TextStyle(
                              color: Color(0xFF030917),
                              fontSize: 20,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        RedoButton(
                          redoIndividualItinerary: redoIndividualItinerary,
                          dayNum: dayNum,
                          index: index,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    //
                    Row(
                      children: [
                        //
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          height: 26,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFEFEFEF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Park',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 12,
                                fontFamily: themeFontFamily2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        //

                        //
                        Container(
                          height: 26,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFEFEFEF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Garden',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 12,
                                fontFamily: themeFontFamily2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        //
                        //
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 190),
                          child: IntrinsicWidth(
                            child: Container(
                              height: 26,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFEFEFEF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  data[4],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 12,
                                    fontFamily: themeFontFamily2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        //
                      ],
                    ),
                    //

                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      onlineDescriptionAboutLocality,
                      style: const TextStyle(
                        color: Color(0xFF0A0A0A),
                        fontSize: 14,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    //
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/star_rating.svg'),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          // '$ratings ( Google ) • ₹₹',
                          ratings == "N/A" || ratings == "null"
                              ? 'No reviews yet—be the first!'
                              : '$ratings ( Google ) • ₹₹',
                          style: const TextStyle(
                            color: Color(0xFF0A0A0A),
                            fontSize: 14,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    //

                    const SizedBox(
                      height: 10,
                    ),

                    //
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/location.svg'),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            address == "N/A" || address == "null"
                                ? 'Location unknown—explore!'
                                : address,
                            style: const TextStyle(
                              color: Color(0xFF0A0A0A),
                              fontSize: 14,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    //

                    const SizedBox(
                      height: 10,
                    ),

                    //
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/clock_fill.svg'),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: open ? 'Open' : 'Closed',
                                      style: TextStyle(
                                        color: open
                                            ? Color(0xFF54AB6A)
                                            : Color(0xFFD93025),
                                        fontSize: 14,
                                        fontFamily: themeFontFamily2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: ' • ',
                                      style: TextStyle(
                                        color: Color(0xFF0A0A0A),
                                        fontSize: 14,
                                        fontFamily: themeFontFamily2,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              SeeHoursWidget(placeName: data[4]),
                            ],
                          ),
                        ),
                      ],
                    ),
                    //

                    const SizedBox(
                      height: 10,
                    ),

                    //
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/wallet.svg'),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            // 'Price Level : $priceDescription',
                            priceDescription == "N/A" ||
                                    priceDescription == "null"
                                ? 'Price Level : Price info missing—discover it!'
                                : 'Price Level : $priceDescription',
                            style: const TextStyle(
                              color: Color(0xFF0A0A0A),
                              fontSize: 14,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    //
                    Row(
                      children: [
                        SvgPicture.asset('assets/icons/sand_timer.svg'),
                        const SizedBox(
                          width: 10,
                        ),
                        const Expanded(
                          child: Text(
                            'Waiting up to 30 min to 1 hr here',
                            style: TextStyle(
                              color: Color(0xFF0A0A0A),
                              fontSize: 14,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    //

                    const SizedBox(
                      height: 20,
                    ),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      // mainAxisSize: MainAxisSize.min,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFECF2FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset('assets/icons/directions.svg'),
                              const SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  _openMap(lat, long); // 12.971599, 77.594566
                                },
                                child: const Text(
                                  'Directions',
                                  style: TextStyle(
                                    color: Color(0xFF214EB0),
                                    fontSize: 12,
                                    fontFamily: themeFontFamily2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed('/similar_restuarant', arguments: {
                              'placeName': data[4],
                              'place': place,
                            });
                          },
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFECF2FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset('assets/icons/similar.svg'),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  'Similar',
                                  style: TextStyle(
                                    color: Color(0xFF005CE7),
                                    fontSize: 12,
                                    fontFamily: themeFontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //

                        visitedWidget
                      ],
                    ),
                    //
                  ],
                ),
              ),
            ],
          ),
        ),
        child: Container(
          height: 54,
          padding: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data[4],
                style: const TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                // padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                  color: const Color(0xFFEFEFEF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Center(
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      setState(() {
                        day1SliderShowActivity[index] =
                            !day1SliderShowActivity[index];
                      });
                    },
                    icon: const Icon(Icons.keyboard_arrow_down_outlined),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
    ],
  );
}

class SeeHoursWidget extends StatefulWidget {
  final String placeName;

  const SeeHoursWidget({Key? key, required this.placeName}) : super(key: key);

  @override
  _SeeHoursWidgetState createState() => _SeeHoursWidgetState();
}

class _SeeHoursWidgetState extends State<SeeHoursWidget> {
  bool _isLoading = false;

  Future<void> _loadHours() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weekData = await fetchOpenCloseInfo(widget.placeName);
      final weekdayText = List<String>.from(weekData['weekday_text']);
      showOpenCloseInfoBottomSheet(context, weekdayText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load opening hours: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _loadHours,
      child: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF214EB0)),
              ),
            )
          : const Text(
              'See hours',
              style: TextStyle(
                color: Color(0xFF214EB0),
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF214EB0),
              ),
            ),
    );
  }
}

class RedoButton extends StatefulWidget {
  final Function redoIndividualItinerary;
  final String dayNum;
  final int index;

  const RedoButton({
    Key? key,
    required this.redoIndividualItinerary,
    required this.dayNum,
    required this.index,
  }) : super(key: key);

  @override
  _RedoButtonState createState() => _RedoButtonState();
}

class _RedoButtonState extends State<RedoButton> {
  bool _isLoading = false;

  Future<void> _handleRedo() async {
    setState(() {
      _isLoading = true;
    });

    await widget.redoIndividualItinerary(widget.dayNum, widget.index);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleRedo,
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: ShapeDecoration(
          color: const Color(0xFFEFEFEF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : SvgPicture.asset('assets/icons/redo.svg'),
        ),
      ),
    );
  }
}

Widget buildChangeTransportationModeBottomSheet(
    transpotationModeBool, modalSetState, context) {
  return Container(
    width: double.maxFinite,
    height: 400,
    decoration: const ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
    ),
    child: Column(
      children: [
        Container(
          width: double.maxFinite,
          height: 87,
          clipBehavior: Clip.antiAlias,
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 7,
                offset: Offset(0, -1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Change Transportation mode',
              style: TextStyle(
                color: Color(0xFF030917),
                fontSize: 20,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        buildTranspotationWidget(0, transpotationModeBool, modalSetState),
        buildTranspotationWidget(1, transpotationModeBool, modalSetState),
        buildTranspotationWidget(2, transpotationModeBool, modalSetState),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  height: 56,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFF005CE7)),
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
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 56,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  decoration: ShapeDecoration(
                    gradient: themeGradientColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Done',
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
        )
      ],
    ),
  );
}

Widget buildTranspotationWidget(index, transpotationModeBool, modalSetState) {
  String title = 'Driving (15 mins • 5 kms)';
  Widget iconWidget = Icon(
    Icons.directions_car,
    color:
        transpotationModeBool[index] ? const Color(0xFF005CE7) : Colors.black,
  );

  if (index == 1) {
    title = 'Transit (25 mins • 5.25 kms)';
    iconWidget = Icon(
      Icons.directions_bus,
      color:
          transpotationModeBool[index] ? const Color(0xFF005CE7) : Colors.black,
    );
  } else if (index == 2) {
    title = 'Walking (30 mins • 4.2 kms)';
    iconWidget = Icon(
      Icons.directions_walk_sharp,
      color:
          transpotationModeBool[index] ? const Color(0xFF005CE7) : Colors.black,
    );
  }

  return InkWell(
    onTap: () {
      for (var i = 0; i < transpotationModeBool.length; i++) {
        transpotationModeBool[i] = i == index;
      }

      modalSetState(() {});
    },
    child: Container(
      margin: const EdgeInsets.all(10),
      height: 52.18,
      padding: const EdgeInsets.all(2),
      decoration: ShapeDecoration(
        gradient: transpotationModeBool[index]
            ? themeGradientColor
            : noneThemeGradientColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: transpotationModeBool[index]
                ? Colors.transparent
                : const Color(0xFFCDCED7),
          ),
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: transpotationModeBool[index]
              ? const Color(0xFFECF2FF)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: TextStyle(
                color: transpotationModeBool[index]
                    ? const Color(0xFF005CE7)
                    : Colors.black,
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Visibility(
              visible: transpotationModeBool[index],
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF005CE7),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Widget buildLocalFoodAndDrinks(context, Future<List<Widget>> foodDrinkArr) {
  return Column(children: [
    FutureBuilder<List<Widget>>(
      future: foodDrinkArr,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading spinner while waiting for the data
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle any errors that occur during the fetch
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Handle the case where no data is available
          return const Text('No Records available');
        } else {
          // Build the list of widgets with SizedBox spacing
          List<Widget> spacedWidgetsFD = [
            Row(
              children: [
                SvgPicture.asset('assets/icons/food_bowl.svg'),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Local Food and Drinks',
                  style: TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 20,
                    fontFamily: themeFontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          ];

          // Group widgets into rows of two cards each
          List<Widget> rows = [];
          List<Widget> widgets = snapshot.data!;

          for (int i = 0; i < widgets.length; i += 2) {
            rows.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // First card
                    Expanded(child: widgets[i]),
                    const SizedBox(width: 10), // Spacing between cards

                    // Second card if available
                    if (i + 1 < widgets.length)
                      Expanded(child: widgets[i + 1])
                    else
                      const Expanded(
                          child: SizedBox()), // Empty space if odd count
                  ],
                ),
              ),
            );
          }

          return Column(children: [
            ...spacedWidgetsFD,
            const SizedBox(height: 10),
            ...rows,
            const SizedBox(height: 40),
          ]);
        }
      },
    )
  ]);

  /*
  return Column(
    children: [
      Row(
        children: [
          SvgPicture.asset('assets/icons/food_bowl.svg'),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'Local Food and Drinks',
            style: TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 20,
              fontFamily: themeFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      // GridView(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      // children: [buildLocalFoodAndDrinksCard(1)],)
      const SizedBox(
        height: 10,
      ),

      Row(
        children: [
          buildLocalFoodAndDrinksCard(
              'karimeenu_polichuttu.jpeg',
              'non-veg',
              'Karimeen Pollichathu',
              'This dish features marinated pearl spot fish grilled in banana leaves for a smoky flavor.',
              context),
          const SizedBox(
            width: 10,
          ),
          buildLocalFoodAndDrinksCard(
              'puttu_and_kadala_curry.jpeg',
              'veg',
              'Puttu and Kadala curry',
              'Puttu and Kadala Curry is a popular Kerala breakfast of steamed rice cakes and spicy black gram curry.',
              context)
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Row(
        children: [
          buildLocalFoodAndDrinksCard(
              'toddy.jpeg',
              'non-veg',
              'Toddy',
              'Toddy, also known as Kallu, is a traditional alcoholic beverage in Kochi made from the sap of palm trees.',
              context),
          const SizedBox(
            width: 10,
          ),
          buildLocalFoodAndDrinksCard(
              'sulaimani_tea.jpeg',
              'veg',
              'Sulaimani Tea',
              'Sulaimani Tea from Kochi is a sweet and sour black tea flavored with lemon, cardamom, and cloves.',
              context)
        ],
      ),
      const SizedBox(
        height: 40,
      )
    ],
  ); */
}

Widget buildLocalFoodAndDrinksCard(img, svg, title, desc, context) {
  var svgIconString = 'non_veg_icon.svg';
  if (svg == 'veg') {
    svgIconString = 'veg_icon.svg';
  }
  return Expanded(
    child: Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFCDCED7),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            width: double.maxFinite,
            height: 111,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage('$img'),
                fit: BoxFit.cover,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    // SvgPicture.asset(
                    //   'assets/icons/$svgIconString',
                    //   width: 21,
                    // ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    Container(
                      // height: 16,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFDC9B10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text(
                        'Food item',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: themeFontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0A0A0A),
                      fontSize: 14,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF484848),
                    fontSize: 12,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        // barrierLabel: 'label',
                        barrierColor: Colors.black87,
                        showDragHandle: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        context: context,
                        builder: (context) {
                          return showFoodBottomSheet(
                              img, svgIconString, title, desc);
                        });
                  },
                  child: Container(
                    height: 30,
                    width: double.maxFinite,
                    // padding:
                    //     const EdgeInsets.symmetric(horizontal: 60, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFECF2FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'View',
                        style: TextStyle(
                          color: Color(0xFF005CE7),
                          fontSize: 14,
                          fontFamily: themeFontFamily2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

Widget showFoodBottomSheet(img, svg, title, description) {
  return Container(
    // padding: const EdgeInsets.all(10),
    height: 530,
    margin: EdgeInsets.all(10),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 1,
          color: Color(0xFFCDCED7),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    child: Column(
      children: [
        Container(
          height: 225,
          padding: const EdgeInsets.only(top: 207, bottom: 12),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: NetworkImage("$img"),
              fit: BoxFit.cover,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  // SvgPicture.asset(
                  //   'assets/icons/$svg',
                  //   width: 21,
                  // ),
                  // const SizedBox(
                  //   width: 10,
                  // ),
                  Container(
                    // height: 16,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFDC9B10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text(
                      'Food item',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: themeFontFamily,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 20,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              /*const SizedBox(
                height: 10,
              ),
             Row(
                children: [
                  Container(
                    // height: 26,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEFEFEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Black Gram',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Container(
                    // height: 26,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEFEFEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Onions',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Container(
                    // height: 26,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEFEFEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Garlic',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),*/
              const SizedBox(
                height: 10,
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF0A0A0A),
                  fontSize: 14,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget buildBestTimeToVisit(Future<List<Widget>> bestTimeToVisitArr) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/clock_outline.svg',
            width: 35,
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'Best time to visit',
            style: TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 20,
              fontFamily: themeFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      FutureBuilder<List<Widget>>(
        future: bestTimeToVisitArr,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading spinner while waiting for the data
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle any errors that occur during the fetch
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Handle the case where no data is available
            return const Text('No tips available');
          } else {
            // Build the list of widgets with SizedBox spacing
            List<Widget> spacedWidgets = [];
            for (int i = 0; i < snapshot.data!.length; i++) {
              print(
                  '+++++++++++++++++++++++++++++++++++++++++snapshot+++++++++++++++++++++++++++++++++++++++');
              print(snapshot.data![i]);
              print(
                  '+++++++++++++++++++++++++++++++++++++++++snapshot+++++++++++++++++++++++++++++++++++++++');
              spacedWidgets.add(snapshot.data![i]);
              if (i < snapshot.data!.length - 1) {
                spacedWidgets.add(const SizedBox(height: 10));
              }
            }

            return Column(
              children: spacedWidgets,
            );
          }
        },
      )
    ],
  );
}

Widget buildNationalHolidays(holiday) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/holiday.svg',
            width: 35,
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'National Holidays',
            style: TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 20,
              fontFamily: themeFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      const Text(
        'Here you can find the national calendar of all public holidays for the year. These dates are subject to change as official changes are announced, so check back regularly for updates.',
        style: TextStyle(
          color: Color(0xFF0A0A0A),
          fontSize: 16,
          fontFamily: themeFontFamily2,
          fontWeight: FontWeight.w400,
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      DataTable(
        dividerThickness: 0.5,
        horizontalMargin: 0,
        columns: const <DataColumn>[
          DataColumn(
            label: Expanded(
              child: Text(
                'Date',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Day',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          DataColumn(
            label: Expanded(
              child: Text(
                'Holiday Name',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
        rows: buildDataRow(holiday),
      ),
      const SizedBox(
        height: 10,
      ),
      Container(
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFECF2FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            SvgPicture.asset('assets/icons/information_note.svg'),
            const SizedBox(
              width: 10,
            ),
            const Expanded(
              child: Text(
                "Please note that during national and public holidays, opening hours for establishments, museums, etc. may vary. Don't forget to check in advance!",
                style: TextStyle(
                  color: Color(0xFF005CE7),
                  fontSize: 12,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 40,
      )
    ],
  );
}

List<DataRow> buildDataRow(holiday) {
  List<DataRow> dataRow = [];

  holiday
      .map(
        (item) => dataRow.add(
          DataRow(
            cells: [
              DataCell(
                Text(
                  item['date'],
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DataCell(
                Text(
                  item['day'],
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DataCell(
                Text(
                  item['holiday_name'],
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 14,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
      .toList();

  return dataRow;
}

Widget buildImportantInformation(importantInfoShowCardBool, setState) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/imp_info.svg',
            width: 35,
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'Important Information',
            style: TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 20,
              fontFamily: themeFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      buildHideShowCard(0, importantInfoShowCardBool, setState,
          'safety_tips.svg', 'Safety Tips', 0, []),
      const SizedBox(
        height: 20,
      ),
      buildHideShowCard(1, importantInfoShowCardBool, setState,
          'safe_roaming_hours.svg', 'Safe Roaming Hours', 0, []),
      const SizedBox(
        height: 20,
      ),
      buildHideShowCard(2, importantInfoShowCardBool, setState, 'tips.svg',
          'Scams to be aware of', 1, []),
      const SizedBox(
        height: 20,
      ),
      buildHideShowCard(3, importantInfoShowCardBool, setState,
          'emergency_info.svg', 'Emergency information', 2, [
        'Time Zone : UTC+5.5.',
        'Driving side : Left.',
        'Emergency phone : Ambulance: 102; Fire: 101; Police: 100; Traffic-accident: 103',
        'Power sockets : 230 V'
      ]),
      const SizedBox(
        height: 20,
      ),
      buildHideShowCard(4, importantInfoShowCardBool, setState,
          'power_socket.svg', 'Power sockets', 3, []),
      const SizedBox(
        height: 40,
      ),
    ],
  );
}

Widget buildHideShowCard(index, List<bool> importantInfoShowCardBool, setState,
    svg, title, type, List<String> listItems) {
  Widget widgetData = const Text(
    "Daytime hours are generally safer for exploring Bangalore's attractions and neighborhoods",
    style: TextStyle(
      color: Color(0xFF484848),
      fontSize: 14,
      fontFamily: themeFontFamily2,
      fontWeight: FontWeight.w400,
    ),
  );

  if (type == 1) {
    widgetData = Column(
      children: [
        createList('Beware of overcharging by taxis and rickshaws.'),
        const SizedBox(
          height: 10,
        ),
        createList(
            'Avoid purchasing items without bargaining; speak to locals for guidance and ensure fair prices unless marked as Maximum Retail Price (MRP).'),
      ],
    );
  } else if (type == 2) {
    List<Widget> columnChildrenWidget = [];

    for (var i = 0; i < listItems.length; i++) {
      columnChildrenWidget.add(
        createList(listItems[i]),
      );

      if (i != (listItems.length - 1)) {
        columnChildrenWidget.add(const SizedBox(
          height: 10,
        ));
      }
    }

    widgetData = Column(children: columnChildrenWidget);
    // const SizedBox(
    //   height: 10,
    // ),

    // widgetData =
    //  Column(
    //   children: [
    //     createList('Time Zone : UTC+5.5.'),
    //     const SizedBox(
    //       height: 10,
    //     ),
    //     createList('Driving side : Left.'),
    //     const SizedBox(
    //       height: 10,
    //     ),
    //     createList(
    //         'Emergency phone : Ambulance: 102; Fire: 101; Police: 100; Traffic-accident: 103'),
    //     const SizedBox(
    //       height: 10,
    //     ),
    //     createList('Power sockets : 230 V'),
    //   ],
    // );
  } else if (type == 3) {
    widgetData = Row(
      children: [
        Column(
          children: [
            const Text(
              'Type C',
              style: TextStyle(
                color: Color(0xFF484848),
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SvgPicture.asset(
              'assets/icons/typeC.svg',
              width: 64,
            )
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          children: [
            const Text(
              'Type D',
              style: TextStyle(
                color: Color(0xFF484848),
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SvgPicture.asset(
              'assets/icons/typeD.svg',
              width: 64,
            )
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          children: [
            const Text(
              'Type M',
              style: TextStyle(
                color: Color(0xFF484848),
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SvgPicture.asset(
              'assets/icons/typeM.svg',
              width: 64,
            )
          ],
        ),
      ],
    );
  }
  return Container(
    width: double.maxFinite,
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/$svg',
              color: const Color(0xFF005CE8),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF030917),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              width: 30,
              height: 30,
              // padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: const Color(0xFFEFEFEF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  setState(() {
                    importantInfoShowCardBool[index] =
                        !importantInfoShowCardBool[index];
                  });
                },
                icon: Icon(importantInfoShowCardBool[index]
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_sharp),
              ),
            ),
          ],
        ),
        Visibility(
          visible: importantInfoShowCardBool[index],
          child: const SizedBox(
            height: 10,
          ),
        ),
        Visibility(
          visible: importantInfoShowCardBool[index],
          child: widgetData,
        )
      ],
    ),
  );
}

void showOpenCloseInfoBottomSheet(
    BuildContext context, List<String> weekdayText) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Opening Hours',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Sora',
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            ListView.builder(
              shrinkWrap: true,
              itemCount: weekdayText.length,
              itemBuilder: (context, index) {
                final parts = weekdayText[index].split(': ');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        parts[0],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Sora',
                        ),
                      ),
                      Text(
                        parts.length > 1 ? parts[1] : '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<Map<String, dynamic>> fetchOpenCloseInfo(String placeName) async {
  const FlutterSecureStorage storage = FlutterSecureStorage();
  String? userToken = await storage.read(key: 'userToken');

  final String apiUrl = '$baseurl/get-open-close-info/$placeName/$userToken';
  print('API URL: $apiUrl');
  try {
    final response = await http.get(Uri.parse(apiUrl));
    print('Response: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.statusCode}');
      return {
        "weekday_text": [
          "Not available",
        ]
      };
    }
  } catch (e) {
    print('Error occurred while fetching data: $e');
    return {
      "weekday_text": [
        "Not available",
      ]
    };
  }
}

Widget createList(text) {
  return Row(
    // crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(right: 10),
        width: 3,
        height: 3,
        decoration: const ShapeDecoration(
          color: Color(0xFF484848),
          shape: OvalBorder(),
        ),
      ),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF484848),
            fontSize: 14,
            fontFamily: themeFontFamily2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ],
  );
}

Widget buildTips(Future<List<Widget>> tripTipsFuture) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/tips.svg',
            width: 35,
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'Tips',
            style: TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 20,
              fontFamily: themeFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      FutureBuilder<List<Widget>>(
        future: tripTipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading spinner while waiting for the data
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle any errors that occur during the fetch
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Handle the case where no data is available
            return const Text('No tips available');
          } else {
            // Build the list of widgets with SizedBox spacing
            List<Widget> spacedWidgets = [];
            for (int i = 0; i < snapshot.data!.length; i++) {
              spacedWidgets.add(snapshot.data![i]);
              if (i < snapshot.data!.length - 1) {
                spacedWidgets.add(const SizedBox(height: 10));
              }
            }

            return Column(
              children: spacedWidgets,
            );
          }
        },
      ),

      /*Column(
        children: tripTipsArr [
          buildTipsWidgetCard('india_map.svg',
              'Kochi is located in the southern part of India, in the state of Kerala.'),
          const SizedBox(height: 10),
          buildTipsWidgetCard('language.svg',
              'The official language is Malayalam, but English is widely spoken and understood.'),
          const SizedBox(height: 10),
          buildTipsWidgetCard('rupees.svg',
              "The currency used is the Indian Rupee (INR). Credit cards are accepted in most places, but it's always a good idea to carry some cash."),
          const SizedBox(height: 10),
          buildTipsWidgetCard('rain.svg',
              "Kochi has a tropical monsoon climate. The best time to visit is from October to February when the weather is cooler and drier."),
          const SizedBox(height: 10),
          buildTipsWidgetCard('sim.svg',
              "Get a local SIM card with a data plan to access ride-sharing services like Ola and Uber, and food-ordering apps like Zomato and Swiggy. If unavailable at the airport, you can buy one near your hotel."),
          const SizedBox(height: 10),
          buildTipsWidgetCard('digital_rupee.svg',
              "India is digital-friendly; even local vendors use digital payments."),
          const SizedBox(height: 10),
          buildTipsWidgetCard('refund_card_balance.svg',
              "Ideal for short visits; UPI app issued by a forex company. Unused balance is refunded at the airport when you leave."),
          const SizedBox(height: 40),
        ],  )*/
    ],
  );
}

Widget buildTipsWidgetCard(svg, desc) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 1,
          color: Color(0xFFCDCED7),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(8),
          decoration: ShapeDecoration(
            color: const Color(0xFFECF2FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: SvgPicture.asset('assets/icons/$svg'),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 14,
              fontFamily: themeFontFamily2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildPackingList(packingListShowCardBool, setState) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/list.svg',
            width: 25,
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'Packing List',
            style: TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 20,
              fontFamily: themeFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      Column(
        children: [
          buildHideShowCard(0, packingListShowCardBool, setState,
              'clothing.svg', 'Clothing', 2, [
            'Toothbrush',
            'Toothpaste',
            'Soap or body wash',
            'Shampoo and conditioner (if needed)',
            'Deodorant',
            'Facial cleanser',
            'Moisturizer',
            'Razor and shaving cream (if needed)',
            'Hairbrush or comb',
            'Hand sanitizer'
          ]),
          const SizedBox(
            height: 20,
          ),
          buildHideShowCard(1, packingListShowCardBool, setState,
              'toiletries.svg', 'Toiletries', 2, [
            'Toothbrush',
            'Toothpaste',
            'Soap or body wash',
            'Shampoo and conditioner (if needed)',
            'Deodorant',
            'Facial cleanser',
            'Moisturizer',
            'Razor and shaving cream (if needed)',
            'Hairbrush or comb',
            'Hand sanitizer'
          ]),
          const SizedBox(
            height: 20,
          ),
          buildHideShowCard(2, packingListShowCardBool, setState, 'docs.svg',
              'Travel documents & essentials', 2, [
            'Toothbrush',
            'Toothpaste',
            'Soap or body wash',
            'Shampoo and conditioner (if needed)',
            'Deodorant',
            'Facial cleanser',
            'Moisturizer',
            'Razor and shaving cream (if needed)',
            'Hairbrush or comb',
            'Hand sanitizer'
          ]),
          const SizedBox(
            height: 20,
          ),
          buildHideShowCard(3, packingListShowCardBool, setState,
              'electronic_gadgets.svg', 'Electronics & gadgets', 2, [
            'Toothbrush',
            'Toothpaste',
            'Soap or body wash',
            'Shampoo and conditioner (if needed)',
            'Deodorant',
            'Facial cleanser',
            'Moisturizer',
            'Razor and shaving cream (if needed)',
            'Hairbrush or comb',
            'Hand sanitizer'
          ]),
          const SizedBox(
            height: 20,
          ),
          buildHideShowCard(4, packingListShowCardBool, setState,
              'items_list.svg', 'Miscellaneous items', 2, [
            'Toothbrush',
            'Toothpaste',
            'Soap or body wash',
            'Shampoo and conditioner (if needed)',
            'Deodorant',
            'Facial cleanser',
            'Moisturizer',
            'Razor and shaving cream (if needed)',
            'Hairbrush or comb',
            'Hand sanitizer'
          ]),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
      const SizedBox(
        height: 30,
      ),
    ],
  );
}

// HTTP request to fetch collections
Future<List> fetchCollections() async {
  const FlutterSecureStorage storage = FlutterSecureStorage();
  String? userToken = await storage.read(key: 'userToken');

  final url = Uri.parse('$baseurl/app/collection/all/$userToken');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load collections');
  }
}

Widget buildSavedItineriesBottomSheet(savedItineraryCollectionBool, setState,
    context, collectionNameController, resIterneryId) {
  return FutureBuilder(
    future: fetchCollections(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } /*else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
        return const Center(child: Text('No collections found.'));
      } */

      final collections = snapshot.data as List;
      print('Collections: $collections');

      return Container(
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 87,
              width: double.maxFinite,
              clipBehavior: Clip.antiAlias,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 7,
                    offset: Offset(0, -1),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 6,
                    margin: const EdgeInsets.only(top: 10),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF888888),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 10),
                      const Text(
                        'Saved Itineraries',
                        style: TextStyle(
                          color: Color(0xFF030917),
                          fontSize: 20,
                          fontFamily: themeFontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset('assets/icons/save_outline.svg'),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Collections',
                        style: TextStyle(
                          color: Color(0xFF030917),
                          fontSize: 16,
                          fontFamily: themeFontFamily2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return buildNewCollectionBottomSheet(
                                    collectionNameController, context);
                              });
                        },
                        child: const Text(
                          'Create new collection',
                          style: TextStyle(
                            color: Color(0xFF030917),
                            fontSize: 16,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: SingleChildScrollView(
                      child: Column(
                        children: collections
                            .map((collection) => Column(
                                  children: [
                                    buildItineraryCollections(
                                        collections.indexOf(collection),
                                        'kochi_river.jpeg',
                                        collection['collection_name'],
                                        true,
                                        savedItineraryCollectionBool,
                                        context,
                                        setState,
                                        collection['_id'],
                                        resIterneryId,
                                        parseTripIds(collection[
                                            'trip_ids'])), // Pass the trip_ids set
                                    const SizedBox(height: 16),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Set<String> parseTripIds(dynamic tripIds) {
  if (tripIds is String) {
    // Remove curly braces and split the string into individual IDs
    return tripIds
        .replaceAll(RegExp(r"[{}']"), '') // Remove curly braces and quotes
        .split(',') // Split by commas
        .map((id) => id.trim()) // Trim whitespace
        .toSet(); // Convert to a Set
  } else if (tripIds is Iterable) {
    // If tripIds is already an Iterable, convert it to a Set
    return tripIds
        .map((id) => id.toString().replaceAll("'", "").trim())
        .toSet();
  } else {
    // Return an empty Set if tripIds is null or invalid
    return {};
  }
}

/*
Widget buildSavedItineriesBottomSheet(
    savedItineraryCollectionBool, setState, context, collectionNameController) {
  return Container(
    decoration: const ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
    ),
    child: Column(
      children: [
        Container(
          height: 87,
          width: double.maxFinite,
          clipBehavior: Clip.antiAlias,
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 7,
                offset: Offset(0, -1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 6,
                margin: const EdgeInsets.only(top: 10),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFF888888),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    'Saved Itineraries',
                    style: TextStyle(
                      color: Color(0xFF030917),
                      fontSize: 20,
                      fontFamily: themeFontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  SvgPicture.asset('assets/icons/save_outline.svg'),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          // height: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Collections',
                    style: TextStyle(
                      color: Color(0xFF030917),
                      fontSize: 16,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return buildNewCollectionBottomSheet(
                                collectionNameController, context);
                          });
                    },
                    child: const Text(
                      'New collection',
                      style: TextStyle(
                        color: Color(0xFF030917),
                        fontSize: 16,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                // height: 350,
                height: MediaQuery.of(context).size.height * 0.35,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildItineraryCollections(
                          0,
                          'kochi_river.jpeg',
                          'All Itineraries',
                          true,
                          savedItineraryCollectionBool,
                          context,
                          setState),
                      const SizedBox(
                        height: 15,
                      ),
                 
                      buildItineraryCollections(
                          1,
                          'kochi_river.jpeg',
                          'Kerala',
                          true,
                          savedItineraryCollectionBool,
                          context,
                          setState),
                      const SizedBox(
                        height: 16,
                      ),
                      buildItineraryCollections(
                          2,
                          'kochi_river.jpeg',
                          'Pondicherry',
                          false,
                          savedItineraryCollectionBool,
                          context,
                          setState),
                      const SizedBox(
                        height: 16,
                      ),
                      buildItineraryCollections(
                          3,
                          'kochi_river.jpeg',
                          'Goa',
                          false,
                          savedItineraryCollectionBool,
                          context,
                          setState),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
} */

Widget buildItineraryCollections(
  int index,
  String img,
  String title,
  bool private,
  List<bool> savedItineraryCollectionBool,
  BuildContext context,
  StateSetter setState,
  String collectionDbId,
  String resIterneryId,
  Set<String> tripIds, // Pass the trip_ids set for the collection
) {
  Widget privateWidget = const Text(
    'Private',
    style: TextStyle(
      color: Color(0xFF888888),
      fontSize: 14,
      fontFamily: themeFontFamily2,
      fontWeight: FontWeight.w400,
    ),
  );

  if (!private) {
    privateWidget = SizedBox(
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
                        image: NetworkImage(
                            "https://img.freepik.com/free-vector/travel-tourism-label-with-attractions_1284-52995.jpg"),
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
                      image: AssetImage('assets/icons/add_person.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Check if the resIterneryId exists in the tripIds set
  bool isChecked = tripIds.contains(resIterneryId.toString());
  print('resIterneryId: ${resIterneryId.toString()}, isChecked: $isChecked');
  print('tripIds: $tripIds');

  return SizedBox(
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            image: const DecorationImage(
              image: NetworkImage(
                  "https://img.freepik.com/free-vector/travel-tourism-label-with-attractions_1284-52995.jpg"),
              fit: BoxFit.fill,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF030917),
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            privateWidget,
          ],
        ),
        const Spacer(),
        isChecked
            ? const IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.check_circle,
                  color: Color(0xFF005CE8),
                ),
              )
            : IconButton(
                onPressed: () async {
                  for (var i = 0;
                      i < savedItineraryCollectionBool.length;
                      i++) {
                    savedItineraryCollectionBool[i] = i == index;
                  }

                  print("++++++++++");
                  print(collectionDbId);
                  print(resIterneryId);
                  print("++++++++++");

                  const FlutterSecureStorage storage = FlutterSecureStorage();
                  String? userToken = await storage.read(key: 'userToken');
                  await addIterneryToCollection(
                      collectionDbId, resIterneryId, userToken!);

                  setState(() {});
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF888888),
                ),
              ),
      ],
    ),
  );
}

/*
Widget buildNewCollectionBottomSheet(collectionNameController, context) {
  return Container(
    height: 329,
    clipBehavior: Clip.antiAlias,
    decoration: const ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 87,
          clipBehavior: Clip.antiAlias,
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 7,
                offset: Offset(0, -1),
                spreadRadius: 0,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 6,
                  margin: const EdgeInsets.only(top: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF888888),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'New collection',
                    style: TextStyle(
                      color: Color(0xFF030917),
                      fontSize: 20,
                      fontFamily: themeFontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Collection name',
                style: TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: inputContainerDecoration,
                height: 54,
                child: TextField(
                  enableInteractiveSelection: false,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: themeFontFamily2),
                  keyboardType: TextInputType.text,
                  controller: collectionNameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(20),
                    hintText: 'Enter collection name',
                    hintStyle: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 16,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);

                        //

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
                        decoration: ShapeDecoration(
                          gradient: themeGradientColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Create',
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
      ],
    ),
  );
} */

Widget buildNewCollectionBottomSheet(
    TextEditingController collectionNameController, BuildContext context) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      // Variable to track button state
      bool isCreateEnabled = collectionNameController.text.trim().isNotEmpty;
      final FlutterSecureStorage storage = const FlutterSecureStorage();

      return Container(
        height: 329,
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 87,
              clipBehavior: Clip.antiAlias,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 7,
                    offset: Offset(0, -1),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 6,
                      margin: const EdgeInsets.only(top: 10),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF888888),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'New collection',
                        style: TextStyle(
                          color: Color(0xFF030917),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Collection name',
                    style: TextStyle(
                      color: Color(0xFF030917),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    height: 54,
                    child: TextField(
                      controller: collectionNameController,
                      onChanged: (value) {
                        // Update button state based on TextField value
                        setState(() {
                          isCreateEnabled = value.trim().isNotEmpty;
                        });
                      },
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        hintText: 'Enter collection name',
                        hintStyle: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                          onTap: isCreateEnabled
                              ? () async {
                                  //Navigator.pop(context);
                                  String? userToken =
                                      await storage.read(key: 'userToken');

                                  addCollection(
                                      collectionNameController.text.trim(),
                                      userToken!,
                                      context);
                                  Navigator.pop(context);
                                  final itineraryId =
                                      await storage.read(key: 'itineraryId');
                                  if (context.mounted) {
                                    showModalBottomSheet(
                                      // isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, modalSetState) {
                                            return buildSavedItineriesBottomSheet(
                                              [
                                                false,
                                                false,
                                                false,
                                                false,
                                                false,
                                                false,
                                                false,
                                                false,
                                                false
                                              ],
                                              modalSetState,
                                              context,
                                              collectionNameController,
                                              itineraryId!,
                                            );
                                          },
                                        );
                                      },
                                    );
                                  }
                                }
                              : null,
                          child: Container(
                            height: 56,
                            decoration: ShapeDecoration(
                              gradient: isCreateEnabled
                                  ? themeGradientColor
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey,
                                        Colors.grey[400]!,
                                      ],
                                    ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Create',
                                style: TextStyle(
                                  color: isCreateEnabled
                                      ? Colors.white
                                      : Colors.black38,
                                  fontSize: 16,
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
          ],
        ),
      );
    },
  );
}
