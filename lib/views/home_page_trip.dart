import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:xplorion_ai/widgets/home_page_trip_widgets.dart';
import 'package:http/http.dart' as http;

class HomePageTrip extends StatefulWidget {
  const HomePageTrip({super.key});

  @override
  State<HomePageTrip> createState() => _HomePageTripState();
}

class _HomePageTripState extends State<HomePageTrip> {
  final storage = const FlutterSecureStorage();

  //  'Day 1',
  //  'Day 2',
  //  'Day 3',

  List menuItemNames = [
    //'Local food and drinks',
    //'Best time to visit',
    //'National Holidays',
    //'Important Information',
    //'Tips',
    //'Packing List'
  ];

  List menuBoolList = [
    //true,
    //false,
    //false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  String iterneryTitle = '';
  String noOfDaysDisplay = '';
  String placeDescription = '';
  String localityInPlace = '';
  String resIterneryId = '';
  String mainPlaceImage =
      'https://loading.io/assets/mod/spinner/spinner/lg.gif';
  String weatherInfo = '';
  List weatherInfoData = [];
  var daysDataDisplay;
  bool isLoading = true; // Track the loading state
  bool hasError = false;

  String? selectedPlace;
  late final responseDataS;

  Future<void> generateItinerary() async {
    String? userToken = await storage.read(key: 'userToken');
    String? travelCompanion = await storage.read(key: 'travelCompanion');
    String? budgetTier = await storage.read(key: 'budgetTier');
    String? startDate = await storage.read(key: 'startDate');
    String? endDate = await storage.read(key: 'endDate');
    String? selectedPlace = await storage.read(key: 'selectedPlace');
    //String? itinerarySaved = await storage.read(key: 'itinerarySavedFlag');
    final receivedArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String? itinerarySaved = receivedArgs?['itinerarySavedFlag'].toString();

    //final url = Uri.parse('$baseurl/app/generate-itenary/itinerary/671a86310999b3b00a8acf25/$userToken');

    // Data to be sent in the POST request
    final Map<String, dynamic> requestBody = {
      'cityPlace': selectedPlace, // Replace with your value
      'fromDate': startDate, // Replace with your value
      'toDate': endDate, // Replace with your value
      'travelCompanion': travelCompanion, // Replace with your value
      'budgetType': budgetTier, // Replace with your value
      'token': userToken, // Replace with your token
    };

    if (itinerarySaved != '1') {
      final url = Uri.parse('$baseurl/app/generate-itenary');

      try {
        // Send HTTP POST request
        final response = await http.post(
          url,
          body: requestBody,
        );
        // Handle response
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          var daysData = responseData['itinerary']['days'];
          var place = responseData['place'];
          var budgetType = responseData['budget_type'];
          resIterneryId = responseData['itineraryId'];
          int noOfDays = daysData.length;
          int r = 0;
          daysDataDisplay = daysData;

          setState(() {
            for (int d = noOfDays; d >= 1; d--) {
              menuItemNames.insert(0, "Day $d");

              if (d == 1) {
                menuBoolList.insert(0, true);
              } else {
                menuBoolList.insert(0, false);
              }

              weatherInfoData.add(daysData[r]['weather_info']);
              r++;
            }

            menuItemNames.insert(noOfDays, "Tips");
            menuBoolList.insert(noOfDays, false); // Tips

            menuItemNames.insert((noOfDays + 1), "Best Time To Visit");
            menuBoolList.insert((noOfDays + 1), false); // Best Time To Visit

            menuItemNames.insert((noOfDays + 2), "Holidays");
            menuBoolList.insert((noOfDays + 2), false); // Holidays

            menuItemNames.insert((noOfDays + 3), "Food and Drinks");
            menuBoolList.insert((noOfDays + 3), false); // Food and Drinks

            iterneryTitle = "$place $noOfDays Days - $budgetType";
            noOfDaysDisplay = "$noOfDays Days";
            placeDescription = responseData['about_place'];
            localityInPlace = responseData['locality_in_place'];
            mainPlaceImage = responseData['image_for_main_place'] ??
                'https://coffective.com/wp-content/uploads/2018/06/default-featured-image.png.jpg';
            isLoading = false;
            hasError = false;
          });

          print('Itinerary generated successfully: $responseData');
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
          print(
              'Failed to generate itinerary. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error occurred while generating itinerary: $e');
      }
    }

    if (itinerarySaved == '1') {
      String? itineraryId = receivedArgs?[
          'itineraryId']; //await storage.read(key: 'itineraryId');
      resIterneryId = itineraryId!;

      //print(" |||||||| ");
      //print(resIterneryId);
      //print(" ||||||||| ");

      final responseS = await http
          .get(Uri.parse('$baseurl/itinerary/$itineraryId/$userToken'));

      if (responseS.statusCode == 200) {
        responseDataS = json.decode(responseS.body);
        var daysData = responseDataS[0]['itinerary']['itinerary']['days'];
        var place = responseDataS[0]['itinerary']['place'];
        var budgetType = responseDataS[0]['itinerary']['budget_type'];

        int noOfDays = daysData.length;
        int r = 0;
        daysDataDisplay = daysData;

        setState(() {
          for (int d = noOfDays; d >= 1; d--) {
            menuItemNames.insert(0, "Day $d");

            if (d == 1) {
              menuBoolList.insert(0, true);
            } else {
              menuBoolList.insert(0, false);
            }

            weatherInfoData.add(daysData[r]['weather_info']);
            r++;
          }

          menuItemNames.insert(noOfDays, "Tips");
          menuBoolList.insert(noOfDays, false); // Tips

          menuItemNames.insert((noOfDays + 1), "Best Time To Visit");
          menuBoolList.insert((noOfDays + 1), false); // Best Time To Visit

          menuItemNames.insert((noOfDays + 2), "Holidays");
          menuBoolList.insert((noOfDays + 2), false); // Holidays

          menuItemNames.insert((noOfDays + 3), "Food and Drinks");
          menuBoolList.insert((noOfDays + 3), false); // Food and Drinks

          iterneryTitle = "$place $noOfDays Days - $budgetType";
          noOfDaysDisplay = "$noOfDays Days";
          placeDescription = responseDataS[0]['itinerary']['about_place'];
          localityInPlace = responseDataS[0]['itinerary']['locality_in_place'];
          mainPlaceImage = responseDataS[0]['itinerary']
                  ['image_for_main_place'] ??
              'https://coffective.com/wp-content/uploads/2018/06/default-featured-image.png.jpg';
          isLoading = false;
        });
      }
    }
  }

  MenuController menuController = MenuController();
  TextEditingController collectionNameController = TextEditingController();
  bool menuOpen = false;
  Widget tripItineraryWidget = Container();

  List menuItemIcons = [
    'board_flight.svg',
    'board_flight.svg',
    'board_flight.svg',
    'food_bowl.svg',
    'clock_outline.svg',
    'holiday.svg',
    'imp_info.svg',
    'tips.svg',
    'list.svg'
  ];

  List<Widget> doseImageSliders = [];
  List<Widget> secondImageSliders = [];
  List<Widget> thirdImageSliders = [];
  List<Widget> fourthImageSliders = [];

  List itineraryImages = []; // 'dose.jpeg', 'dose.jpeg
  List secondImages = ['lal_bagh.jpeg', 'lal_bagh.jpeg'];
  List thirdImages = ['bengaluru_palace.jpeg'];
  List fourthImages = ['ub_city.jpeg', 'dose.jpeg'];

  List<int> day1SliderCurrentPos = [0, 0, 0, 0];
  List<bool> day1SliderShowActivity = [false, true, true, false];
  List<bool> importantInfoShowCardBool = [false, true, true, false, false];
  List<bool> packingListShowCardBool = [false, true, true, false, false];
  List<bool> transpotationModeBool = [true, false, false];
  List<bool> savedItineraryCollectionBool = [
    false,
    false,
    false,
    false,
    false,
    false
  ];

  Map dayActivityDataArray = {};
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<String> loadingTexts = [
    "Pack your bags and your patience – we're crafting your dream trip!",
    "Our AI is busy mapping out your adventure... because getting lost is overrated!",
    "Good things take time, and great itineraries take a few seconds",
    "Hold on tight! We're adding a sprinkle of wanderlust to your plans.",
    "Your itinerary is baking in our travel oven – almost ready to serve!",
  ];

  // void startAutoCarousel() {
  //   Timer.periodic(Duration(seconds: 2), (timer) {
  //     if (_pageController.hasClients) {
  //       setState(() {
  //         _currentIndex = (_currentIndex + 1) % loadingTexts.length;
  //       });
  //       _pageController.animateToPage(
  //         _currentIndex,
  //         duration: Duration(milliseconds: 1000),
  //         curve: Curves.easeInOut,
  //       );
  //     }
  //   });
  // }
  void startAutoCarousel() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        if (_currentIndex < loadingTexts.length - 1) {
          // Normal transition to next item
          _currentIndex++;
          _pageController.animateToPage(
            _currentIndex,
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } else {
          // Instantly reset to the first item
          _currentIndex = 0;
          _pageController.jumpToPage(_currentIndex);
        }
      }
    });
  }

  Future<void> redoItinerary(dayNo) async {
    String? userToken = await storage.read(key: 'userToken');

    // Define the API endpoint
    final String apiUrl =
        '$baseurl/day-redo-itinerary/$dayNo/$resIterneryId/$userToken';

    try {
      // Make the Get request
      final response = await http.get(Uri.parse(apiUrl));
      var data = json.decode(response.body);

      if (data != null && data is Map<String, dynamic>) {
        print(
            '+++++++++++++++++++++++++++++++++++++redoItinerary++++++++++++++++++++++++++++++++++++++++++++++++++');
        print(data);
        print(
            '+++++++++++++++++++++++++++++++++++++redoItinerary++++++++++++++++++++++++++++++++++++++++++++++++++');
        setState(() {
          // Find the index of the matching day_no
          int index = daysDataDisplay
              .indexWhere((day) => day["day_no"] == data["day_no"]);

          if (index != -1) {
            // Replace the existing object with the new data
            daysDataDisplay[index] = data;
          }
          // else {
          //   // If day_no is not found, add the new data
          //   daysDataDisplay.add(data);
          // }
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      // show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error Loading Data Please Try Again')),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
    generateItinerary();
    startAutoCarousel();
  }

  void _getData() {
    /*itineraryImages
        .map(
          (item) => doseImageSliders.add(
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: NetworkImage(item),
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
          ),
        )
        .toList();  */

    secondImages
        .map(
          (item) => secondImageSliders.add(
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/$item"),
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
          ),
        )
        .toList();

    thirdImages
        .map(
          (item) => thirdImageSliders.add(
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/$item"),
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
          ),
        )
        .toList();

    fourthImages
        .map(
          (item) => fourthImageSliders.add(
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/$item"),
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
          ),
        )
        .toList();

    dayActivityDataArray = {
      'data': [
        [
          'car',
          '7:00 AM - 8:00 AM: Breakfast at MTR',
          doseImageSliders,
          0,
          'Mavalli Tiffin Room (MTR)',
          true
        ],
        [
          'bus',
          '8:30 AM - 10:00 AM: Visit Lalbagh Botanical Garden',
          secondImageSliders,
          1,
          'Lalbagh Botanical Garden',
          true
        ],
        [
          'walk',
          '10:30 AM - 12:00 PM: Bangalore Palace',
          thirdImageSliders,
          2,
          'Bangalore Palace',
          false
        ],
        [
          'car',
          '12:30 PM - 1:30 PM: Lunch at Nagarjuna',
          fourthImageSliders,
          1,
          'UB City',
          true
        ],
      ],
      'sliderPos': day1SliderCurrentPos,
      'showActivity': day1SliderShowActivity
    };
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tripItineraryWidget = changeTripItineraryMenuView();

    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GIF Image
              Image.asset(
                'assets/images/iternery_loading.gif',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 10),

              // Indeterminate Progress Bar
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: const LinearProgressIndicator(),
              ),
              const SizedBox(height: 160),

              // Auto-scrolling Carousel Text
              SizedBox(
                height: 60,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: loadingTexts.length,
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevent manual scrolling
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        loadingTexts[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true, // Enables multi-line text wrapping
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    //CircularProgressIndicator()

    if (hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20), // Adds padding on both sides
            child: Column(
              mainAxisSize: MainAxisSize.min, // Centers content vertically
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/itinerary_failure.svg',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your Itinerary is stuck in traffic 🚦',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Don’t worry, we’ve called for backup!\nReload to clear the road',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, // Makes button full width
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0099FF), Color(0xFF54AB6A)],
                      ),
                      borderRadius: BorderRadius.circular(50), // Fully rounded
                    ),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          hasError = false;
                        });
                        generateItinerary();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(50), // Fully rounded
                        ),
                        backgroundColor: Colors.transparent, // To show gradient
                      ),
                      child: const Text('Reload',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          ListView(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Stack(
                      children: [
                        Image.network(
                          mainPlaceImage,
                          width: double.maxFinite,
                          height: double.maxFinite,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: double.maxFinite,
                                  height: double.maxFinite,
                                  color: Colors.grey[300],
                                ),
                              );
                            }
                          },
                        ),
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.5,
                            child: Container(
                              color: const Color(0xFF000000),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    height: MediaQuery.of(context).size.height * 0.63,
                    child: Column(
                      children: [
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    // Navigator.of(context).pushNamed('/home_page');
                                    //Navigator.of(context).pushNamedAndRemoveUntil('/home_page', (route) => false);
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    padding: const EdgeInsets.all(0),
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.home_outlined,
                                      // size: 20,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                //
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      // isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, modalSetState) {
                                            return buildSavedItineriesBottomSheet(
                                                savedItineraryCollectionBool,
                                                modalSetState,
                                                context,
                                                collectionNameController,
                                                resIterneryId);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    padding: const EdgeInsets.all(0),
                                    decoration: const ShapeDecoration(
                                        color: Colors.white, shape: OvalBorder()
                                        //  RoundedRectangleBorder(
                                        //   borderRadius: BorderRadius.circular(50),
                                        // ),
                                        ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                          'assets/icons/save_outline.svg'),
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 20,
                                ),

                                InkWell(
                                  onTap: () {
                                    print(" /////////// ");
                                    print(responseDataS);
                                    print(" //////////// ");

                                    Navigator.of(context).pushNamed(
                                        '/explore_road_map',
                                        arguments: {
                                          'itineraryDataMaps': responseDataS
                                        });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    padding: const EdgeInsets.all(10),
                                    decoration: const ShapeDecoration(
                                        color: Colors.white,
                                        shape: OvalBorder()),
                                    child: SvgPicture.asset(
                                      'assets/icons/map_location.svg',
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 20,
                                ),

                                InkWell(
                                  onTap: () {
                                    Navigator.of(context)
                                        .pushNamed('/trip_settings');
                                  },
                                  child: Container(
                                      width: 40,
                                      height: 40,
                                      // padding: const EdgeInsets.all(10),
                                      decoration: const ShapeDecoration(
                                        color: Colors.white,
                                        shape: OvalBorder(),
                                      ),
                                      child: const Icon(Icons.settings_outlined)
                                      //  SvgPicture.asset('assets/icons/map_location.svg',)
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              iterneryTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontFamily: 'Sora',
                                fontWeight: FontWeight.w700,
                                // height: 0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage(
                                          "assets/images/profile_photo.jpeg"),
                                      fit: BoxFit.fill,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          width: 2, color: Colors.white),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                child: Container(
                                  width: 92,
                                  height: 35,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFECF2FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(33),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.share_outlined),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        'Share',
                                        style: TextStyle(
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
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                  'assets/icons/calendar_outline.svg'),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                noOfDaysDisplay,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: themeFontFamily2,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              // Icon(
                              //   Icons.cloudy_snowing,
                              //   color: Colors.white,
                              // ),
                              SvgPicture.asset(
                                'assets/icons/weather_new.svg',
                                // width: 14,
                                // height: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              const Text(
                                'H: 35°, L: 21°, 20% chances of rainfall',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: themeFontFamily2,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                  'assets/icons/location_outline.svg'),
                              const SizedBox(
                                width: 12,
                              ),
                              Text(
                                localityInPlace,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: themeFontFamily2,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Row(
                            // textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                child: SvgPicture.asset(
                                    'assets/icons/comments.svg'),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                // flex: 12,
                                child: Text(
                                  placeDescription,
                                  // textAlign: TextAlign,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: themeFontFamily2,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: menuItemNames.length,
                        itemBuilder: ((context, index) {
                          return buildMenuItemsCard(index, menuItemNames[index],
                              menuBoolList, setState);
                        }),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    tripItineraryWidget
                  ],
                ),
              ),
            ],
          ),
          if (menuOpen)
            const ModalBarrier(
              color: Colors.black87, // Semi-transparent black background
              dismissible: false, // Make it undismissible by clicking
            ),
          Positioned(
            bottom: 20,
            right: 0,
            child: MenuAnchor(
              onClose: () {
                menuOpen = false;

                setState(() {});
              },
              onOpen: () {
                menuOpen = true;

                setState(() {});
              },
              consumeOutsideTap: false,
              // anchorTapClosesMenu: true,
              style: MenuStyle(
                backgroundColor: getMaterialStateColor(),
                shadowColor: getMaterialStateColor(),
                surfaceTintColor: getMaterialStateColor(),
                shape: getMaterialStateShape(),
              ),
              alignmentOffset: const Offset(-140, 20),
              controller: menuController,
              builder: (context, controller, child) {
                return GestureDetector(
                  onTap: () {
                    if (menuController.isOpen) {
                      menuController.close();
                    } else {
                      menuController.open();
                    }
                    setState(() {});
                  },
                  child: Container(
                    width: 85,
                    height: 38,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: const ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.00, 0.06),
                        end: Alignment(1, -0.06),
                        colors: [Color(0xFF54AB6A), Color(0xFF0099FF)],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        menuController.isOpen
                            ? SvgPicture.asset('assets/icons/close.svg')
                            : SvgPicture.asset('assets/icons/menu.svg'),
                        const SizedBox(width: 6),
                        Text(
                          menuController.isOpen ? 'Close' : 'Menu',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              menuChildren: List<MenuItemButton>.generate(
                menuItemNames.length,
                (int index) => MenuItemButton(
                  // style: ButtonStyle(

                  // ),
                  onPressed: () => setState(() {
                    for (var i = 0; i < menuBoolList.length; i++) {
                      menuBoolList[i] = i == index;
                    }
                    menuController.close();
                  }),
                  child: Container(
                    // color: Colors.white,
                    width: 185,
                    height: 22,
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: SvgPicture.asset(
                              'assets/icons/${menuItemIcons[0]}',
                              width: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          menuItemNames[index],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w400,
                            // height: 0.11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {},
      //   icon: const Icon(Icons.edit),
      //   label: const Text('Edit'),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }

  List holiday = [];

  var tripTipsArr;
  var bestTimeToVisitArr;
  var foodDrinksArr;
  Widget changeTripItineraryMenuView() {
    if (daysDataDisplay == null || isLoading) {
      // Display a loading indicator if data is not yet available iternery_loading.gif
      return Center(
          child: Image.asset(
        'assets/images/iternery_loading.gif',
        width: 200,
        height: 200,
        fit: BoxFit.cover, // Set fit as per your requirement (optional)
      )); // CircularProgressIndicator()
    }

    var menuIndex = 0;
    var weatherInfoToSend = '';
    for (var i = 0; i < menuBoolList.length; i++) {
      if (menuBoolList[i]) {
        menuIndex = i;
      }
    }

    doseImageSliders.clear();
    int dataLen = daysDataDisplay.length;
    int day = menuIndex + 1;

    if (day > dataLen) {
      if (day == (dataLen + 1)) {
        if (tripTipsArr == null || tripTipsArr == '') {
          tripTipsArr = getTipsData(); // Assign value if null
        } else {
          tripTipsArr = tripTipsArr;
        }
        return buildTips(tripTipsArr);
      }

      if (day == (dataLen + 2)) {
        if (bestTimeToVisitArr == null || bestTimeToVisitArr == '') {
          bestTimeToVisitArr = getBestTimeToVisit();
        } else {
          bestTimeToVisitArr = bestTimeToVisitArr;
        }

        return buildBestTimeToVisit(bestTimeToVisitArr);
      }

      if (day == (dataLen + 3)) {
        return buildNationalHolidays(holiday);
      }

      if (day == (dataLen + 4)) {
        if (foodDrinksArr == null || foodDrinksArr == '') {
          foodDrinksArr = getFoodAndDrink();
        } else {
          foodDrinksArr = foodDrinksArr;
        }

        return buildLocalFoodAndDrinks(context, foodDrinksArr);
      }
    }

    weatherInfoToSend = weatherInfoData[menuIndex];

    List activities = [];
    for (int j = 0; j < dataLen; j++) {
      var activitiesData = daysDataDisplay[j]['activities'];
      int activitiesDataLen = activitiesData.length;
      if (day.toString() == daysDataDisplay[j]['day_no']) {
        for (int k = 0; k < activitiesDataLen; k++) {
          // Create a new sublist for each activity inside the inner loop
          List activitiesSubList = [];

          doseImageSliders.add(
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: NetworkImage(activitiesData[k]['place_image_url'] ??
                      "https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png"),
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
          );
          //itineraryImages.add(activitiesData[k]['place_image_url']);

          // Add elements to the sublist
          activitiesSubList.add('car');
          activitiesSubList.add(activitiesData[k]['time'] +
              ' : ' +
              activitiesData[k]['activity']);
          activitiesSubList.add(doseImageSliders);
          activitiesSubList.add(j);
          activitiesSubList
              .add(activitiesData[k]['locality_area_place_business']);
          activitiesSubList.add(true);
          activitiesSubList.add(activitiesData[k]['ratings']);
          activitiesSubList
              .add(activitiesData[k]['one_line_description_about_place']);
          activitiesSubList.add(activitiesData[k]['formatted_address']);
          activitiesSubList.add(activitiesData[k]['lat']);
          activitiesSubList.add(activitiesData[k]['long']);
          activitiesSubList.add(activitiesData[k]['distance_km']);
          activitiesSubList.add(activitiesData[k]['duration_min']);
          activitiesSubList.add(activitiesData[k]['two_locations_cordinates']);
          activitiesSubList.add(activitiesData[k]['price_level_description']);
          activitiesSubList.add(activitiesData[k]['currently_open']);

          // Add the sublist to the main activities list
          activities.add(activitiesSubList);

          doseImageSliders = [];
        }
      }
    }

    Map iterneryData = {
      'data': activities,
      'sliderPos': day1SliderCurrentPos,
      'showActivity': day1SliderShowActivity
    };

    menuIndex = menuIndex + 1;
    fetchNationalHolidays();

    return DayItineraryView(
        weatherSvg: 'thunder_cloud.svg',
        dayNum: '$menuIndex',
        setState: setState,
        dayActivityDataArray: iterneryData,
        contextP: context,
        transpotationModeBool: transpotationModeBool,
        weatherText: weatherInfoToSend,
        redoItinerary: redoItinerary); // dayActivityDataArray

    /*switch (menuIndex) {
      /*case 0:
        return dayItineraryView('thunder_cloud.svg', '1', setState,
            dayActivityDataArray, context, transpotationModeBool);

      case 1:
        return dayItineraryView('sun_clouds.svg', '2', setState,
            dayActivityDataArray, context, transpotationModeBool);

      case 2:
        return dayItineraryView('sun_clouds.svg', '3', setState,
            dayActivityDataArray, context, transpotationModeBool); */

      case 3:
        return buildLocalFoodAndDrinks(context);

      case 4:
        return buildBestTimeToVisit();

      case 5:
        return buildNationalHolidays(holiday);

      case 6:
        return buildImportantInformation(importantInfoShowCardBool, setState);

      case 7:
        return buildTips();

      case 8:
        return buildPackingList(packingListShowCardBool, setState);

      default:
        return dayItineraryView('thunder_cloud.svg', '1', setState,
            dayActivityDataArray, context, transpotationModeBool,weatherInfo);
    } */
  }

  Future<List<Widget>> getTipsData() async {
    // Replace this with your actual base URL
    const storage = FlutterSecureStorage();

    try {
      // Read the user token and selected place from secure storage
      String? userToken = await storage.read(key: 'userToken');
      String? selectedPlace = await storage.read(key: 'selectedPlace');

      //print("$userToken ===== $selectedPlace");

      // Ensure the values are not null
      if (userToken == null || selectedPlace == null) {
        print("User token or selected place is null");
        return [];
      }

      // Perform GET request
      final response = await http
          .get(Uri.parse('$baseurl/tips-for-place/$selectedPlace/$userToken'));

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON response
        List<dynamic> tipsArray = json.decode(response.body);

        List<Widget> tips = tipsArray.map((item) {
          String tipText = item["tip"] as String;
          return buildTipsWidgetCard('tips.svg', tipText);
        }).toList();

        return tips;
      } else {
        print("Failed to load tips. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("An error occurred: $e");
      return [];
    }
  }

  // Best Time To Visit
  Future<List<Widget>> getBestTimeToVisit() async {
    // Replace this with your actual base URL
    const storage = FlutterSecureStorage();

    try {
      // Read the user token and selected place from secure storage
      String? userToken = await storage.read(key: 'userToken');
      String? selectedPlace = await storage.read(key: 'selectedPlace');

      //print("$userToken ===== $selectedPlace");

      // Ensure the values are not null
      if (userToken == null || selectedPlace == null) {
        print("User token or selected place is null");
        return [];
      }

      // Perform GET request
      final response = await http.get(Uri.parse(
          '$baseurl/best-time-to-visit-place/$selectedPlace/$userToken'));

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON response
        List<dynamic> tipsArray = json.decode(response.body);

        List<Widget> tips = tipsArray.map((item) {
          String tipText = item["tip"] as String;
          return buildTipsWidgetCard('tips.svg', tipText);
        }).toList();

        return tips;
      } else {
        print("Failed to load tips. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("An error occurred: $e");
      return [];
    }
  }

  // National Holidays
  fetchNationalHolidays() async {
    if (holiday.isEmpty) {
      // Read the user token and selected place from secure storage
      String? userToken = await storage.read(key: 'userToken');
      String? selectedPlace = await storage.read(key: 'selectedPlace');
      final url =
          Uri.parse('$baseurl/national-holidays/$selectedPlace/$userToken');

      // Perform the GET request
      final response = await http.get(url);

      // Check the response status
      if (response.statusCode == 200) {
        // Decode and return the JSON response as a list of maps
        var nationalHolidaysData = json.decode(response.body);
        var nationalHolidaysDataLen = nationalHolidaysData.length;

        for (int i = 0; i < nationalHolidaysDataLen; i++) {
          holiday.add(nationalHolidaysData[i]);
        }

        return 1;
      } else {
        // Handle errors (throw exception or return an empty list)
        throw Exception(
            'Failed to load national holidays: ${response.statusCode}');
      }
    }
    // return 1;
  }

  // Food and Drinks
  Future<List<Widget>> getFoodAndDrink() async {
    // Replace this with your actual base URL
    const storage = FlutterSecureStorage();

    try {
      // Read the user token and selected place from secure storage
      String? userToken = await storage.read(key: 'userToken');
      String? selectedPlace = await storage.read(key: 'selectedPlace');

      // Ensure the values are not null
      if (userToken == null || selectedPlace == null) {
        print("User token or selected place is null");
        return [];
      }

      // Perform GET request
      final response = await http
          .get(Uri.parse('$baseurl/food-drinks/$selectedPlace/$userToken'));

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON response
        List<dynamic> FoodAndDrinksArray = json.decode(response.body);

        List<Widget> foodDrinksArr = FoodAndDrinksArray.map((item) {
          String foodDrinkDescription =
              item["food_drink_description"] as String;
          String foodDrinkName = item["food_drink_name"] as String;
          String foodDrinkImage = item["food_drink_image"] as String;
          String foodType = item["food_drink_type"] as String;

          String foodTypeString = "";
          if (foodType == "Veg") {
            foodTypeString = 'veg';
          } else {
            foodTypeString = 'non-veg';
          }

          return buildLocalFoodAndDrinksCard(foodDrinkImage, foodTypeString,
              foodDrinkName, foodDrinkDescription, context);
        }).toList();

        return foodDrinksArr;
      } else {
        print("Failed to load tips. Status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("An error occurred: $e");
      return [];
    }
  }
}
