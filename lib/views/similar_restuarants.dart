import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:io';

class SimilarRestuarants extends StatefulWidget {
  const SimilarRestuarants({super.key});

  @override
  State<SimilarRestuarants> createState() => _SimilarRestuarantsState();
}

class _SimilarRestuarantsState extends State<SimilarRestuarants> {
  final storage = const FlutterSecureStorage();
  String placeName = '';
  String place = '';
  List<int> restuarantCurrentPos = [];
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> restaurants = [];
  bool limitReached = false;
  List<bool> isNameExpanded = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          placeName = args['placeName'];
          place = args['place'];
        });
        fetchSimilarRestaurants();
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'No place information provided';
        });
      }
    });
  }

  Future<void> fetchSimilarRestaurants() async {
    try {
      final token = await storage.read(key: 'userToken');
      if (token == null) {
        throw Exception('User token not found. Please login again.');
      }

      final response = await http.get(
        Uri.parse(
            '$baseurl/similer-resturant/${Uri.encodeComponent('$placeName $place')}/$token'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map &&
            data.containsKey("errFlag") &&
            data["errFlag"] == 2) {
          setState(() {
            limitReached = true;
            isLoading = false;
            errorMessage =
                data["message"] ?? 'Similar restaurant creation limit reached';
          });
          return;
        } else if (data is List) {
          if (data.isEmpty) {
            setState(() {
              isLoading = false;
              errorMessage = 'No similar restaurants found';
            });
          } else {
            setState(() {
              restaurants = data;
              restuarantCurrentPos = List<int>.filled(data.length, 0);
              isNameExpanded = List<bool>.filled(data.length, false);
              isLoading = false;
              errorMessage = '';
            });
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to load restaurants. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load restaurants: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _openMap(double latitude, double longitude) async {
    String googleMapsUrl = 'geo:$latitude,$longitude?q=$latitude,$longitude';
    String appleMapsUrl = 'http://maps.apple.com/?q=$latitude,$longitude';

    try {
      if (Platform.isAndroid) {
        if (await canLaunchUrlString(googleMapsUrl)) {
          await launchUrlString(googleMapsUrl);
        } else {
          throw 'Could not open Google Maps.';
        }
      } else if (Platform.isIOS) {
        if (await canLaunchUrlString(appleMapsUrl)) {
          await launchUrlString(appleMapsUrl);
        } else {
          throw 'Could not open Apple Maps.';
        }
      } else {
        throw 'Unsupported platform.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open maps: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> openMapWithLocation(String location) async {
    String encodedLocation = Uri.encodeComponent(location);
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
    String appleMapsUrl = 'http://maps.apple.com/?q=$encodedLocation';

    try {
      if (Platform.isAndroid) {
        String googleMapsAppUrl = 'geo:0,0?q=$encodedLocation';
        if (await canLaunchUrlString(googleMapsAppUrl)) {
          await launchUrlString(googleMapsAppUrl);
        } else if (await canLaunchUrlString(googleMapsUrl)) {
          await launchUrlString(googleMapsUrl);
        } else {
          throw 'Could not launch Google Maps.';
        }
      } else if (Platform.isIOS) {
        if (await canLaunchUrlString(appleMapsUrl)) {
          await launchUrlString(appleMapsUrl);
        } else if (await canLaunchUrlString(googleMapsUrl)) {
          await launchUrlString(googleMapsUrl);
        } else {
          throw 'Could not launch Apple Maps or Google Maps.';
        }
      } else {
        throw 'Unsupported platform.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open maps: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        centerTitle: true,
        title: const Text(
          'Similar',
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
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: _buildBodyContent(),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding similar palaces...'),
          ],
        ),
      );
    }

    if (limitReached) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchSimilarRestaurants,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (restaurants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No similar palaces found',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return Column(
          children: [
            buildRestuarantWidget(index, restaurant),
            const SizedBox(height: 15),
          ],
        );
      },
    );
  }

  Widget buildRestuarantWidget(int index, Map<String, dynamic> restaurant) {
    final imageSliders = [
      Container(
        width: double.infinity,
        height: 200,
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        child: restaurant['image_url'] != null
            ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.network(
                  restaurant['image_url'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant, size: 50),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              )
            : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.restaurant, size: 50),
              ),
      )
    ];

    return Container(
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
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  initialPage: 0,
                  onPageChanged: (i, reason) {
                    setState(() {
                      restuarantCurrentPos[index] = i;
                    });
                  },
                ),
                items: imageSliders,
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
                          children: imageSliders.map((url) {
                            int indexS = imageSliders.indexOf(url);
                            return Container(
                              width: restuarantCurrentPos[index] == indexS
                                  ? 14
                                  : 8.0,
                              height: 8,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                                color: restuarantCurrentPos[index] == indexS
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFFA5A5A5),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isNameExpanded[index] = !isNameExpanded[index];
                          });
                        },
                        child: Text(
                          restaurant['name'] ?? 'Unknown',
                          style: const TextStyle(
                            color: Color(0xFF030917),
                            fontSize: 20,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: isNameExpanded[index] ? null : 1,
                          overflow: isNameExpanded[index]
                              ? null
                              : TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      width: 30,
                      height: 30,
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
                              restuarantCurrentPos[index] =
                                  restuarantCurrentPos[index] == 0 ? 1 : 0;
                            });
                          },
                          icon: restuarantCurrentPos[index] == 0
                              ? const Icon(Icons.keyboard_arrow_up_rounded)
                              : const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/star_rating.svg'),
                    const SizedBox(width: 10),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${restaurant['ratings'] ?? 'N/A'} ( Google ) • ',
                            style: const TextStyle(
                              color: Color(0xFF0A0A0A),
                              fontSize: 14,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: _getPriceLevel(
                                restaurant['price_level'] != "N/A"
                                    ? restaurant['price_level']
                                    : 0),
                            style: TextStyle(
                              color: _getPriceColor(
                                  restaurant['price_level'] != "N/A"
                                      ? restaurant['price_level']
                                      : 0),
                              fontSize: 14,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: restuarantCurrentPos[index] == 0,
                  child: const SizedBox(height: 10),
                ),
                Visibility(
                  visible: restuarantCurrentPos[index] == 0,
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/location.svg'),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          restaurant['formatted_address'] ??
                              'Address not available',
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
                Visibility(
                  visible: restuarantCurrentPos[index] == 0,
                  child: const SizedBox(height: 10),
                ),
                Visibility(
                  visible: restuarantCurrentPos[index] == 0,
                  // child: Row(
                  //   children: [
                  //     SvgPicture.asset('assets/icons/clock_fill.svg'),
                  //     const SizedBox(width: 10),
                  //     Expanded(
                  //       child: Row(
                  //         children: [
                  //           Text.rich(
                  //             TextSpan(
                  //               children: [
                  //                 TextSpan(
                  //                   text: restaurant['currently_open'] == true
                  //                       ? 'Open'
                  //                       : 'Closed',
                  //                   style: TextStyle(
                  //                     color:
                  //                         restaurant['currently_open'] == true
                  //                             ? const Color(0xFF54AB6A)
                  //                             : const Color(0xFFD93025),
                  //                     fontSize: 14,
                  //                     fontFamily: themeFontFamily2,
                  //                     fontWeight: FontWeight.w500,
                  //                   ),
                  //                 ),
                  //                 const TextSpan(
                  //                   text: ' • Closes 10:00 pm',
                  //                   style: TextStyle(
                  //                     color: Color(0xFF0A0A0A),
                  //                     fontSize: 14,
                  //                     fontFamily: themeFontFamily2,
                  //                     fontWeight: FontWeight.w400,
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //           const SizedBox(width: 10),
                  //           SeeHoursWidget(placeName: restaurant['name']),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/clock_fill.svg'),
                      // const SizedBox(width: 10),
                      // OpenStatusWidget(
                      //     placeName: restaurant['name']), // <-- New Widget
                      // const Text(' • ',
                      //     style: TextStyle(
                      //         color: Color(0xFF0A0A0A),
                      //         fontSize: 14,
                      //         fontFamily: themeFontFamily2,
                      //         fontWeight: FontWeight.w400)),
                      const SizedBox(width: 10),
                      SeeHoursWidget(placeName: restaurant['name']),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/wallet.svg'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _getPriceRange(restaurant['price_level']),
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
                Visibility(
                  visible: restuarantCurrentPos[index] != 0,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/location.svg'),
                          const SizedBox(width: 10),
                          const Text(
                            '2.5 kms away',
                            style: TextStyle(
                              color: Color(0xFF0A0A0A),
                              fontSize: 14,
                              fontFamily: themeFontFamily2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                Visibility(
                  visible: restuarantCurrentPos[index] == 0,
                  child: const SizedBox(height: 10),
                ),
                Visibility(
                  visible: restuarantCurrentPos[index] == 0,
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/sand_timer.svg'),
                      const SizedBox(width: 10),
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
                ),
                Visibility(
                  visible: restuarantCurrentPos[index] == 0,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // if (restaurant['lat'] != null &&
                              //     restaurant['long'] != null) {
                              //   _openMap(
                              //     double.parse(restaurant['lat'].toString()),
                              //     double.parse(restaurant['long'].toString()),
                              //   );
                              // } else {
                              openMapWithLocation(restaurant['name'] ?? '');
                              // }
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
                                  SvgPicture.asset(
                                      'assets/icons/directions.svg'),
                                  const SizedBox(width: 5),
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
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPriceLevel(int? level) {
    switch (level) {
      case 1:
        return 'Inexpensive';
      case 2:
        return 'Moderate';
      case 3:
        return 'Expensive';
      case 4:
        return 'Luxury';
      default:
        return 'N/A';
    }
  }

  Color _getPriceColor(int? level) {
    switch (level) {
      case 1:
        return const Color(0xFF4CAF50); // Green
      case 2:
        return const Color(0xFF2196F3); // Blue
      case 3:
        return const Color(0xFFFF9800); // Orange
      case 4:
        return const Color(0xFF9B27B0); // Red
      default:
        return const Color(0xFF0A0A0A); // Default text color
    }
  }

  String _getPriceRange(dynamic priceLevel) {
    if (priceLevel == null || priceLevel == 'N/A') return 'Price not available';
    if (priceLevel is String) return priceLevel;

    switch (priceLevel) {
      case 1:
        return '₹100-300 per person';
      case 2:
        return '₹300-600 per person';
      case 3:
        return '₹600-1200 per person';
      case 4:
        return '₹1200+ per person';
      default:
        return 'Price not available';
    }
  }
}

enum TrimMode { Line, Length }

class SeeHoursWidget extends StatefulWidget {
  final String placeName;

  const SeeHoursWidget({Key? key, required this.placeName}) : super(key: key);

  @override
  _SeeHoursWidgetState createState() => _SeeHoursWidgetState();
}

class _SeeHoursWidgetState extends State<SeeHoursWidget> {
  bool _isLoading = false;

  Future<Map<String, dynamic>> fetchOpenCloseInfo(String placeName) async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    String? userToken = await storage.read(key: 'userToken');

    final String apiUrl = '$baseurl/get-open-close-info/$placeName/$userToken';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "weekday_text": ["Not available"],
        };
      }
    } catch (e) {
      return {
        "weekday_text": ["Not available"],
      };
    }
  }

  void showOpenCloseInfoBottomSheet(
    BuildContext context,
    List<String> weekdayText,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // We use Monday as a reference for today (since DateTime.now().weekday is 1 for Monday)
        final int todayIndex = DateTime.now().weekday - 1;

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle for the bottom sheet
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Opening Hours',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Sora',
                  ),
                ),
                const SizedBox(height: 16),

                // List of hours
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: weekdayText.length,
                  itemBuilder: (context, index) {
                    final parts = weekdayText[index].split(': ');
                    final day = parts[0];
                    final time =
                        parts.length > 1 ? parts[1].trim() : 'Not available';

                    // --- CHANGE START ---
                    // 1. Split the time string by the comma to handle multiple entries.
                    final timeSlots = time.split(', ');
                    // --- CHANGE END ---

                    final bool isToday = (index == todayIndex);
                    final bool isClosed = time.toLowerCase() == 'closed';

                    final dayTextStyle = TextStyle(
                      fontSize: 16,
                      fontFamily: 'Sora',
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    );

                    final timeTextStyle = TextStyle(
                      fontSize: 16,
                      fontFamily: 'Sora',
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isClosed
                          ? Colors.red[700]
                          : (isToday
                              ? Theme.of(context).primaryColor
                              : Colors.grey[600]),
                    );

                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: isToday
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // --- CHANGE START ---
                      // 2. Use a Row that aligns its children to the top.
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // This is important
                        children: [
                          // Day of the week (stays the same)
                          Text(day, style: dayTextStyle),

                          // 3. Use a Column to stack the time slots vertically.
                          Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .end, // Aligns time to the right
                            children: timeSlots.map((slot) {
                              return Text(slot, style: timeTextStyle);
                            }).toList(),
                          ),
                        ],
                      ),
                      // --- CHANGE END ---
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

class OpenStatusWidget extends StatefulWidget {
  final String placeName;
  const OpenStatusWidget({Key? key, required this.placeName}) : super(key: key);

  @override
  _OpenStatusWidgetState createState() => _OpenStatusWidgetState();
}

class _OpenStatusWidgetState extends State<OpenStatusWidget> {
  bool? _isOpen;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<Map<String, dynamic>> fetchOpenCloseInfo(String placeName) async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    String? userToken = await storage.read(key: 'userToken');

    final String apiUrl = '$baseurl/get-open-close-info/$placeName/$userToken';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "weekday_text": ["Not available"],
        };
      }
    } catch (e) {
      return {
        "weekday_text": ["Not available"],
      };
    }
  }

  /// This method is called whenever the parent widget rebuilds and passes new data.
  @override
  void didUpdateWidget(covariant OpenStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the new placeName is different from the old one, fetch the status again.
    if (widget.placeName != oldWidget.placeName) {
      _fetchStatus();
    }
  }

  Future<void> _fetchStatus() async {
    // Set loading to true to show the indicator while fetching new data.
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final info = await fetchOpenCloseInfo(widget.placeName);

    // Check if the widget is still on screen before updating the state.
    if (mounted) {
      setState(() {
        _isOpen = info?['open_now'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 14,
        height: 14,
        child:
            CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF005CE7)),
      );
    }

    if (_isOpen == null) {
      return const Text("N/A",
          style: TextStyle(fontSize: 14, color: Colors.grey));
    }

    return Text(
      _isOpen! ? 'Open' : 'Closed',
      style: TextStyle(
        color: _isOpen! ? const Color(0xFF54AB6A) : const Color(0xFFD93025),
        fontSize: 14,
        fontFamily: themeFontFamily2,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
