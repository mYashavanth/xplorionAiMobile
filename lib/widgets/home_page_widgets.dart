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

const storage = FlutterSecureStorage();

Widget topBannerCard(status, heading, note, image, fromDate, toDate,
    travelCompanion, budgetType, currentLocation, context) {
  return GestureDetector(
      onTap: () async {
        print(
            "$travelCompanion ---- $budgetType ----- $fromDate ---- $toDate ---- $currentLocation ---- $heading");

        //String? userToken = await storage.read(key: 'userToken');
        await storage.write(key: 'travelCompanion', value: travelCompanion);
        await storage.write(key: 'budgetTier', value: budgetType);
        await storage.write(key: 'startDate', value: fromDate);
        await storage.write(key: 'endDate', value: toDate);
        await storage.write(key: 'selectedPlace', value: currentLocation);
        storage.write(key: 'itinerarySavedFlag', value: '0');

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pushNamed('/home_page_trip');
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
        padding: const EdgeInsets.all(0),
        // height: 184,
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
                    image: NetworkImage(
                        '$baseurl/banner-images/$image'), //AssetImage('assets/images/$image'),
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
                  Container(
                    padding: const EdgeInsets.only(
                        top: 5, bottom: 5, left: 10, right: 10),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF005CE7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w700,
                        // height: 0.15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
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
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 240,
                    child: Text(
                      note,
                      style: const TextStyle(
                        color: Color(0xFFEDF2FE),
                        fontSize: 14,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w400,
                        // height: 0.12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                      margin: const EdgeInsets.only(top: 10),
                      // padding: const EdgeInsets.all(10),
                      width: 60,
                      height: 30,
                      // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      )),
                ],
              ),
            ),
            // const Positioned(
            //   bottom: 0,
            //   right: 0,
            //   child: Image(
            //     image: AssetImage('assets/icons/robo_girl.png'),
            //   ),
            // ),
          ],
        ),
      ));
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
          // height: 116,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            image: DecorationImage(
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage("assets/images/panjim_goa.jpeg")
                      as ImageProvider,
              fit: BoxFit.fill,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

Widget weekendTripsNearYouCard(
    image, title, noOfDays, cityState, distanceFromPlace, activities, context) {
  List<DateTime> getWeekendDates() {
    final now = DateTime.now();
    // Find the first day of the week (Monday).
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Calculate Saturday and Sunday.
    final saturday = firstDayOfWeek.add(const Duration(days: 5));
    final sunday = firstDayOfWeek.add(const Duration(days: 6));

    return [saturday, sunday];
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
        InkWell(
          onTap: () async {
            await storage.write(key: 'selectedPlace', value: cityState);

            // Format and print the weekend dates.
            final weekendDates = getWeekendDates();
            final formatter = DateFormat('d MMM');

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
              image: NetworkImage(image),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            await storage.write(key: 'selectedPlace', value: cityState);

            // Format and print the weekend dates.
            final weekendDates = getWeekendDates();
            final formatter = DateFormat('d MMM');

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
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF030917),
                        fontSize: 16,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w500,
                        // height: 0.09,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/calendar.svg',
                      height: 13,
                      width: 13,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      '$noOfDays Day',
                      style: const TextStyle(
                        color: Color(0xFF8B8D98),
                        fontSize: 12,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w400,
                        // height: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/location.svg',
                      height: 13,
                      width: 13,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      cityState,
                      style: const TextStyle(
                        color: Color(0xFF8B8D98),
                        fontSize: 12,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w400,
                        // height: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/route.svg',
                      height: 13,
                      width: 13,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      distanceFromPlace,
                      style: const TextStyle(
                        color: Color(0xFF8B8D98),
                        fontSize: 12,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w400,
                        // height: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/escape.svg',
                      height: 13,
                      width: 13,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        activities,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: Color(0xFF8B8D98),
                          fontSize: 12,
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w400,
                          // height: 0,
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
            // color: Color(0xFF005CE7),
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
              Icon(
                Icons.flash_on,
                color: Colors.white,
              ),
              SizedBox(width: 12),
              Text(
                'Viewed 14 times today',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                  height: 0,
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
                  image: NetworkImage("$image"),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(''),
            )),
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
                  Colors.black.withOpacity(0.0), // Fully transparent
                  Colors.black.withOpacity(0.1), // Light white
                  Colors.black.withOpacity(0.3), // Light white
                  Colors.black.withOpacity(0.5), // Light white
                  Colors.black.withOpacity(0.7), // Light white
                  Colors.black.withOpacity(0.9), // Light white
                  // Fully white
                ],
                stops: const [
                  0.0,
                  0.1,
                  0.2,
                  0.3,
                  0.5,
                  1.0,
                ], // Adjusts the position of the color stops
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Split the title into two parts based on space
              Text(
                title.split(" ")[0], // First part (bold)
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w600, // Bold
                ),
              ),
              Text(
                title.split(" ").length > 1
                    ? title.split(" ")[1]
                    : "", // Second part (normal)
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w400, // Normal
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
