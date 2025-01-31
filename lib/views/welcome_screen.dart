import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Stack(
                children: [
                  const Image(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/welcome_screen_pic_sea.png'),
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
            Column(
              children: [
                const SizedBox(
                  height: 80,
                ),
                Container(
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 8,
                    child:  Wrap(
                      children: [
                        const Text(
                          'Craft your ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w700,
                            // height: 0.04,
                          ),
                        ),
                        const Text(
                          'perfect ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w700,
                            // height: 0.04,
                          ),
                        ),
                        Text(
                          'Journey ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w700,
                            // height: 0.04,
                          ),
                        ),
                        Text(
                          'with ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w700,
                            // height: 0.04,
                          ),
                        ),
                        Text(
                          'our ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w700,
                            // height: 0.04,
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontFamily: themeFontFamily,
                                  fontWeight: FontWeight.w700,
                                  // height: 0.04,
                                ),
                              ),
                              SizedBox(width: 5),
                              // Image(
                              //   width: 20.88,
                              //   height: 20.38,
                              //   image: AssetImage('assets/icons/stars.png'),
                              // ),
                              SvgPicture.asset('assets/icons/star_gradient.svg',color: Colors.white,width:23.8),
                            ],
                          ),
                        ),
                        Text(
                          ' Itinerary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w700,
                            // height: 0.04,
                          ),
                        ),
                        Text(
                          ' Generator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: themeFontFamily,
                            fontWeight: FontWeight.w700,
                            // height: 0.04,
                          ),
                        ),
                      ],
                    )),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  width: MediaQuery.of(context).size.width * 8,
                  child: const Text(
                    'Effortlessly plan your adventure with personalized recommendations',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: themeFontFamily2,
                      fontWeight: FontWeight.w400,
                      // height: 0.09,
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/home_page');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    width: double.maxFinite,
                    height: 56,
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
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Get started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w600,
                            height: 0.16,
                          ),
                        ),
                        SizedBox(width: 10),
                        Image(
                          width: 16.88,
                          height: 17.38,
                          image: AssetImage('assets/icons/stars.png'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
