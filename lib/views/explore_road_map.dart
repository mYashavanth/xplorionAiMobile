import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExploreRoadMap extends StatefulWidget {
  const ExploreRoadMap({super.key});

  @override
  State<ExploreRoadMap> createState() => _ExploreRoadMapState();
}

class _ExploreRoadMapState extends State<ExploreRoadMap>
    with TickerProviderStateMixin {
  late TabController mapTabController;

  List<bool> showPopUpWidgetsBool = [true, true, true, true];
  List<bool> itineraryDatesRowBool = [true, false, false, false,false];
  int tablength = 2;

  @override
  void initState() {
    // TODO: implement initState
    mapTabController = TabController(length: tablength, vsync: this);
    mapTabController.addListener(() {
      if (mapTabController.indexIsChanging) {
        setState(() {

          _getShortestRoute(mapTabController.index);

        });
      }
    });

    super.initState();
  }

  final List<Tab> topTabs = [];

  GoogleMapController? mapController;

  // Define multiple LatLng points
  final List<LatLng> points = [
     const LatLng(37.7749, -122.4194), // San Francisco
    //LatLng(34.0522, -118.2437), // Los Angeles
    //LatLng(36.1699, -115.1398), // Las Vegas
    //LatLng(32.7157, -117.1611), // San Diego
    //LatLng(33.4484, -112.0740), // Phoenix
  ];
  List<Widget> exploreLocationCards = [];
  bool isLoading = true;

  // Create polylines
  Set<Polyline> polylines = {};

  // Initial Day  1
  int dayNo = 0;

  // API key for Google Maps Directions API
  static const String googleApiKey = 'AIzaSyDEJx-EbYbqRixjZ0DvwuPd3FKVKtvv_OY';



  // Function to fetch and display shortest route
  Future<void> _getShortestRoute(int tabIndex) async {

    points.clear();
    polylines.clear();

    final receivedArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    var itineraryDataForMaps = receivedArgs?['itineraryDataMaps'];
    print(itineraryDataForMaps[0]['itinerary']['itinerary']['days']);
    var mapsDataJson = itineraryDataForMaps[0]['itinerary']['itinerary']['days'];
    int dataLen = mapsDataJson.length;

    for(int i = 0;i < dataLen;i++)
    {
        if(topTabs.length < dataLen)
        {
            topTabs.add(Tab(
                text: 'Day ${i + 1}'
            ));
        }

      var dayWiseActivityData = mapsDataJson[i]['activities'];
      if(tabIndex == i)
      {
        for(int d = 0;d < dayWiseActivityData.length;d++)
        {
          if (dayWiseActivityData[d]['lat'] != null && dayWiseActivityData[d]['long'] != null) {
            points.add(LatLng(dayWiseActivityData[d]['lat'], dayWiseActivityData[d]['long']));
          }

        //   creating exploreLocationCards
        //   exploreLocationCards.add(popUpExploreWidgets(
        //       d,
        //       context,
        //       showPopUpWidgetsBool,
        //       setState,
        //       'ooty.jpeg',
        //       'Tea Gardens',
        //       true,
        //       true,
        //       2,
        //       false,
        //       false,
        //       false));
        }
      }
    }

    final String origin = '${points.first.latitude},${points.first.longitude}';
    final String destination = '${points.last.latitude},${points.last.longitude}';

    // Format waypoints by skipping the first and last points
    final String waypoints = points
        .sublist(1, points.length - 1)
        .map((point) => '${point.latitude},${point.longitude}')
        .join('|');

    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&waypoints=$waypoints&key=$googleApiKey';
    //final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$googleApiKey';
    //print(url);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
        final data = json.decode(response.body);

      if (data['routes'].isNotEmpty) {
        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        final decodedPolyline = _decodePolyline(polylinePoints);

        setState(() {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('shortest_route'),
              points: decodedPolyline,
              color: Colors.blue,
              width: 10,
            ),
          );
        });
      }
    } else {
      print('Failed to fetch directions');
    }
  }

