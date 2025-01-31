import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';

class SimilarRestuarants extends StatefulWidget {
  const SimilarRestuarants({super.key});

  @override
  State<SimilarRestuarants> createState() => _SimilarRestuarantsState();
}

class _SimilarRestuarantsState extends State<SimilarRestuarants> {
  List<int> restuarantCurrentPos = [0, 0,0,0];

  List<String> resturantImages1 = ['dose.jpeg', 'idli.jpeg','poori.jpeg','bread_toast.jpeg'];
  List<Widget> restuarantImageWidgets1 = [];

  List<String> resturantImages2 = ['idli.jpeg','dose.jpeg','bread_toast.jpeg'];
  List<Widget> restuarantImageWidgets2 = [];

  List<String> resturantImages3 = ['poori.jpeg','idli.jpeg','dose.jpeg'];
  List<Widget> restuarantImageWidgets3 = [];

  List<String> resturantImages4 = ['bread_toast.jpeg'];
  List<Widget> restuarantImageWidgets4 = [];

  List<bool> resturantExpandWidget = [true, false,true,false];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void getData() {
    resturantImages1
        .map(
          (item) => restuarantImageWidgets1.add(
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/$item"),
                  fit: BoxFit.cover,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();


    resturantImages2
        .map(
          (item) => restuarantImageWidgets2.add(
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/$item"),
                  fit: BoxFit.cover,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();



    resturantImages3
        .map(
          (item) => restuarantImageWidgets3.add(
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/$item"),
                  fit: BoxFit.cover,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();


    resturantImages4
        .map(
          (item) => restuarantImageWidgets4.add(
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/$item"),
                  fit: BoxFit.cover,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Similar Restaurants',
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
        padding: const EdgeInsets.only(left:15,right:15),
        child: ListView(
          children: [
            buildRestuarantWidget(
                0, 'Mavalli Tiffin Room (MTR)', true, restuarantImageWidgets1),
                const SizedBox(height: 15,),
            buildRestuarantWidget(
                1, 'Indraprastha', false, restuarantImageWidgets2),
                const SizedBox(height: 15,),
            buildRestuarantWidget(
                2, 'Kadamba Veg', false, restuarantImageWidgets3),
                const SizedBox(height: 15,),
            buildRestuarantWidget(
                3 , 'Shanthi Sagar', true, restuarantImageWidgets4),
                const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  Widget buildRestuarantWidget(index, title, open, List<Widget> imageSliders) {
    return Container(
      // height: 590,
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
                  // height: 200,
                  // aspectRatio: 1,
                  // enlargeCenterPage: true,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  initialPage: 0,
                  // autoPlay: true,
                  onPageChanged: (i, reason) {
                    setState(
                      () {
                        restuarantCurrentPos[index] = i;
                      },
                    );
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
                          children: imageSliders.map(
                            (url) {
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
                                  // shape: BoxShape.circle,
                                  color: restuarantCurrentPos[index] == indexS
                                      ? const Color(0xFFFFFFFF)
                                      : const Color(0xFFA5A5A5),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
            ],
          ),
          //

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
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
                      // padding: const EdgeInsets.all(8),
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
                              resturantExpandWidget[index] =
                                  !resturantExpandWidget[index];
                            });
                          },
                          icon: resturantExpandWidget[index]
                              ? const Icon(Icons.keyboard_arrow_up_rounded)
                              : const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),

                //
                Row(
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
                          'Park',
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
                      height: 26,
                      margin: const EdgeInsets.only(right: 8),
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
                          'Garden',
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
                      height: 26,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFEFEFEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          title,
                          style: const TextStyle(
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
                //

                Visibility(
                  visible: resturantExpandWidget[index],
                  child: const Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Simple restaurant serving classic tiffin dishes, such as rava idli, masala dosa & chandrahara.',
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

                const SizedBox(
                  height: 10,
                ),

                //
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/star_rating.svg'),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      '4.3 (36,347) • ₹₹',
                      style: TextStyle(
                        color: Color(0xFF0A0A0A),
                        fontSize: 14,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                //

                Visibility(
                  visible: resturantExpandWidget[index],
                  child: const SizedBox(
                    height: 10,
                  ),
                ),

                //
                Visibility(
                  visible: resturantExpandWidget[index],
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/location.svg'),
                      const SizedBox(
                        width: 10,
                      ),
                      const Expanded(
                        child: Text(
                          '14, Lal Bagh Main Rd, Doddamavalli, Sudhama Nagar, Bengaluru, Karnataka 560027',
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

                //

                Visibility(
                  visible: resturantExpandWidget[index],
                  child: const SizedBox(
                    height: 10,
                  ),
                ),

                //
                Visibility(
                  visible: resturantExpandWidget[index],
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/clock_fill.svg'),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: open ? 'Open' : 'Closed',
                                    style: TextStyle(
                                      color: open
                                          ? Color(0xFF54AB6A)
                                          : Color(0xFFD93025),
                                      fontSize: 14,
                                      fontFamily: themeFontFamily2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' • Closes 8:30 pm',
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
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //

                const SizedBox(
                  height: 10,
                ),

                //
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/wallet.svg'),
                    const SizedBox(
                      width: 10,
                    ),
                    const Expanded(
                      child: Text(
                        '₹200-400 per person',
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

                Visibility(
                  visible: resturantExpandWidget[index],
                  child: const SizedBox(
                    height: 10,
                  ),
                ),

                Visibility(
                  visible: !resturantExpandWidget[index],
                  child: Row(
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset('assets/icons/location.svg'),
                          const SizedBox(
                            width: 10,
                          ),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/icons/replace.svg'),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Replace',
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
                ),

                Visibility(
                  visible: resturantExpandWidget[index],
                  child: const SizedBox(
                    height: 10,
                  ),
                ),

                //
                Visibility(
                  visible: resturantExpandWidget[index],
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/icons/sand_timer.svg'),
                      const SizedBox(
                        width: 10,
                      ),
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
                //

                Visibility(
                  visible: resturantExpandWidget[index],
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                  
                      Row(
                        // mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset('assets/icons/replace.svg'),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  'Replace',
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
                          //
                        ],
                      ),
                      //
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
}
