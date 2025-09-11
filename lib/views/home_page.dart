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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const apiKey = 'AIzaSyDEJx-EbYbqRixjZ0DvwuPd3FKVKtvv_OY';
  LocationStatus _locationStatus = LocationStatus.loading;
  String currentLocation = 'Loading location...';
  String? errorMessage;
  List<Widget> createdIternery = [];
  List<Widget> popularDestination = [];
  List<Widget> weekendTrips = [];
  bool _isDialogShowing = false;

  final FlutterSecureStorage storage = const FlutterSecureStorage();
  int currentPos = 0;
  List<Widget> imageSliders = [];
  bool showReload = false;
  bool _isManualLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialLocation();

    Timer(const Duration(seconds: 15), () {
      if (mounted &&
          popularDestination.isEmpty &&
          _locationStatus == LocationStatus.granted) {
        setState(() {
          showReload = true;
        });
      }
    });
  }

  // MODIFIED: This function now handles the initial location setup with a default.
  Future<void> _loadInitialLocation() async {
    String? savedLocation = await storage.read(key: 'savedLocation');
    String? isManualStr = await storage.read(key: 'isLocationManual');

    if (savedLocation != null && savedLocation.isNotEmpty) {
      // If a location is already saved, use it.
      setState(() {
        currentLocation = savedLocation;
        _locationStatus = LocationStatus.granted;
        _isManualLocation = (isManualStr == 'true');
      });
      _fetchAllData();
    } else {
      // FIRST LAUNCH: Set a default location without asking for permission.
      await _setDefaultLocationAndFetchData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionOnResume();
    }
  }

  // This function is now only called by user action (GPS button or pull-to-refresh).
  Future<void> _determinePosition() async {
    setState(() => _locationStatus = LocationStatus.loading);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showInfoDialog(
            'Location Disabled', 'Please enable location services to use GPS.');
        setState(() =>
            _locationStatus = LocationStatus.granted); // Revert to stable state
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showInfoDialog('Permission Denied',
            'Please grant location permission to use this feature.');
        setState(() =>
            _locationStatus = LocationStatus.granted); // Revert to stable state
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _showInfoDialog('Permission Permanently Denied',
            'Location permission is permanently denied. Please enable it in your device settings.',
            showSettingsButton: true);
        setState(() =>
            _locationStatus = LocationStatus.granted); // Revert to stable state
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _getAddressFromLatLng(position);
    } catch (e) {
      _showInfoDialog('Location Error',
          'Could not get your current location. Please try again or enter one manually.');
      setState(() =>
          _locationStatus = LocationStatus.granted); // Revert to stable state
    }
  }

  void _showInfoDialog(String title, String message,
      {bool showSettingsButton = false, VoidCallback? onDismiss}) {
    if (_isDialogShowing || !mounted) return;
    _isDialogShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (showSettingsButton)
              TextButton(
                child: const Text('Open Settings'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await openAppSettings();
                },
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ).then((_) {
        _isDialogShowing = false;
        onDismiss?.call();
      });
    });
  }

  void _showManualLocationEntryDialog() async {
    final _formKey = GlobalKey<FormState>();

    String? savedAddress = await storage.read(key: 'manualAddress');
    String? savedCity = await storage.read(key: 'manualCity');
    String? savedState = await storage.read(key: 'manualState');
    String? savedPincode = await storage.read(key: 'manualPincode');
    String? savedCountry = await storage.read(key: 'manualCountry');

    final _addressController = TextEditingController(text: savedAddress);
    final _cityController = TextEditingController(text: savedCity);
    final _stateController = TextEditingController(text: savedState);
    final _pincodeController = TextEditingController(text: savedPincode);
    final _countryController = TextEditingController(text: savedCountry);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Enter Your Location',
              style: TextStyle(
                color: Color(0xFF1F1F1F),
                fontSize: 20,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _addressController,
                      autofocus: true,
                      style: const TextStyle(fontFamily: themeFontFamily),
                      decoration: InputDecoration(
                        labelText: 'Address / Area *',
                        hintText: 'e.g., 836, SBI Staff Colony...',
                        labelStyle: const TextStyle(
                            fontFamily: themeFontFamily, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Address / Area is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      style: const TextStyle(fontFamily: themeFontFamily),
                      decoration: InputDecoration(
                        labelText: 'City *',
                        hintText: 'e.g., Bengaluru',
                        labelStyle: const TextStyle(
                            fontFamily: themeFontFamily, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stateController,
                      style: const TextStyle(fontFamily: themeFontFamily),
                      decoration: InputDecoration(
                        labelText: 'State / Province *',
                        hintText: 'e.g., Karnataka',
                        labelStyle: const TextStyle(
                            fontFamily: themeFontFamily, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'State / Province is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pincodeController,
                      style: const TextStyle(fontFamily: themeFontFamily),
                      decoration: InputDecoration(
                        labelText: 'Pincode / Zip Code *',
                        hintText: 'e.g., 560040',
                        labelStyle: const TextStyle(
                            fontFamily: themeFontFamily, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Pincode / Zip Code is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _countryController,
                      style: const TextStyle(fontFamily: themeFontFamily),
                      decoration: InputDecoration(
                        labelText: 'Country *',
                        hintText: 'e.g., India',
                        labelStyle: const TextStyle(
                            fontFamily: themeFontFamily, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Country is required.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF005CE7),
                    fontFamily: themeFontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), // Increased rounding
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0099FF), // Darker Blue
                      Color(0xFF54AB6A), // Darker Green
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final address = _addressController.text.trim();
                      final city = _cityController.text.trim();
                      final state = _stateController.text.trim();
                      final pincode = _pincodeController.text.trim();
                      final country = _countryController.text.trim();

                      final details = {
                        'address': address,
                        'city': city,
                        'state': state,
                        'pincode': pincode,
                        'country': country,
                      };

                      final locationString =
                          "$address, $city, $state $pincode, $country";

                      Navigator.of(context).pop();
                      _updateLocationAndFetchData(locationString,
                          isManual: true, details: details);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(25), // Increased rounding
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: themeFontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateLocationAndFetchData(String location,
      {required bool isManual, Map<String, String>? details}) async {
    await storage.write(key: 'savedLocation', value: location);
    await storage.write(key: 'isLocationManual', value: isManual.toString());

    if (isManual && details != null) {
      await storage.write(key: 'manualAddress', value: details['address']);
      await storage.write(key: 'manualCity', value: details['city']);
      await storage.write(key: 'manualState', value: details['state']);
      await storage.write(key: 'manualPincode', value: details['pincode']);
      await storage.write(key: 'manualCountry', value: details['country']);
    }

    setState(() {
      currentLocation = location;
      _locationStatus = LocationStatus.granted;
      _isManualLocation = isManual;
    });
    _fetchAllData();
  }

  Future<void> _setDefaultLocationAndFetchData() async {
    const defaultLocation = "Majestic, Bengaluru, Karnataka 560009, India";
    await _updateLocationAndFetchData(defaultLocation, isManual: true);
  }

  Future<void> _fetchAllData() async {
    setState(() {
      createdIternery.clear();
      popularDestination.clear();
      weekendTrips.clear();
      imageSliders.clear();
      showReload = false;
    });

    await fetchItineraries();
    await _getData();
    await fetchPopularDestination();
    await fetchWeekendTripsNearMe();
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final newLocation = data['results'][0]['formatted_address'];
          _updateLocationAndFetchData(newLocation, isManual: false);
        } else {
          throw Exception('No address found from coordinates.');
        }
      } else {
        throw Exception('Failed to fetch address from API.');
      }
    } catch (e) {
      setState(() {
        _locationStatus = LocationStatus.error;
        errorMessage = 'Could not get location name. Please try manually.';
      });
      _showInfoDialog('Location Error', errorMessage!);
    }
  }

  Future<void> fetchItineraries() async {
    String? userToken = await storage.read(key: 'userToken');
    if (userToken == null) return;
    final response =
        await http.get(Uri.parse('$baseurl/itinerary/all/${userToken}'));

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
        }
      });
    }
  }

  Future<void> fetchPopularDestination() async {
    if (currentLocation == 'Loading location...' ||
        _locationStatus != LocationStatus.granted) return;
    String? userToken = await storage.read(key: 'userToken');
    if (userToken == null) return;
    final response = await http.get(Uri.parse(
        '$baseurl/popular-destination-nearby/$currentLocation/${userToken}'));
    print(
        'url:------------------------------ $baseurl/popular-destination-nearby/$currentLocation/${userToken}');

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
    if (currentLocation == 'Loading location...' ||
        _locationStatus != LocationStatus.granted) return;
    String? userToken = await storage.read(key: 'userToken');
    if (userToken == null) return;
    final response = await http.get(Uri.parse(
        '$baseurl/weekend-trips-nearby/$currentLocation/${userToken}'));

    print(
        'url:------------------------------ $baseurl/weekend-trips-nearby/$currentLocation/${userToken}');
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      int dataLen = data.length;

      setState(() {
        weekendTrips = [];
        for (int i = 0; i < dataLen; i++) {
          String imageURL = data[i]['image_url']?.isNotEmpty == true
              ? data[i]['image_url']
              : 'https://xplorionai.nyc3.cdn.digitaloceanspaces.com/banners/placeholder_image.jpg';
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
            category = i % 5 == 0
                ? 'Adventure'
                : i % 5 == 1
                    ? 'Relaxation'
                    : i % 5 == 2
                        ? 'Cultural'
                        : i % 5 == 3
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

  Future<void> _checkPermissionOnResume() async {
    // We only try to auto-refresh if the user previously denied (but not forever).
    if (_locationStatus == LocationStatus.permissionDenied ||
        _locationStatus == LocationStatus.serviceDisabled) {
      _determinePosition();
    }
  }

  void _showRefreshPopup() {
    if (_isDialogShowing || !mounted) return;
    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Enabled'),
        content: const Text(
            'Location services are now enabled. Refresh to see personalized content.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isDialogShowing = false;
              _refreshAllData();
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    ).then((_) => _isDialogShowing = false);
  }

  Future<void> _refreshAllData() async {
    await _determinePosition();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _getData() async {
    String? userToken = await storage.read(key: 'userToken');
    if (userToken == null) return;
    final response = await http.get(
        Uri.parse('$baseurl/app/masters/home-page-banners/all/${userToken}'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      int dataLen = data.length;
      if (imageSliders.isNotEmpty) {
        imageSliders.clear();
      }
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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    bool blockUI = _locationStatus != LocationStatus.granted;

    return RefreshIndicator(
      onRefresh: _refreshAllData,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ListView(
            children: [
              Container(
                color: Colors.white,
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                            'assets/icons/location_tripssist_logo.svg',
                            semanticsLabel: 'XplorionAi',
                            width: 24,
                            height: 32),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildLocationUI(),
                    const SizedBox(height: 20),
                    Opacity(
                      opacity: blockUI ? 0.4 : 1.0,
                      child: AbsorbPointer(
                        absorbing: blockUI,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                            viewportFraction: 1.0,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                currentPos = index;
                                              });
                                            }),
                                        items: imageSliders,
                                      ),
                                      if (imageSliders.length > 1)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: imageSliders
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            return GestureDetector(
                                              onTap: () =>
                                                  {}, // Add controller to animate to page
                                              child: Container(
                                                width: currentPos == entry.key
                                                    ? 12.0
                                                    : 8.0,
                                                height: 8.0,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 4.0),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: (Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black)
                                                        .withOpacity(
                                                            currentPos ==
                                                                    entry.key
                                                                ? 0.9
                                                                : 0.4)),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                    ],
                                  ),
                            const SizedBox(height: 20),
                            if (createdIternery.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Continue planning',
                                        style: TextStyle(
                                          color: Color(0xFF1F1F1F),
                                          fontSize: 20,
                                          fontFamily: themeFontFamily,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushNamed('/continue_planning');
                                        },
                                        child: Container(
                                          width: 55,
                                          height: 29,
                                          padding: const EdgeInsets.all(0),
                                          decoration: ShapeDecoration(
                                            color: const Color(0xFFECF2FF),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Top 6',
                                              style: TextStyle(
                                                  color: Color(0xFF005CE7),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const Text(
                                      'Pick up where you left off, Keep your adventures rolling!'),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 144,
                                    child: ListView(
                                      itemExtent:
                                          MediaQuery.of(context).size.width *
                                              0.92,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: const PageScrollPhysics(),
                                      children: createdIternery,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            const Text(
                              'Weekend trips near you',
                              style: TextStyle(
                                color: Color(0xFF1F1F1F),
                                fontSize: 20,
                                fontFamily: themeFontFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                                'Discover perfect weekend getaways near you!'),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 400,
                              child: weekendTrips.isEmpty
                                  ? ListView.builder(
                                      padding: const EdgeInsets.only(
                                          top: 4, bottom: 4),
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          3, // Only 3 dummy cards as requested
                                      itemBuilder: (context, index) {
                                        // Create dummy data for each card
                                        final dummyData = [
                                          {
                                            'image':
                                                'assets/images/weekendTrips/21.jpg',
                                            'title':
                                                'Plotting your next escape',
                                            'noOfDays':
                                                'Making space for a mini vacation...',
                                            'cityState':
                                                'Somewhere worth escaping to...',
                                            'distanceFromPlace':
                                                'Calculating miles of memories...',
                                            'activities':
                                                'Relax, Unwind, Explore',
                                            'category': 'Adventure',
                                          },
                                          {
                                            'image':
                                                'assets/images/weekendTrips/1500.jpg',
                                            'title':
                                                'Plotting your next escape',
                                            'noOfDays':
                                                'Making space for a mini vacation...',
                                            'cityState':
                                                'Somewhere worth escaping to...',
                                            'distanceFromPlace':
                                                'Calculating miles of memories...',
                                            'activities':
                                                'Relax, Unwind, Explore',
                                            'category': 'Relaxation',
                                          },
                                          {
                                            'image':
                                                'assets/images/weekendTrips/7353.jpg',
                                            'title':
                                                'Plotting your next escape',
                                            'noOfDays':
                                                'Making space for a mini vacation...',
                                            'cityState':
                                                'Somewhere worth escaping to...',
                                            'distanceFromPlace':
                                                'Calculating miles of memories...',
                                            'activities':
                                                'Relax, Unwind, Explore',
                                            'category': 'Cultural',
                                          },
                                        ];

                                        return Stack(
                                          children: [
                                            // Actual dummy card with slightly reduced opacity
                                            Opacity(
                                              opacity: 0.8,
                                              child: weekendTripsNearYouCard(
                                                dummyData[index]['image']!,
                                                dummyData[index]['title']!,
                                                dummyData[index]['noOfDays']!,
                                                dummyData[index]['cityState']!,
                                                dummyData[index]
                                                    ['distanceFromPlace']!,
                                                dummyData[index]['activities']!,
                                                context,
                                                dummyData[index]['category']!,
                                              ),
                                            ),

                                            // More visible shimmer overlay with gradient
                                            Shimmer.fromColors(
                                              baseColor: Colors.grey.shade300
                                                  .withOpacity(0.7),
                                              highlightColor:
                                                  Colors.white.withOpacity(0.9),
                                              period: const Duration(
                                                  milliseconds:
                                                      1500), // Faster animation
                                              child: Container(
                                                width: 291,
                                                height: 410,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.white
                                                          .withOpacity(0.5),
                                                      Colors.white
                                                          .withOpacity(0.3),
                                                      Colors.white
                                                          .withOpacity(0.5),
                                                    ],
                                                    stops: const [
                                                      0.1,
                                                      0.5,
                                                      0.9
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  : ListView(
                                      padding: const EdgeInsets.only(
                                          top: 4, bottom: 4),
                                      scrollDirection: Axis.horizontal,
                                      children: weekendTrips,
                                    ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Popular destinations nearby',
                              style: TextStyle(
                                color: Color(0xFF1F1F1F),
                                fontSize: 20,
                                fontFamily: themeFontFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                                'Uncover must-see gems just around the corner!'),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 240,
                              child: popularDestination.isEmpty
                                  ? Column(
                                      children: [
                                        Expanded(
                                          child: ListView.builder(
                                            padding: const EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: 4,
                                            itemBuilder: (context, index) {
                                              final dummyData = [
                                                {
                                                  'image':
                                                      'assets/images/popularDestinations/354.jpg',
                                                  'title': 'Hills',
                                                },
                                                {
                                                  'image':
                                                      'assets/images/popularDestinations/39550.jpg',
                                                  'title': 'Beaches',
                                                },
                                                {
                                                  'image':
                                                      'assets/images/popularDestinations/2149211337.jpg',
                                                  'title': 'Mountains',
                                                },
                                                {
                                                  'image':
                                                      'assets/images/popularDestinations/2150456198.jpg',
                                                  'title': 'Landmarks',
                                                },
                                              ];

                                              return Stack(
                                                children: [
                                                  // Dummy card with reduced opacity
                                                  Opacity(
                                                    opacity: 0.8,
                                                    child:
                                                        popularDestinationsNearby(
                                                      dummyData[index]
                                                          ['image']!,
                                                      dummyData[index]
                                                          ['title']!,
                                                      context,
                                                    ),
                                                  ),

                                                  // Enhanced shimmer overlay
                                                  Shimmer.fromColors(
                                                    baseColor: Colors.white
                                                        .withOpacity(0.9),
                                                    highlightColor: Colors
                                                        .grey.shade100
                                                        .withOpacity(0.9),
                                                    period: const Duration(
                                                        milliseconds:
                                                            1000), // Faster animation
                                                    child: Container(
                                                      width: 152,
                                                      height: 234,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Colors.white
                                                                .withOpacity(
                                                                    0.5),
                                                            Colors.white
                                                                .withOpacity(
                                                                    0.3),
                                                            Colors.white
                                                                .withOpacity(
                                                                    0.5),
                                                          ],
                                                          stops: const [
                                                            0.1,
                                                            0.5,
                                                            0.9
                                                          ],
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                                                color: Colors.white
                                                    .withOpacity(0.8),
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
                                                  fetchPopularDestination();
                                                },
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  : ListView(
                                      padding: const EdgeInsets.only(
                                          top: 4, bottom: 4),
                                      scrollDirection: Axis.horizontal,
                                      children: popularDestination,
                                    ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
      ),
    );
  }

  Widget _buildLocationUI() {
    switch (_locationStatus) {
      case LocationStatus.loading:
        return const Text('Loading location...',
            style: TextStyle(color: Colors.black, fontSize: 12));
      case LocationStatus.granted:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: Colors.blue, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                currentLocation,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(
              height: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.gps_fixed, size: 18, color: Colors.blue),
                tooltip: 'Select current location',
                onPressed: () => _determinePosition(), // Trigger GPS flow
              ),
            ),
            SizedBox(
              height: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                tooltip: 'Enter location manually',
                onPressed: _showManualLocationEntryDialog,
              ),
            )
          ],
        );
      case LocationStatus.serviceDisabled:
      case LocationStatus.permissionDenied:
      case LocationStatus.permissionPermanentlyDenied:
      case LocationStatus.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errorMessage ?? 'Location is needed for personalized content.',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.blue,
              ),
              onPressed: () => _determinePosition(),
              child: const Text('Set Location',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
    }
  }
}

class CustomNavigatorObserver extends NavigatorObserver {
  final VoidCallback onPopNext;

  CustomNavigatorObserver({required this.onPopNext});

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name == '/home_page') {
      onPopNext();
    }
  }
}