// Function to decode the polyline
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> decodedPoints = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      decodedPoints.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return decodedPoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        title: const Text(
          'Explore',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: TabBar(
          labelColor: Colors.black,
          labelPadding: const EdgeInsets.all(0),
          indicatorColor: Colors.black,
          indicatorPadding: const EdgeInsets.all(0),
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'IBM Plex Sans',
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 16,
            fontFamily: 'IBM Plex Sans',
            fontWeight: FontWeight.w400,
          ),
          controller: mapTabController,
          tabs: topTabs /*const [
           Tab(
              text: 'Overview',
              // icon: Icon(Icons.directions_car),
            ),
            Tab(
              text: 'Attractions',
            ),
            Tab(
              text: 'Restaurants',
            ),
          ]*/,
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              child: GoogleMap(
                onMapCreated: (controller) async {
                  mapController = controller;
                  await _getShortestRoute(0); // Fetch and draw the route when the map is created
                },
                initialCameraPosition: CameraPosition(
                  target: points[0],
                  zoom: 10,
                ),
                markers: points.map((point) {
                  return Marker(
                    markerId: MarkerId(point.toString()),
                    position: point,
                    infoWindow: InfoWindow(
                      title: "Point",
                      snippet: "${point.latitude}, ${point.longitude}",
                    ),
                  );
                }).toSet(),
                polylines: polylines,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 515,
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.036),
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: exploreLocationCards,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget popUpExploreWidgets(
      index,
      context,
      showPopUpWidgetsBool,
      setState,
      img,
      title,
      smallChips,
      locationNumBool,
      locationInt,
      locationBool,
      fullDay,
      saved) {
    String save = 'save_outline.svg';
    if (saved) {
      save = 'save_fill.svg';
    }

    return Visibility(
      visible: showPopUpWidgetsBool[index],
      child: Container(
        // color: Colors.green,
        // width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  showPopUpWidgetsBool[index] = !showPopUpWidgetsBool[index];
                  setState(() {});
                },
                icon: const Icon(Icons.close),
              ),
            ),
            Container(
              // height: 350,
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 120,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/$img"),
                        fit: BoxFit.fill,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Visibility(
                        visible: locationNumBool,
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 25,
                              width: 25,
                              child: SvgPicture.asset(
                                  'assets/icons/location_icon_blue.svg'),
                            ),
                            SizedBox(
                              height: 25,
                              width: 25,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    locationInt.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: themeFontFamily2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: themeFontFamily2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  Visibility(
                    visible: smallChips,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
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
                                'Farm',
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
                                'Nature & Parks',
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
                                'Museum',
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Tea gardens in Kochi, Kerala, are scenic plantations known for lush tea cultivation in hilly terrains.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/star_rating.svg',
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        '4.8 (80224)',
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                          fontFamily: 'IBM Plex Sans',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ],
                  ),

                  Visibility(
                    visible: locationBool,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child:  Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/timer_clock.svg',
                          ),
                          // Image(
                          //   color: Color(0xFF888888),
                          //   image: AssetImage('assets/images/timer_icon.png'),
                          // ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            'People typically spend 60 min here',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  //

                  //
                  Visibility(
                    visible: fullDay,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/clock_fill.svg',
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            'Friday : Open 24 hours',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //

                  //
                  Visibility(
                    visible: locationBool,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/location.svg',color: const Color(0xFF888888),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            'KDHP house,NH 49,Nullatanni,Munnar kerala,685612',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/clock_fill.svg',
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Thursday : 9:30 AM - 10:45 PM',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //

                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return buildAddToYourTrip(
                                      setState, context, itineraryDatesRowBool);
                                });
                              });
                        },
                        child: Container(
                          height: 32,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: ShapeDecoration(
                            color: const Color(0xFF005CE7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/$save',
                                color: Colors.white,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
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
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        margin: const EdgeInsets.only(right: 10),
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
                            const Text(
                              'Directions',
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
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // SvgPicture.asset('assets/icons/directions.svg'),
                            // const SizedBox(
                            //   width: 5,
                            // ),
                            Text(
                              'Details',
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildAddToYourTrip(StateSetter setState, BuildContext context,
    List<bool> itineraryDatesRowBool) {
  return Container(
    height: 460,
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
              const Text(
                'Add To your trip',
                style: TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 20,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w600,
                ),
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
          padding: const EdgeInsets.fromLTRB(10,0,10,10),
          child: Column(
            children: [
              
              buildItineraryDateRow(0, 'Day 1 Itinerary',
                  itineraryDatesRowBool, context, setState),
              const SizedBox(
                height: 10,
              ),
              buildItineraryDateRow(1, 'Day 2 Itinerary',
                  itineraryDatesRowBool, context, setState),
              const SizedBox(
                height: 10,
              ),
              buildItineraryDateRow(2, 'Day 3 Itinerary',
                  itineraryDatesRowBool, context, setState),
              const SizedBox(
                height: 10,
              ),
              buildItineraryDateRow(3, 'Wednesday, June 12',
                  itineraryDatesRowBool, context, setState),
              const SizedBox(
                height: 10,
              ),
              buildItineraryDateRow(4, 'Thursday, June 14',
                  itineraryDatesRowBool, context, setState),
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
}

Widget buildItineraryDateRow(
    index, date, itineraryDatesRowBool, context, setState) {
  return SizedBox(
    child: Row(
      children: [
        SvgPicture.asset('assets/icons/save_date_list.svg'),
        const SizedBox(
          width: 20,
        ),
        Text(
          date,
          style: const TextStyle(
            color: Color(0xFF030917),
            fontSize: 14,
            fontFamily: themeFontFamily2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        itineraryDatesRowBool[index]
            ? const IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.check_circle,
                  color: Color(0xFF005CE8),
                ),
              )
            : IconButton(
                onPressed: () {
                  for (var i = 0; i < itineraryDatesRowBool.length; i++) {
                    itineraryDatesRowBool[i] = i == index;
                  }
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
