import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/widgets/gradient_text.dart';

class ItineraryGeneratingScreen extends StatefulWidget {
  const ItineraryGeneratingScreen({super.key});

  @override
  State<ItineraryGeneratingScreen> createState() =>
      _ItineraryGeneratingScreenState();
}

class _ItineraryGeneratingScreenState extends State<ItineraryGeneratingScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(const Duration(seconds: 3), () {
      storage.write(key: 'itinerarySavedFlag', value: '0');

      Navigator.of(context).pushNamed('/home_page_trip');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mediaWidth = MediaQuery.of(context).size.width;
    var mediaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        // height: mediaHeight,
        // color: Colors.red,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Container(
              // color: Colors.green,
              height: mediaHeight * 0.4,
              child: Stack(
                children: [
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Opacity(
                        opacity: 0.50,
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          height: 247,
                          width: 247,
                          decoration: const ShapeDecoration(
                            gradient: themeGradientColorReverse,
                            shape: OvalBorder(),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(35),
                            width: double.maxFinite,
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: OvalBorder(),
                            ),
                            child: Container(
                              width: double.maxFinite,
                              decoration: const ShapeDecoration(
                                gradient: themeGradientColor,
                                shape: OvalBorder(),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/star_gradient.svg',
                                  width: 50,
                                  height: 50,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.white, BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      //
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 247,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white
                                    .withOpacity(0.0), // Fully transparent
                                Colors.white.withOpacity(0.0), // Light white
                                Colors.white.withOpacity(0.0), // Light white
                                Colors.white.withOpacity(0.9), // Light white
                                Colors.white, // Fully white
                                Colors.white, // Fully white
                              ],
                              stops: const [
                                0.0,
                                0.1,
                                0.2,
                                0.6,
                                0.8,
                                1.0,
                              ], // Adjusts the position of the color stops
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //
                  Positioned(
                    left: 30,
                    top: 40,
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: OvalBorder(
                          side: BorderSide(
                            width: 5,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            color: Color(0xFFF0ECE4),
                          ),
                        ),
                      ),
                      child: SvgPicture.asset('assets/icons/globe.svg'),
                    ),
                  ),

                  //
                  Positioned(
                    right: 90,
                    top: 1,
                    child: Container(
                      width: 35,
                      height: 35,
                      padding: const EdgeInsets.all(5),
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: OvalBorder(
                          side: BorderSide(
                            width: 5,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            color: Color(0xFFE0ECF3),
                          ),
                        ),
                      ),
                      child: SvgPicture.asset('assets/icons/passport.svg'),
                    ),
                  ),

                  //
                  Positioned(
                    right: 30,
                    bottom: 100,
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(4),
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: OvalBorder(
                          side: BorderSide(
                            width: 5,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            color: Color(0xFFF0E9F2),
                          ),
                        ),
                      ),
                      child: SvgPicture.asset('assets/icons/camera.svg'),
                    ),
                  ),

                  //
                  Positioned(
                    left: 50,
                    bottom: 80,
                    child: Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.all(5),
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: OvalBorder(
                          side: BorderSide(
                            width: 5,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            color: Color(0xFFDBEBED),
                          ),
                        ),
                      ),
                      child: SvgPicture.asset('assets/icons/bags.svg'),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Generating your Itinerary',
              style: TextStyle(
                color: Color(0xFF030917),
                fontSize: 20,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w600,
                // height: 0.06,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Kochin (Cochin) is a great choice! \nWe’re gathering popular things\nto do and more...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
                // height: 0.09,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 120,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const GradientText(
              '88% completed ',
              gradient: themeGradientColor,
              style: TextStyle(
                color: Color(0xFF54AB6A),
                fontSize: 16,
                fontFamily: themeFontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 20,
              width: MediaQuery.of(context).size.width,
              decoration: ShapeDecoration(
                color: const Color(0xFFECF2FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.75,
                    decoration: ShapeDecoration(
                      // color: const Color(0xFFECF2FF),
                      gradient: themeGradientColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Creating your custom AI travel plan...',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 16,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
