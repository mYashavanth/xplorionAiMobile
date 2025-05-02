import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:xplorion_ai/widgets/create_itinerary_widgets/create_itenerary_travel_companions.dart';
import 'package:xplorion_ai/widgets/create_itinerary_widgets/create_itinerary_budget_limit.dart';
import 'package:xplorion_ai/widgets/create_itinerary_widgets/create_itinerary_select_date_range_widget.dart';
import 'package:http/http.dart' as http;

class CreateItinerary extends StatefulWidget {
  const CreateItinerary({super.key});

  @override
  State<CreateItinerary> createState() => _CreateItineraryState();
}

class _CreateItineraryState extends State<CreateItinerary> {
  PageController pageController = PageController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  int _curr = 0;

  bool locationTaken = false;

  String location = 'Please Choose Location';

  /*
  !locationTaken
            ? const Text(
                'Choose your location',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 20,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w600,
                  // height: 0,
                ),
              )
            :
  *
  * */

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            setState(() {
              if (_curr <= 0) {
                Navigator.of(context).pop();
                return;
              }
              _curr -= 1;
              pageController.animateToPage(
                _curr,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            });
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 30,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              // width: 104,
              child: Text(
                'Itinerary for',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              location,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1F1F1F),
                fontSize: 13,
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(0),
                  width: double.maxFinite,
                  height: 8,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    // color: const Color(0xFFECF2FF),
                    gradient: themeGradientColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(0),
                  width: double.maxFinite,
                  height: 8,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    gradient: _curr > 0
                        ? themeGradientColor
                        : remainCITabGradientColor,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(0),
                  width: double.maxFinite,
                  height: 8,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    gradient: _curr > 1
                        ? themeGradientColor
                        : remainCITabGradientColor,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(0),
                  width: double.maxFinite,
                  height: 8,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    gradient: _curr > 2
                        ? themeGradientColor
                        : remainCITabGradientColor,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          SelectDateRange(pageController),
          CreateIteneraryTravelCompanions(pageController),
          CreateItineraryBudgetLimit(pageController),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Container(
          width: double.maxFinite,
          height: 56,
          decoration: ShapeDecoration(
            gradient: themeGradientColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            onPressed: () async {
              String? placeName = await storage.read(key: 'selectedPlace');
              String? startDate = await storage.read(key: 'startDate');
              String? endDate = await storage.read(key: 'endDate');

              if (placeName == null || placeName!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please Select Place Name'),
                  duration: Duration(seconds: 3),
                ));

                return;
              }

              if (startDate == null || startDate!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please Select Start Date'),
                  duration: Duration(seconds: 3),
                ));

                return;
              }

              if (endDate == null || endDate!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please Select End Date'),
                  duration: Duration(seconds: 3),
                ));

                return;
              }

              setState(() {
                location = placeName;
                if (_curr >= 2) {
                  Navigator.of(context).pushReplacementNamed('/home_page_trip');
                }
                locationTaken = true;
                _curr += 1;
                pageController.animateToPage(
                  _curr,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              });
            },
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w600,
                // height: 0.16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
