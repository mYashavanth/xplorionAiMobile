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
      }
    });
  }

  Future<void> fetchSimilarRestaurants() async {
    try {
      final token = await storage.read(key: 'userToken');
      if (token == null) {
        throw Exception('User token not found');
      }

      final response = await http.get(
        Uri.parse(
            '$baseurl/similer-resturant/${Uri.encodeComponent('$placeName $place')}/$token'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          restaurants = data;
          restuarantCurrentPos = List<int>.filled(data.length, 0);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load restaurants: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load restaurants: ${e.toString()}';
        isLoading = false;
      });
    }
  }

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
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (restaurants.isEmpty) {
      return const Center(child: Text('No similar restaurants found'));
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
                ),
              )
            : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.restaurant, size: 50),
              ),
      )
    ];

    final isExpanded = index == 0; // Expand first item by default

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
                    Text(
                      restaurant['name'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Color(0xFF030917),
                        fontSize: 20,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w500,
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
                              // Toggle expanded state
                              if (restuarantCurrentPos[index] == 0) {
                                restuarantCurrentPos[index] = 1;
                              } else {
                                restuarantCurrentPos[index] = 0;
                              }
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
                          'Restaurant',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                            fontFamily: themeFontFamily2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: restuarantCurrentPos[index] == 0,
                  child: const Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'A great place to enjoy delicious food and drinks.',
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/star_rating.svg'),
                    const SizedBox(width: 10),
                    Text(
                      '${restaurant['rating'] ?? 'N/A'} (${restaurant['ratings'] ?? '0'}) • ${_getPriceLevel(restaurant['price_level'])}',
                      style: const TextStyle(
                        color: Color(0xFF0A0A0A),
                        fontSize: 14,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w400,
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
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/clock_fill.svg'),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: restaurant['currently_open'] == true
                                        ? 'Open'
                                        : 'Closed',
                                    style: TextStyle(
                                      color:
                                          restaurant['currently_open'] == true
                                              ? Color(0xFF54AB6A)
                                              : Color(0xFFD93025),
                                      fontSize: 14,
                                      fontFamily: themeFontFamily2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' • Closes 10:00 pm',
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
                            const SizedBox(width: 10),
                            SeeHoursWidget(placeName: restaurant['name']),
                          ],
                        ),
                      ),
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
                      // Container(
                      //   height: 32,
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 12, vertical: 4),
                      //   decoration: ShapeDecoration(
                      //     color: const Color(0xFFECF2FF),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(32),
                      //     ),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       SvgPicture.asset('assets/icons/replace.svg'),
                      //       const SizedBox(width: 5),
                      //       const Text(
                      //         'Replace',
                      //         style: TextStyle(
                      //           color: Color(0xFF005CE7),
                      //           fontSize: 12,
                      //           fontFamily: themeFontFamily,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
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
                              _openMap(restaurant['lat'], restaurant['long']);
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
                          // Container(
                          //   height: 32,
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 12, vertical: 4),
                          //   decoration: ShapeDecoration(
                          //     color: const Color(0xFFECF2FF),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(32),
                          //     ),
                          //   ),
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       SvgPicture.asset('assets/icons/replace.svg'),
                          //       const SizedBox(width: 5),
                          //       const Text(
                          //         'Replace',
                          //         style: TextStyle(
                          //           color: Color(0xFF005CE7),
                          //           fontSize: 12,
                          //           fontFamily: themeFontFamily,
                          //           fontWeight: FontWeight.w500,
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
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

  String _getPriceLevel(dynamic priceLevel) {
    if (priceLevel == null || priceLevel == 'N/A') return '';
    if (priceLevel is String) return priceLevel;
    return '₹' * (priceLevel as int);
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
