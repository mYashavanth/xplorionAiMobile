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
import 'package:xplorion_ai/views/trip_settings.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:xplorion_ai/widgets/home_page_trip_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class HomePageTrip extends StatefulWidget {
  const HomePageTrip({super.key});

  @override
  State<HomePageTrip> createState() => _HomePageTripState();
}

class _HomePageTripState extends State<HomePageTrip> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey tripItineraryKey = GlobalKey();
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
  ];

  String iterneryTitle = '';
  String noOfDaysDisplay = '';
  String placeDescription = '';
  String localityInPlace = '';
  String resIterneryId = '';
  List markAsVisitedList = [];
  String mainPlaceImage =
      'https://loading.io/assets/mod/spinner/spinner/lg.gif';
  String weatherInfo = '';
  List weatherInfoData = [];
  var daysDataDisplay;
  bool isLoading = true; // Track the loading state
  bool hasError = false;

  String? selectedPlace;
  late final responseDataS;
  late final responseData;
  String? itinerarySavedFlag;

  int getDaysBetween(String fromDateStr, String toDateStr) {
    DateTime parseDate(String dateStr, [int? baseYear]) {
      // Format: "9 Apr"
      final shortFormat = RegExp(r'^(\d{1,2}) (\w{3})$');
      final match = shortFormat.firstMatch(dateStr);
      if (match != null) {
        int day = int.parse(match.group(1)!);
        String monthAbbr = match.group(2)!;
        int year = baseYear ?? DateTime.now().year;

        Map<String, int> monthMap = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12,
        };

        int? month = monthMap[monthAbbr];
        if (month == null) {
          throw FormatException("Invalid month abbreviation: $monthAbbr");
        }

        return DateTime(year, month, day);
      }

      // Format: "2025-02-23"
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        throw FormatException("Unrecognized date format: $dateStr");
      }
    }

    // Try parsing both dates
    bool isShortFormat(String str) => RegExp(r'^\d{1,2} \w{3}$').hasMatch(str);

    DateTime fromDate;
    DateTime toDate;

    if (isShortFormat(fromDateStr) && isShortFormat(toDateStr)) {
      DateTime now = DateTime.now();
      fromDate = parseDate(fromDateStr, now.year);
      toDate = parseDate(toDateStr, now.year);

      if (toDate.isBefore(fromDate)) {
        // Assume toDate is in the next year
        toDate = parseDate(toDateStr, now.year + 1);
      }
    } else {
      fromDate = parseDate(fromDateStr);
      toDate = parseDate(toDateStr);
    }

    return toDate.difference(fromDate).inDays + 1;
  }

  Future<void> generateItineraryForDay({
    required int dayNo,
    bool updateLoadingState = true, // Optional parameter to control isLoading
  }) async {
    // Return early if dayNo is less than 2 (no call needed)
    if (dayNo < 2) {
      print('Skipping day $dayNo as it is less than 2.');
      return;
    }

    print(daysDataDisplay
        .any((day) => day != null && day["day_no"] == dayNo.toString()));
    if (daysDataDisplay
        .any((day) => day != null && day["day_no"] == dayNo.toString())) {
      print('Skipping day $dayNo as it is already generated.');
      return;
    }

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'userToken');
    final fromDate = await storage.read(key: 'startDate');
    final toDate = await storage.read(key: 'endDate');

    if (token == null) {
      print('User token not found.');
      return;
    }

    final url = Uri.parse('$baseurl/app/generate-itenary/for-day');

    final body = {
      'token': token,
      'itineraryId': resIterneryId,
      'dayNo': dayNo.toString(),
      'fromDate': fromDate,
      'toDate': toDate,
    };

    try {
      if (updateLoadingState) {
        setState(() {
          isLoading = true;
        });
      }

      final response = await http.post(
        url,
        body: body,
      );
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        weatherInfoData[dayNo - 1] = data['weather_info'];
        setState(() {
          if (daysDataDisplay.length < dayNo) {
            daysDataDisplay.length = dayNo; // Extend the list if necessary
          }
          daysDataDisplay[dayNo - 1] = data;
        });
        print('Itinerary for day $dayNo generated successfully.');
      } else {
        print('Failed to generate itinerary for day $dayNo: ${response.body}');
      }
    } catch (e) {
      print('Error generating itinerary for day $dayNo: $e');
    } finally {
      if (updateLoadingState) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> generateItineraryForAllDays(int totalDays) async {
    for (int dayNo = 2; dayNo <= totalDays; dayNo++) {
      print('Generating itinerary for day $dayNo...');
      bool success = false;

      while (!success) {
        try {
          // Call the generateItineraryForDay function
          await generateItineraryForDay(
              dayNo: dayNo, updateLoadingState: false);
          success = true; // Mark as success if no exception occurs
          print('Successfully generated itinerary for day $dayNo');
        } catch (e) {
          // Log the error and retry
          print('Error generating itinerary for day $dayNo: $e');
          await Future.delayed(
              const Duration(seconds: 1)); // Add a delay before retrying
        }
      }
    }
  }

  List<dynamic> fillMissingDays(List<dynamic> daysData, {int totalDays = 7}) {
    // Create a map of day numbers to their data
    final dayMap = {for (var day in daysData) int.parse(day['day_no']): day};

    // Initialize the result list
    final filledDays = List<dynamic>.filled(totalDays, null);

    // Fill in the available days
    for (int dayNum = 1; dayNum <= totalDays; dayNum++) {
      if (dayMap.containsKey(dayNum)) {
        filledDays[dayNum - 1] = dayMap[dayNum];
      }
    }

    return filledDays;
  }

  void _scrollToTripItinerary() {
    // Get the RenderObject of the tripItineraryWidget
    final RenderBox? renderBox =
        tripItineraryKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      // Get the position of the widget relative to the ListView
      final double offset = renderBox.localToGlobal(Offset.zero).dy +
          _scrollController.offset -
          kToolbarHeight; // Adjust for AppBar height if necessary

      // Smoothly scroll to the position
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  String fromDate = '';
  String toDate = '';

  Future<void> generateItinerary() async {
    String? userToken = await storage.read(key: 'userToken');
    String? travelCompanion = await storage.read(key: 'travelCompanion');
    String? budgetTier = await storage.read(key: 'budgetTier');
    String? startDate = await storage.read(key: 'startDate');
    String? endDate = await storage.read(key: 'endDate');
    String? selectedPlace = await storage.read(key: 'selectedPlace');
    if (startDate != null && endDate != null) {
      fromDate = startDate;
      toDate = endDate;
    } else {
      fromDate = '';
      toDate = '';
      print("Start date or end date is null");
    }
    //String? itinerarySaved = await storage.read(key: 'itinerarySavedFlag');
    final receivedArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    String? itinerarySaved = receivedArgs?['itinerarySavedFlag'].toString();
    print(
        '+++++++++++++++++++++++++++++++++itinerarySaved+++++++++++++++++++++++++++++++++++');
    print(itinerarySaved);
    print(
        '+++++++++++++++++++++++++++++++++itinerarySaved+++++++++++++++++++++++++++++++++++');
    itinerarySavedFlag = itinerarySaved;

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
      // Timeout mechanism
      // Timer timeoutTimer = Timer(const Duration(minutes: 1), () {
      //   setState(() {
      //     isLoading = false;
      //     hasError = true; // Set error state if timeout occurs
      //   });
      // });
      final url = Uri.parse('$baseurl/app/generate-itenary');
      print(requestBody);
      try {
        // Send HTTP POST request
        final response = await http.post(
          url,
          body: requestBody,
        );
        // Handle response
        print('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
        print('Response status: ${response.body}');
        print('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

        if (response.statusCode == 200) {
          responseData = json.decode(response.body);

          var daysData = responseData['itinerary']['days'];
          print('daysData $daysData');
          setDay1SliderShowActivity(daysData);
          var place = responseData['place'];
          var budgetType = responseData['budget_type'];
          resIterneryId = responseData['itineraryId'];
          await storage.write(key: 'itineraryId', value: resIterneryId);
          int noOfDays;
          if (startDate != null && endDate != null) {
            noOfDays = getDaysBetween(startDate, endDate);
            print('noOfDays $noOfDays, startDate $startDate, endDate $endDate');
          } else {
            throw Exception("Start date or end date is null");
          }
          // int r = 0;
          daysDataDisplay = daysData;

          setState(() {
            for (int d = noOfDays; d >= 1; d--) {
              menuItemNames.insert(0, "Day $d");

              if (d == 1) {
                menuBoolList.insert(0, true);
              } else {
                menuBoolList.insert(0, false);
              }

              // if (r < daysData.length && daysData[r] != null) {
              //   weatherInfoData.add(daysData[r]['weather_info']);
              //   print('r $r, d $d, daysData[r] ${daysData[r]}');
              // }
              // r++;
              if (daysData != null && d - 1 >= 0 && d - 1 < daysData.length) {
                weatherInfoData.insert(0, daysData[d - 1]['weather_info']);
              } else {
                weatherInfoData.insert(0, 'No data available');
              }
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
            // if responseData['locality_in_place'] this is a list I want to handle that case to, just save the firlst element of the list
            if (responseData['locality_in_place'] is List) {
              localityInPlace = responseData['locality_in_place'][0];
            } else {
              localityInPlace = responseData['locality_in_place'];
            }
            mainPlaceImage = responseData['image_for_main_place'] ??
                'https://coffective.com/wp-content/uploads/2018/06/default-featured-image.png.jpg';
            isLoading = false;
            hasError = false;
          });

          print('Itinerary generated successfully: $responseData');
          generateItineraryForAllDays(noOfDays);
        } else {
          // timeoutTimer.cancel();
          setState(() {
            hasError = true;
            isLoading = false;
          });
          print(
              'Failed to generate itinerary. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error occurred while generating itinerary: $e');
        // timeoutTimer.cancel();
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }

    if (itinerarySaved == '1') {
      String? itineraryId = receivedArgs?[
          'itineraryId']; //await storage.read(key: 'itineraryId');
      resIterneryId = itineraryId!;
      await storage.write(key: 'itineraryId', value: resIterneryId);
      //print(" |||||||| ");
      //print(resIterneryId);
      //print(" ||||||||| ");

      final responseS = await http
          .get(Uri.parse('$baseurl/itinerary/$itineraryId/$userToken'));
      print('$baseurl/itinerary/$itineraryId/$userToken');

      if (responseS.statusCode == 200) {
        responseDataS = json.decode(responseS.body);
        var daysData = responseDataS[0]['itinerary']['itinerary']['days'];
        print('daysData $daysData');
        setDay1SliderShowActivity(daysData);
        var place = responseDataS[0]['itinerary']['place'];
        var budgetType = responseDataS[0]['itinerary']['budget_type'];

        int noOfDays = responseDataS[0]['itinerary']['no_of_days'];
        // int r = 0;
        daysDataDisplay = fillMissingDays(daysData, totalDays: noOfDays);

        setState(() {
          for (int d = noOfDays; d >= 1; d--) {
            menuItemNames.insert(0, "Day $d");

            if (d == 1) {
              menuBoolList.insert(0, true);
            } else {
              menuBoolList.insert(0, false);
            }

            if (daysData != null && d - 1 >= 0 && d - 1 < daysData.length) {
              weatherInfoData.insert(0, daysData[d - 1]['weather_info']);
            } else {
              weatherInfoData.insert(0, 'No data available');
            }
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
          // if responseData['locality_in_place'] this is a list I want to handle that case to, just save the firlst element of the list
          if (responseDataS[0]['itinerary']['locality_in_place'] is List) {
            localityInPlace =
                responseDataS[0]['itinerary']['locality_in_place'][0];
          } else {
            localityInPlace =
                responseDataS[0]['itinerary']['locality_in_place'];
          }
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
  List<bool> day1SliderShowActivity = [];

  void setDay1SliderShowActivity(daysData) {
    if (daysData.isNotEmpty) {
      var activities = daysData[0]['activities'];
      day1SliderShowActivity = List<bool>.filled(activities.length, true);
    }
  }

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
    Timer.periodic(Duration(seconds: 10), (timer) {
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

  Future<void> redoIndividualItinerary(dayNo, index) async {
    String? userToken = await storage.read(key: 'userToken');

    // Define the API endpoint
    final String apiUrl =
        '$baseurl/activity-redo-itinerary/$dayNo/$index/$resIterneryId/$userToken';

    try {
      // Make the Get request
      final response = await http.get(Uri.parse(apiUrl));
      var data = json.decode(response.body);

      print(
          '+++++++++++++++++++++++++++++++++++++redoIndvidualItinerary++++++++++++++++++++++++++++++++++++++++++++++++++');
      print(apiUrl);
      print(
          '+++++++++++++++++++++++++++++++++++++redoIndvidualItinerary++++++++++++++++++++++++++++++++++++++++++++++++++');
      if (data != null && data is Map<String, dynamic>) {
        setState(() {
          // Find the index of the matching day_no
          int dayIndex =
              daysDataDisplay.indexWhere((day) => day["day_no"] == dayNo);
          if (dayIndex != -1) {
            // print(daysDataDisplay[dayIndex]['activities'][index]);
            // Replace the existing object with the new data
            daysDataDisplay[dayIndex]['activities'][index] = data;
          }
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

  Future<void> getMarkAsVisitedData() async {
    String? userToken = await storage.read(key: 'userToken');
    if (resIterneryId.isEmpty) {
      return; // Exit if resIterneryId is not set
    }

    // Define the API endpoint
    final String apiUrl = '$baseurl/app/mark-visited/$resIterneryId/$userToken';

    try {
      // Make the Get request
      final response = await http.get(Uri.parse(apiUrl));
      var data = json.decode(response.body);

      // print(
      //     '+++++++++++++++++++++++++++++++++++++getMarkAsVisitedData++++++++++++++++++++++++++++++++++++++++++++++++++');
      // print(data);
      // print(
      //     '+++++++++++++++++++++++++++++++++++++getMarkAsVisitedData++++++++++++++++++++++++++++++++++++++++++++++++++');
      if (response.statusCode == 200) {
        if (data != null && data is List) {
          // Check if the response is a list
          setState(() {
            markAsVisitedList = data;
          });
        } else {
          throw Exception("Invalid data format received.");
        }
      } else {
        throw Exception("Failed to load mark as visited data.");
      }

      // print('markAsVisitedList $markAsVisitedList');
    } catch (e) {
      print('Error occurred: $e');
      // show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error Loading Mark as visited Data Please Try Again')),
      );
    }
  }

  Future<void> updateMarkAsVisitedData(
      String indexId, String deleteFlag, String dayNo) async {
    String? userToken = await storage.read(key: 'userToken');
    // print(
    //     'indexId $indexId, deleteFlag $deleteFlag, dayNo $dayNo, userToken $userToken, resIterneryId $resIterneryId');
    if (resIterneryId.isEmpty || userToken == null) {
      return; // Exit if resIterneryId is not set or userToken is null
    }

    // Define the API endpoint
    final String apiUrl = '$baseurl/app/mark-visited/update';

    // Prepare the request body
    final map = <String, dynamic>{};
    map['token'] = userToken;
    map['iterneryId'] = resIterneryId;
    map['indexId'] = indexId;
    map['deleteFlag'] = deleteFlag;
    map['dayNo'] = dayNo;

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        body: map,
      );

      var responseData = json.decode(response.body);

      print('++++++++++++++ updateMarkAsVisitedData ++++++++++++++');
      print(responseData);
      print('++++++++++++++ updateMarkAsVisitedData ++++++++++++++');

      if (response.statusCode == 200) {
        // Update local list after API call
        getMarkAsVisitedData();
      } else {
        throw Exception("Failed to update mark as visited data.");
      }
    } catch (e) {
      print('Error occurred: $e');
      // Show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error updating Mark as Visited Data. Please try again')),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
    generateItinerary().then((_) {
      getMarkAsVisitedData();
    });
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
    _scrollController.dispose();
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
                child: const LinearProgressIndicator(
                  color: Color(0xFF0099FF),
                ),
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
        backgroundColor: Colors.white,
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          ListView(
            controller: _scrollController, // Attach the ScrollController
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
                                  onTap: () async {
                                    // Navigator.of(context).pop();
                                    // Navigator.of(context).pushNamed('/home_page');
                                    // Navigator.of(context)
                                    //     .pushNamedAndRemoveUntil(
                                    //         '/home_page', (route) => false);

                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
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
                                    print(itinerarySavedFlag != '1'
                                        ? [responseData]
                                        : responseDataS);
                                    print(" //////////// ");

                                    Navigator.of(context).pushNamed(
                                        '/explore_road_map',
                                        arguments: {
                                          'itineraryDataMaps': daysDataDisplay
                                              .where((day) => day != null)
                                              .toList()
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
                                    print(resIterneryId);
                                    Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (buildContext) =>
                                              TripSettings(
                                            resIterneryId: resIterneryId,
                                            iterneryTitle: iterneryTitle,
                                          ),
                                        ));
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
                                child: GestureDetector(
                                  onTap: () {
                                    Share.share('”Hey everyone,\n'
                                        "I just generated an amazing travel itinerary with the XplorionAI Travel App – and it's too good not to share:\n"
                                        "   -Free Travel App\n"
                                        "   -Personalized Itinerary Generation\n"
                                        "   -Curated Experiences – Enjoy destination highlights, dining picks, and cultural gems\n"
                                        "   -Social Sharing & Collaboration\n"
                                        "   -Optimized for Android and iOS\n"
                                        "Download now:\n"
                                        "   -Android: Download on Google Play Store\n"
                                        "   -iOS: Download on Apple App Store\n\n\n"
                                        "Discover more at www.xplorionai.com\n"
                                        "XplorionAI – Personalized journeys that amplify.”\n");
                                  },
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.share_outlined),
                                        SizedBox(width: 8),
                                        Text(
                                          'Share',
                                          style: TextStyle(
                                            color: Color(0xFF030917),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
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
                          return buildMenuItemsCard(
                            index,
                            menuItemNames[index],
                            menuBoolList,
                            setState,
                            generateItineraryForDay,
                            _scrollToTripItinerary,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      key: tripItineraryKey,
                      child: tripItineraryWidget,
                    ),
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
    int dataLen;
    if (itinerarySavedFlag != '1') {
      dataLen = getDaysBetween(fromDate, toDate);
    } else {
      dataLen = daysDataDisplay.length;
    }
    // int dataLen = daysDataDisplay.length;
    int day = menuIndex + 1;

    if (day > dataLen) {
      if (day == (dataLen + 1)) {
        print(tripTipsArr);
        if (tripTipsArr == null || tripTipsArr == '') {
          tripTipsArr = getTipsData(); // Assign value if null or invalid
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
    print('weatherInfoData == $weatherInfoData');
    print('menuIndex == $menuIndex');
    weatherInfoToSend = weatherInfoData[menuIndex];

    List activities = [];
    for (int j = 0; j < daysDataDisplay.length; j++) {
      if (daysDataDisplay[j] == null) {
        continue; // Skip this iteration if 'day_no' is null
      }
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
          print('activitiesData[k], : ${activitiesData[k]}');

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
          activitiesSubList.add(activitiesData[k]['distance_unit']);

          // Add the sublist to the main activities list
          activities.add(activitiesSubList);

          doseImageSliders = [];
        }
      }
    }

    Map iterneryData = {
      'data': activities,
      'sliderPos': day1SliderCurrentPos,
      'showActivity': day1SliderShowActivity,
      'place': iterneryTitle.split(' ').first,
    };

    menuIndex = menuIndex + 1;
    fetchNationalHolidays();
    if (tripTipsArr == null || tripTipsArr == '') {
      tripTipsArr = getTipsData(); // Assign value if null or invalid
    }
    if (bestTimeToVisitArr == null || bestTimeToVisitArr == '') {
      bestTimeToVisitArr = getBestTimeToVisit();
    }
    if (foodDrinksArr == null || foodDrinksArr == '') {
      foodDrinksArr = getFoodAndDrink();
    }
    print('markAsVisitedList == $markAsVisitedList');
    return DayItineraryView(
        weatherSvg: 'thunder_cloud.svg',
        dayNum: '$menuIndex',
        setState: setState,
        dayActivityDataArray: iterneryData,
        contextP: context,
        transpotationModeBool: transpotationModeBool,
        weatherText: weatherInfoToSend,
        redoItinerary: redoItinerary,
        redoIndividualItinerary: redoIndividualItinerary,
        markAsVisitedList: markAsVisitedList,
        updateMarkAsVisitedData:
            updateMarkAsVisitedData); // dayActivityDataArray

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

      // Ensure the values are not null
      if (userToken == null || selectedPlace == null) {
        print("User token or selected place is null");
        return [];
      }

      // Determine the initial URL based on itinerarySavedFlag
      String initialUrl = itinerarySavedFlag == '1'
          ? '$baseurl/get-all-tips/$resIterneryId/$userToken'
          : '$baseurl/tips-for-place/$selectedPlace/$resIterneryId/$userToken';

      // Perform GET request
      final response = await http.get(Uri.parse(initialUrl));
      // print(response.body);

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON response
        List<dynamic> tipsArray =
            itinerarySavedFlag == "1" && response.body != '[]'
                ? json.decode(response.body)[0]["tipsJsonData"]
                : json.decode(response.body);

        // If the response body is an empty array and itinerarySavedFlag is '1',
        // make another call with a different URL
        if (itinerarySavedFlag == '1' && tipsArray.isEmpty) {
          final fallbackUrl =
              '$baseurl/tips-for-place/$selectedPlace/$resIterneryId/$userToken';
          final fallbackResponse = await http.get(Uri.parse(fallbackUrl));
          print(fallbackResponse.body);

          if (fallbackResponse.statusCode == 200) {
            tipsArray = json.decode(fallbackResponse.body);
          }
        }

        List<Widget> tips = tipsArray.map((item) {
          String tipText = item["tip"] as String;
          return buildTipsWidgetCard('lightbulb.svg', tipText);
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

      print(itinerarySavedFlag);
      final initialUrl = itinerarySavedFlag == '1'
          ? '$baseurl/get-all-best-time-to-visit/$resIterneryId/$userToken'
          : '$baseurl/best-time-to-visit-place/$selectedPlace/$resIterneryId/$userToken';

      // Perform GET request
      final response = await http.get(Uri.parse(initialUrl));

      // print(url);
      // print(response.body);

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON response
        List<dynamic> tipsArray =
            itinerarySavedFlag == '1' && response.body != '[]'
                ? json.decode(response.body)[0]['bestTimeToVisitJsonData']
                : json.decode(response.body);

        // If the response body is an empty array and itinerarySavedFlag is '1',
        // make another call with a different URL
        if (itinerarySavedFlag == '1' && tipsArray.isEmpty) {
          final fallbackUrl =
              '$baseurl/best-time-to-visit-place/$selectedPlace/$resIterneryId/$userToken';
          final fallbackResponse = await http.get(Uri.parse(fallbackUrl));
          print(fallbackResponse.body);

          if (fallbackResponse.statusCode == 200) {
            tipsArray = json.decode(fallbackResponse.body);
          }
        }

        List<Widget> tips = tipsArray.map((item) {
          String tipText = item["tip"] as String;
          return buildTipsWidgetCard('your-location.svg', tipText);
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
      // print(itinerarySavedFlag);
      final url = Uri.parse(itinerarySavedFlag == '1'
          ? '$baseurl/get-all-national-holidays/$resIterneryId/$userToken'
          : '$baseurl/national-holidays/$selectedPlace/$resIterneryId/$userToken');

      // Perform the GET request
      final response = await http.get(url);
      // print(url);
      print(response.body);
      // print(json.decode(response.body)[0]['nationalHolidaysJsonData']);

      // Check the response status
      if (response.statusCode == 200) {
        // Decode and return the JSON response as a list of maps
        var nationalHolidaysData = itinerarySavedFlag == '1'
            ? json.decode(response.body)[0]['nationalHolidaysJsonData']
            : json.decode(response.body);
        var nationalHolidaysDataLen = nationalHolidaysData.length;

        for (int i = 0; i < nationalHolidaysDataLen; i++) {
          setState(() {
            holiday.add(nationalHolidaysData[i]);
          });
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

      print(itinerarySavedFlag);
      final initialUrl = itinerarySavedFlag == '1'
          ? '$baseurl/get-all-food-drinks/$resIterneryId/$userToken'
          : '$baseurl/food-drinks/$selectedPlace/$resIterneryId/$userToken';
      // Perform GET request
      final response = await http.get(Uri.parse(initialUrl));

      print(initialUrl);
      print(response.body);

      // Check if response is successful
      if (response.statusCode == 200) {
        // Parse JSON response
        List<dynamic> FoodAndDrinksArray =
            itinerarySavedFlag == '1' && response.body != '[]'
                ? json.decode(response.body)[0]['foodAndDrinkJsonData']
                : json.decode(response.body);

        // If the response body is an empty array and itinerarySavedFlag is '1',
        // make another call with a different URL
        if (itinerarySavedFlag == '1' && FoodAndDrinksArray.isEmpty) {
          final fallbackUrl =
              '$baseurl/food-drinks/$selectedPlace/$resIterneryId/$userToken';
          final fallbackResponse = await http.get(Uri.parse(fallbackUrl));
          print(fallbackResponse.body);

          if (fallbackResponse.statusCode == 200) {
            FoodAndDrinksArray = json.decode(fallbackResponse.body);
          }
        }

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
