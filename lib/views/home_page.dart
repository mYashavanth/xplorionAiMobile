import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:xplorion_ai/widgets/bottom_navbar.dart';
import 'package:xplorion_ai/widgets/gradient_text.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../widgets/home_page_widgets.dart';

enum LocationStatus {
  loading,
  serviceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  granted,
  error
}

final GlobalKey<_HomePageState> homePageKey = GlobalKey<_HomePageState>();

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: homePageKey);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const apiKey = 'AIzaSyDEJx-EbYbqRixjZ0DvwuPd3FKVKtvv_OY';
  LocationStatus _locationStatus = LocationStatus.loading;
  String currentLocation = 'Loading location...';
  String? errorMessage;
  List<Widget> createdIternery = [];
  List<Widget> popularDestination = [];
  List<Widget> weekendTrips = [];

  // Get Co Ordinates
  Future<void> _determinePosition() async {
    setState(() {
      _locationStatus = LocationStatus.loading;
      errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = LocationStatus.serviceDisabled;
          errorMessage = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = LocationStatus.permissionDenied;
            errorMessage = 'Location permissions are denied.';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = LocationStatus.permissionPermanentlyDenied;
          errorMessage = 'Location permissions are permanently denied.';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // If we get here, permissions are granted
      setState(() {
        _locationStatus = LocationStatus.granted;
      });

      _getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        _locationStatus = LocationStatus.error;
        errorMessage = 'Failed to get location: ${e.toString()}';
      });
    }
  }

  Widget _buildLocationUI() {
    switch (_locationStatus) {
      case LocationStatus.loading:
        return const Text(
          'Loading location...',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w100,
          ),
        );
      case LocationStatus.serviceDisabled:
        return Column(
          children: [
            const Text(
              'Location services are disabled. Please enable them in settings.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w300,
              ),
            ),
            TextButton(
              onPressed: _determinePosition,
              child: const Text('Retry'),
            ),
          ],
        );
      case LocationStatus.permissionDenied:
        return Column(
          children: [
            const Text(
              'Please enable Location for Personalised Travel Itineraries',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w700,
                ),
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _determinePosition,
              child: const Text('Enable Location'),
            ),
          ],
        );
      case LocationStatus.permissionPermanentlyDenied:
        return Column(
          children: [
            const Text(
              'Location permissions are permanently denied. Please enable them in app settings.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
                textStyle: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w700,
                ),
                padding: EdgeInsets.zero,
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () async {
                bool opened = await openAppSettings();
                if (!opened) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Could not open app settings. Please open them manually.'),
                    ),
                  );
                }
                // _determinePosition();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      case LocationStatus.granted:
        return Text(
          currentLocation,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w300,
          ),
        );
      case LocationStatus.error:
        return Column(
          children: [
            Text(
              errorMessage ?? 'Unknown error occurred',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w300,
              ),
            ),
            TextButton(
              onPressed: _determinePosition,
              child: const Text('Retry'),
            ),
          ],
        );
    }
  }

  // get Name From Lat and Long
  Future<void> _getAddressFromLatLng(Position position) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        print(data);
        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() {
            currentLocation = data['results'][0]['formatted_address'];
          });

          _getData();
          fetchPopularDestination();
          fetchWeekendTripsNearMe();
        } else {
          setState(() {
            currentLocation = 'No address Found';
          });
        }
      } else {
        setState(() {
          currentLocation = 'Failed to fetch address';
        });
      }
    } catch (e) {
      setState(() {
        currentLocation = 'Couldnot get Location';
      });
    }
  }

  Future<void> fetchItineraries() async {
    String? userToken = await storage.read(key: 'userToken');
    final response =
        await http.get(Uri.parse('$baseurl/itinerary/all/${userToken!}'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      int dataLen = data.length;
      print(data);
      setState(() {
        createdIternery = [];

        for (int i = 0; i < dataLen; i++) {
          var place = data[i]['cityStateCountry'];
          var itineraryString = data[i]['itinerary'];
          var travelCompanion = data[i]['travelCompanion'];
          int noOfDays = itineraryString['itinerary']['days'].length;
          String dayWithDate = itineraryString['itinerary']['days'][0]['day'];
          // print(
          //     'itinerary image:------- ${itineraryString['image_for_main_place']}');
          createdIternery.add(singleCardPlan(
              context,
              itineraryString['image_for_main_place'],
              place,
              noOfDays,
              dayWithDate,
              travelCompanion,
              data[i]['_id']));
        }
      });
    }
  }

  Future<void> fetchPopularDestination() async {
    String? userToken = await storage.read(key: 'userToken');
    final response = await http.get(Uri.parse(
        '$baseurl/popular-destination-nearby/$currentLocation/${userToken!}'));
    print(
        'url:------------------------------ $baseurl/popular-destination-nearby/$currentLocation/${userToken!}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      int dataLen = data.length;

      setState(() {
        popularDestination = [];

        for (int i = 0; i < dataLen; i++) {
          var placeName = data[i]['place_name'];
          var imageURL = data[i]['image_url'];

          if (imageURL != '') {
            popularDestination
                .add(popularDestinationsNearby(imageURL, placeName, context));
          }
        }
      });
    }
  }

  Future<void> fetchWeekendTripsNearMe() async {
    String? userToken = await storage.read(key: 'userToken');
    final response = await http.get(Uri.parse(
        '$baseurl/weekend-trips-nearby/$currentLocation/${userToken!}'));

    print(
        'url:------------------------------ $baseurl/weekend-trips-nearby/$currentLocation/${userToken!}');
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      int dataLen = data.length;

      setState(() {
        weekendTrips = [];

        for (int i = 0; i < dataLen; i++) {
          var placeName = data[i]['place_name'];
          //var imageURL = data[i]['image_url'];
          String imageURL = data[i]['image_url']?.isNotEmpty == true
              ? data[i]['image_url']
              : 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png';
          var title = data[i]['title'];
          var noOfDays = data[i]['no_of_days'];
          var cityState = data[i]['city_state'];
          var distanceFromPlace = data[i]['distance_from_place'];
          var activities = data[i]['activities'];
          String category;
          if (data[i]["theme"] != null &&
              data[i]["theme"].toString().isNotEmpty) {
            category = data[i]["theme"].toString();
          } else {
            category = i == 0
                ? 'Adventure'
                : i == 1
                    ? 'Relaxation'
                    : i == 2
                        ? 'Cultural'
                        : i == 3
                            ? 'Historical'
                            : 'Nature';
          }

          if (imageURL != '') {
            weekendTrips.add(weekendTripsNearYouCard(imageURL, title, noOfDays,
                cityState, distanceFromPlace, activities, context, category));
          }
        }
      });
    }
  }

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  int currentPos = 0;

  List<Widget> imageSliders = [];

  List banner = [];
  bool showReload = false;

  @override
  void initState() {
    fetchItineraries();
    _determinePosition();

    Timer(const Duration(seconds: 15), () {
      if (popularDestination.isEmpty) {
        setState(() {
          showReload = true;
        });
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies");
    fetchItineraries(); // Call fetchItineraries whenever the page reappears
  }

  Future<void> _getData() async {
    // Add Banner
    String? userToken = await storage.read(key: 'userToken');
    final response = await http.get(
        Uri.parse('$baseurl/app/masters/home-page-banners/all/${userToken!}'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      int dataLen = data.length;
      print(
          'bannerData:+++++++++++++++++++++++++++++++++++++++++++++++++++ $data');

      for (int i = 0; i < dataLen; i++) {
        imageSliders.add(
          topBannerCard(
              'NEW',
              data[i]['banner_title'],
              data[i]['banner_description'],
              data[i]['banner_image'],
              data[i]['fromDate'],
              data[i]['toDate'],
              data[i]['travelCompanion'],
              data[i]['budgetType'],
              currentLocation,
              context),
        );
      }

      /*if(dataLen == 0)
      {
          imageSliders.add(
            topBannerCard(
                'NEW FEATURE',
                'Share your Itinerary with Friends',
                'Easily share your travel plans and get everyone on board.',
                'cp_slide_image2.jpeg'),
          );
      } */
    }

    /*;
    imageSliders.add(
      topBannerCard(
          'NEW FEATURE',
          'Travel the world with your friends',
          'Easily share your travel plans and get everyone on board.',
          'cp_slide_image3.jpeg'),
    );
    imageSliders.add(
      topBannerCard(
          'NEW FEATURE',
          'Banner 4 Heading',
          'Sit back, relax, and let AI craft your perfect itinerary.',
          'cp_slide_image1.jpeg'),
    ); */
  }

  @override
  Widget build(BuildContext context) {
    bool blockUI = _locationStatus != LocationStatus.granted;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
              child: Column(
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                          'assets/icons/location_tripssist_logo.svg',
                          semanticsLabel: 'XplorionAi',
                          width: 24,
                          height: 32),
                      /*Image(
                        width: 25,
                        height: 36,
                        image: AssetImage('assets/icons/location_tripssist_logo.svg'),
                      ), */
                      /*const SizedBox(
                        width: 10,
                      ), */

                      /*const Text(
                        'XplorionAi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontFamily: themeFontFamily,
                          fontWeight: FontWeight.w700,
                          
                        ),
                      ) */

                      // GradientText(
                      //   'Tripssist',
                      //   gradient: LinearGradient(
                      //     begin: Alignment(-1.00, 0.06),
                      //     end: Alignment(1, -0.06),
                      //     colors: [
                      //       Color(0xFF0099FF),
                      //       Color(0xFF54AB6A),
                      //     ],
                      //   ),
                      //   style: TextStyle(
                      //     color: Color(0xFF54AB6A),
                      //     fontSize: 24,
                      //     fontFamily: 'Public Sans',
                      //     fontWeight: FontWeight.w700,
                      //     height: 0,
                      //   ),
                      // ),

                      // const Spacer(),
                      // Container(
                      //   width: 40,
                      //   height: 40,
                      //   decoration: const ShapeDecoration(
                      //     image: DecorationImage(
                      //       image: AssetImage("assets/images/profile_photo.jpeg"),
                      //       fit: BoxFit.fill,
                      //     ),
                      //     shape: OvalBorder(),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildLocationUI(),
                  ),
                  const SizedBox(height: 20),
                  // Only allow interaction if permission is granted
                  Column(
                    children: [
                      // ...existing code for banners, itineraries, etc...
                      imageSliders.isEmpty
                          ? Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                CarouselSlider(
                                  options: CarouselOptions(
                                      viewportFraction: 1,
                                      enableInfiniteScroll: false,
                                      initialPage: 0,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          currentPos = index;
                                        });
                                      }),
                                  items: imageSliders,
                                ),
                                imageSliders.length == 1
                                    ? const Text('')
                                    : Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: imageSliders.map((url) {
                                            int index =
                                                imageSliders.indexOf(url);
                                            return Container(
                                              width: currentPos == index
                                                  ? 14
                                                  : 8.0,
                                              height: 8,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 2.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(50)),
                                                color: currentPos == index
                                                    ? const Color(0xFF8B8D98)
                                                    : const Color(0xFFCDCED7),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                              ],
                            ),
                      createdIternery.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Continue planning',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF1F1F1F),
                                        fontSize: 20,
                                        fontFamily: themeFontFamily,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushNamed('/continue_planning');
                                        },
                                        child: const Text(
                                          'Top 6',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontFamily: themeFontFamily2,
                                            fontWeight: FontWeight.w400,
                                            height: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                    'Pick up where you left off, Keep your adventures rolling!'),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 144,
                                  child: ListView(
                                    itemExtent:
                                        MediaQuery.of(context).size.width *
                                            0.92,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics:
                                        const PageScrollPhysics(), // Enables snapping to one card at a time
                                    children: createdIternery,
                                  ),
                                ),
                              ],
                            ),
                      // singleCardPlan(context),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // SizedBox(
            //   height: 440,
            //   width: double.maxFinite,
            //   child: Stack(
            //     children: [
            //       SizedBox(
            //         width: double.maxFinite,
            //         height: 440,
            //         child: Stack(
            //           children: [
            //             const Image(
            //               width: double.maxFinite,
            //               height: double.maxFinite,
            //               fit: BoxFit.cover,
            //               image: AssetImage(
            //                   'assets/images/homepage_banner_image.jpeg'),
            //             ),
            //             Positioned.fill(
            //               child: Opacity(
            //                 opacity: 0.3,
            //                 child: Container(
            //                   color: const Color(0xFF000000),
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       Container(
            //         padding: const EdgeInsets.all(20),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             const Spacer(),
            //             const Text(
            //               'Create your dream trip in minutes with AI',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 32,
            //                 fontFamily: 'Public Sans',
            //                 fontWeight: FontWeight.w700,
            //               ),
            //             ),
            //             const SizedBox(
            //               height: 10,
            //             ),
            //             const Text(
            //               'Jumpstart your adventure with a personalized itinerary, powered by expert reviews.',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 14,
            //                 fontFamily: 'Public Sans',
            //                 fontWeight: FontWeight.w400,
            //               ),
            //             ),
            //             Container(
            //               margin: const EdgeInsets.only(top: 20),
            //               width: 114,
            //               height: 37,
            //               padding: const EdgeInsets.symmetric(
            //                   horizontal: 12, vertical: 8),
            //               decoration: ShapeDecoration(
            //                 gradient: const LinearGradient(
            //                   begin: Alignment(-1.00, 0.06),
            //                   end: Alignment(1, -0.06),
            //                   colors: [
            //                     Color(0xFF0099FF),
            //                     Color(0xFF54AB6A),
            //                   ],
            //                 ),
            //                 shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.circular(4)),
            //               ),
            //               child: const Row(
            //                 mainAxisSize: MainAxisSize.min,
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 crossAxisAlignment: CrossAxisAlignment.center,
            //                 children: [
            //                   Text(
            //                     'Try it now',
            //                     style: TextStyle(
            //                       color: Colors.white,
            //                       fontSize: 14,
            //                       fontFamily: 'Public Sans',
            //                       fontWeight: FontWeight.w600,
            //                       height: 0.11,
            //                     ),
            //                   ),
            //                   SizedBox(width: 8),
            //                   SizedBox(
            //                     width: 14.42,
            //                     height: 15,
            //                     child: Image(
            //                         image: AssetImage('assets/icons/stars.png')),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       )
            //     ],
            //   ),
            // ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekend trips near you',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1F1F1F),
                      fontSize: 20,
                      fontFamily: themeFontFamily,
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                  const Text('Discover perfect weekend getaways near you!'),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 400,
                    child: weekendTrips.isEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            scrollDirection: Axis.horizontal,
                            itemCount: 5, // Number of shimmer cards to display
                            itemBuilder: (context, index) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 200,
                                  height: 300,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            },
                          )
                        : ListView(
                            padding: const EdgeInsets.only(top: 4, bottom: 4),
                            scrollDirection: Axis.horizontal,
                            children: weekendTrips, //[
                            //weekendTripsNearYouCard('church.jpeg'),
                            //weekendTripsNearYouCard('mysore_palace.jpeg'),
                            //weekendTripsNearYouCard('mysore_palace.jpeg'),
                            //],
                          ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    'Popular destinations nearby',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1F1F1F),
                      fontSize: 20,
                      fontFamily: themeFontFamily,
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                  const Text('Uncover must-see gems just around the corner!'),
                  SizedBox(
                    height: 10,
                  ),
                  AbsorbPointer(
                    absorbing: blockUI,
                    child: Opacity(
                      opacity: blockUI ? 0.4 : 1.0,
                      child: SizedBox(
                        height: 240,
                        child: popularDestination.isEmpty
                            ? Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.only(
                                          top: 4, bottom: 4),
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          5, // Number of shimmer cards to display
                                      itemBuilder: (context, index) {
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey.shade300,
                                          highlightColor: Colors.grey.shade100,
                                          child: Container(
                                            width: 200,
                                            height: 240,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (showReload)
                                    Center(
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.refresh,
                                              color: Colors.blue),
                                          iconSize: 32,
                                          onPressed: () {
                                            setState(() {
                                              showReload = false;
                                            });
                                            fetchPopularDestination(); // Reload data
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : ListView(
                                padding:
                                    const EdgeInsets.only(top: 4, bottom: 4),
                                scrollDirection: Axis.horizontal,
                                children: popularDestination,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            )
          ],
        ),
        bottomNavigationBar: AbsorbPointer(
          absorbing: blockUI,
          child: Opacity(
            opacity: blockUI ? 0.4 : 1.0,
            child: const TripssistNavigationBar(0),
          ),
        ),
      ),
    );
  }
}

class CustomNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPopNext;

  CustomNavigatorObserver({required this.onPopNext});

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    print("didPop called ${previousRoute?.settings.name}");
    if (previousRoute?.settings.name == '/home_page') {
      print("onPopNext called");
      onPopNext(); // Trigger the callback when navigating back to HomePage
    }
  }
}
