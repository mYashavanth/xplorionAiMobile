import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:intl/intl.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'dart:math';

const storage = FlutterSecureStorage();

Widget topBannerCard(status, heading, note, image, fromDate, toDate,
    travelCompanion, budgetType, currentLocation, context) {
  bool isBannerClickable = true;
  return GestureDetector(
    onTap: () async {
      if (!isBannerClickable) return; // Prevent multiple clicks
      isBannerClickable = false; // Disable further clicks
      if (currentLocation == 'Loading location...') {
        // Show a message or handle the case where location is not available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait, location is being fetched...'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      try {
        print(
            "$travelCompanion ---- $budgetType ----- $fromDate ---- $toDate ---- $currentLocation ---- $heading");
        final List<String> words =
            currentLocation.replaceAll(RegExp(r','), "").split(" ");
        final String location = words.sublist(words.length - 5).join(' ');

        print(location);
        await storage.write(key: 'travelCompanion', value: travelCompanion);
        await storage.write(key: 'budgetTier', value: budgetType);
        await storage.write(key: 'startDate', value: fromDate);
        await storage.write(key: 'endDate', value: toDate);
        await storage.write(key: 'selectedPlace', value: location);
        storage.write(key: 'itinerarySavedFlag', value: '0');

        // Navigate to the next screen
        await Navigator.of(context).pushNamed('/home_page_trip');
      } catch (e) {
        print("Error during navigation: $e");
      } finally {
        isBannerClickable = true; // Re-enable clicks after navigation
      }
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
      padding: const EdgeInsets.all(0),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x33BCB080),
            blurRadius: 8,
            offset: Offset(1, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Stack(
        children: [
          SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Stack(
              children: [
                Image(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  fit: BoxFit.cover,
                  image:
                      NetworkImage(image), //AssetImage('assets/images/$image'),
                ),
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
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   padding: const EdgeInsets.only(
                //       top: 5, bottom: 5, left: 10, right: 10),
                //   decoration: ShapeDecoration(
                //     color: const Color(0xFF005CE7),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(24),
                //     ),
                //   ),
                //   child: Text(
                //     status,
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontSize: 10,
                //       fontFamily: themeFontFamily2,
                //       fontWeight: FontWeight.w700,
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 8,
                // ),
                SizedBox(
                  child: Text(
                    heading,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: themeFontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // const SizedBox(height: 8),
                // SizedBox(
                //   width: 240,
                //   child: Text(
                //     note,
                //     maxLines: 3,
                //     overflow: TextOverflow.ellipsis,
                //     style: const TextStyle(
                //       color: Color(0xFFEDF2FE),
                //       fontSize: 14,
                //       fontFamily: themeFontFamily2,
                //       fontWeight: FontWeight.w400,
                //     ),
                //   ),
                // ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 60,
                    height: 30,
                    decoration: ShapeDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment(-1.00, 0.06),
                        end: Alignment(1, -0.06),
                        colors: [
                          Color(0xFF0099FF),
                          Color(0xFF54AB6A),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget singleCardPlan(context, imageUrl, placeName, noOfDays, dayDate,
    travelCompanion, itineraryId) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.all(12),
    // height: 144,
    // clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          width: 1,
          color: Color(0xFFCDCED7),
        ),
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.240,
          height: 116,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                  )
                : Image.asset(
                    "assets/images/panjim_goa.jpeg",
                    fit: BoxFit.fill,
                  ),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.54,
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      placeName,
                      style: const TextStyle(
                        color: Color(0xFF030917),
                        fontSize: 16,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // const Spacer(),
                  // InkWell(
                  //   onTap: () {},
                  //   child: const Center(
                  //     child: Icon(
                  //       Icons.more_horiz,
                  //       color: Color(0xFF8B8D98),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              'Starts at $dayDate ($noOfDays days)',
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 8,
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
              height: 8,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.54,
              child: Row(
                children: [
                  SizedBox(
                    width: 47,
                    height: 28,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed('/friends');
                      },
                      child: Stack(
                        children: [
                          // Positioned(
                          //   left: 0,
                          //   top: 0,
                          //   child: Container(
                          //     width: 28,
                          //     height: 28,
                          //     decoration: const ShapeDecoration(
                          //       image: DecorationImage(
                          //         image: AssetImage(
                          //             "assets/images/friend_photo.jpeg"),
                          //         fit: BoxFit.fill,
                          //       ),
                          //       shape: OvalBorder(
                          //         side: BorderSide(
                          //           width: 1,
                          //           strokeAlign: BorderSide.strokeAlignOutside,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Positioned(
                            // left: 19,
                            left: 0,
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
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      /*storage.write(
                          key: 'itinerarySavedFlag',
                          value: '1'
                      );

                      storage.write(
                          key: 'itineraryId',
                          value: itineraryId
                      ); */
                      storage.write(key: 'selectedPlace', value: placeName);
                      print("palceName: $placeName");
                      print("itineraryId: $itineraryId");
                      Navigator.of(context).pushNamed('/home_page_trip',
                          arguments: {
                            'itinerarySavedFlag': 1,
                            'itineraryId': itineraryId
                          });
                    },
                    child: Container(
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
                  )
                ],
              ),
            ),
          ],
        )
      ],
    ),
  );
}

Widget weekendTripsNearYouCard(image, title, noOfDays, cityState,
    distanceFromPlace, activities, context, category) {
  // List of fallback images
  final List<String> fallbackImages = [
    'assets/images/weekendTrips/21.jpg',
    'assets/images/weekendTrips/1500.jpg',
    'assets/images/weekendTrips/7353.jpg',
    'assets/images/weekendTrips/9109.jpg',
    'assets/images/weekendTrips/9115.jpg',
    'assets/images/weekendTrips/18468.jpg',
    'assets/images/weekendTrips/2149417763.jpg',
  ];

  // Function to get a random fallback image
  String getRandomFallbackImage() {
    final random = Random();
    print(
        "##################################  Fallback images: $fallbackImages, $random");
    return fallbackImages[random.nextInt(fallbackImages.length)];
  }

  // Function to check if image is dummy
  bool isDummyImage(String imageUrl) {
    return imageUrl.contains('dummy') ||
        imageUrl.contains('placeholder') ||
        imageUrl.isEmpty;
  }

  List<DateTime> getWeekendDates() {
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    print('noofDays: $noOfDays');

    if (noOfDays == "3") {
      // Friday, Saturday, Sunday
      final friday = firstDayOfWeek.add(const Duration(days: 4));
      final sunday = firstDayOfWeek.add(const Duration(days: 6));
      print('Friday: $friday, Sunday: $sunday');
      return [friday, sunday];
    } else if (noOfDays == "2") {
      // Saturday, Sunday
      final saturday = firstDayOfWeek.add(const Duration(days: 5));
      final sunday = firstDayOfWeek.add(const Duration(days: 6));
      print('Saturday: $saturday, Sunday: $sunday');
      return [saturday, sunday];
    } else {
      // Only Saturday
      final saturday = firstDayOfWeek.add(const Duration(days: 5));
      print('Saturday: $saturday');
      return [saturday, saturday];
    }
  }

  Color getCategoryColor(String category) {
    final colors = {
      'Adventure': const Color(0xFF4CAF50),
      'Relaxation': const Color(0xFF2196F3),
      'Cultural': const Color(0xFF9C27B0),
      'Food': const Color(0xFFF44336),
      'Nature': const Color(0xFF8BC34A),
    };
    // return colors[category] ?? const Color(0xFF607D8B);
    return const Color(0xFF4CAF50); // Default color if not found
  }

  return Container(
    margin: const EdgeInsets.only(right: 10),
    height: 410,
    width: 291,
    padding: const EdgeInsets.all(0),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    child: Column(
      children: [
        Stack(
          children: [
            InkWell(
              onTap: () async {
                await storage.write(key: 'selectedPlace', value: cityState);
                final weekendDates = getWeekendDates();
                final formatter = DateFormat('yyyy-MM-dd');
                await storage.write(
                    key: 'startDate', value: formatter.format(weekendDates[0]));
                await storage.write(
                    key: 'endDate', value: formatter.format(weekendDates[1]));
                Navigator.of(context).pushNamed('/create_itinerary');
              },
              child: Container(
                padding: EdgeInsets.all(0),
                clipBehavior: Clip.antiAlias,
                decoration: const ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                    ),
                  ),
                ),
                width: double.infinity,
                height: 186,
                child: Image(
                  fit: BoxFit.fill,
                  image: isDummyImage(image)
                      ? AssetImage(getRandomFallbackImage())
                      : NetworkImage(image),
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      getRandomFallbackImage(),
                      fit: BoxFit.fill,
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getCategoryColor(category),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        // Rest of your widget code remains the same...
        InkWell(
          onTap: () async {
            await storage.write(key: 'selectedPlace', value: cityState);
            final weekendDates = getWeekendDates();
            final formatter = DateFormat('yyyy-MM-dd');
            await storage.write(
                key: 'startDate', value: formatter.format(weekendDates[0]));
            await storage.write(
                key: 'endDate', value: formatter.format(weekendDates[1]));
            Navigator.of(context).pushNamed('/create_itinerary');
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 250,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF030917),
                          fontSize: 16,
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/calendar.svg',
                      height: 13,
                      width: 13,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$noOfDays Day',
                      style: const TextStyle(
                        color: Color(0xFF8B8D98),
                        fontSize: 12,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/location.svg',
                      height: 13,
                      width: 13,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      cityState,
                      style: const TextStyle(
                        color: Color(0xFF8B8D98),
                        fontSize: 12,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/route.svg',
                      height: 13,
                      width: 13,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      distanceFromPlace,
                      style: const TextStyle(
                        color: Color(0xFF8B8D98),
                        fontSize: 12,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/escape.svg',
                      height: 13,
                      width: 13,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        activities,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: Color(0xFF8B8D98),
                          fontSize: 12,
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 291,
          height: 43,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const ShapeDecoration(
            gradient: themeGradientColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(23),
                bottomRight: Radius.circular(23),
              ),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.flash_on, color: Colors.white),
              SizedBox(width: 12),
              Text(
                "Curated by XplorionAi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget popularDestinationsNearby(image, title, context) {
  // List of fallback images
  final List<String> fallbackImages = [
    'assets/images/popularDestinations/354.jpg',
    'assets/images/popularDestinations/39550.jpg',
    'assets/images/popularDestinations/2149211337.jpg',
    'assets/images/popularDestinations/2150456198.jpg',
  ];

  // Function to get a random fallback image
  String getRandomFallbackImage() {
    final random = Random();
    print(
        "##################################  Fallback images: $fallbackImages, $random");
    return fallbackImages[random.nextInt(fallbackImages.length)];
  }

  // Function to check if image is missing or invalid
  bool isInvalidImage(String imageUrl) {
    return imageUrl.isEmpty ||
        imageUrl.contains('dummy') ||
        imageUrl.contains('placeholder');
  }

  return Container(
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    margin: const EdgeInsets.only(right: 10),
    child: Stack(
      alignment: Alignment.center,
      children: [
        InkWell(
          onTap: () async {
            await storage.write(key: 'selectedPlace', value: title);
            Navigator.of(context).pushNamed('/create_itinerary');
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 152,
            height: 230,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: isInvalidImage(image)
                    ? AssetImage(getRandomFallbackImage())
                    : NetworkImage(image),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Builder(
              builder: (context) {
                if (isInvalidImage(image)) {
                  return Image.asset(
                    getRandomFallbackImage(),
                    fit: BoxFit.cover,
                  );
                }
                return Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      getRandomFallbackImage(),
                      fit: BoxFit.cover,
                    );
                  },
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            width: 152,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.1, 0.2, 0.3, 0.5, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.split(" ")[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                title.split(" ").length > 1 ? title.split(" ")[1] : "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
