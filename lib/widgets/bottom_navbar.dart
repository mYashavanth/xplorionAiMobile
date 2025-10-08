import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/widgets/gradient_text.dart';

class TripssistNavigationBar extends StatefulWidget {
  final int selected;
  const TripssistNavigationBar(this.selected, {super.key});

  @override
  State<TripssistNavigationBar> createState() => _TripssistNavigationBarState();
}

class _TripssistNavigationBarState extends State<TripssistNavigationBar> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  int _selectedIndex = 0;
  @override
  void initState() {
    _selectedIndex = widget.selected;
    setState(() {});
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      if (_selectedIndex == index) {
        return;
      }

      switch (index) {
        case 0:
          Navigator.of(context).popUntil((route) => route.isFirst);
        //Navigator.of(context).pushNamed('/home_page');
        case 1:
          _clearStoredData();
        case 2:
          Navigator.of(context).pushNamed('/profile');
      }
    });
  }

  Future<void> _clearStoredData() async {
    await storage.delete(key: 'selectedPlace');
    await storage.delete(key: 'startDate');
    await storage.delete(key: 'endDate');
    Navigator.of(context).pushNamed('/create_itinerary');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            width: 0.5,
            color: Color.fromARGB(138, 205, 203, 203),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //first
          InkWell(
            onTap: () {
              _onItemTapped(0);
            },
            child: SizedBox(
              width: 70,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: _selectedIndex != 0
                          ? Colors.white
                          : const Color(0xFF2C64E3),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SvgPicture.asset(
                    'assets/icons/li_home.svg',
                    colorFilter: ColorFilter.mode(
                        _selectedIndex != 0
                            ? const Color(0xFF8B8D98)
                            : const Color(0xFF2C64E3),
                        BlendMode.srcIn),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Home',
                    style: TextStyle(
                      color: _selectedIndex != 0
                          ? const Color(0xFF8B8D98)
                          : const Color(0xFF2C64E3),
                      fontSize: 12,
                      fontFamily: themeFontFamily,
                      fontWeight: _selectedIndex != 0
                          ? FontWeight.w400
                          : FontWeight.w600,
                      // height: 0.11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //second
          // InkWell(
          //   onTap: () {
          //     print('tapped');
          //   },
          //   child: Stack(
          //     clipBehavior: Clip.none,
          //     alignment: Alignment.center,
          //     children: [
          //       const SizedBox(
          //         width: 55,
          //         height: 53,
          //       ),
          //       Positioned(
          //         top: -30,
          //         child: Column(
          //           children: [
          //             Container(
          //               width: 55,
          //               height: 53,
          //               clipBehavior: Clip.antiAlias,
          //               decoration: ShapeDecoration(
          //                 gradient: const LinearGradient(
          //                   begin: Alignment(-1.00, 0.06),
          //                   end: Alignment(1, -0.06),
          //                   colors: [Color(0xFF54AB6A), Color(0xFF0099FF)],
          //                 ),
          //                 shape: RoundedRectangleBorder(
          //                   borderRadius: BorderRadius.circular(69),
          //                 ),
          //               ),
          //               child: ElevatedButton(
          //                 onPressed: () {
          //                   _onItemTapped(1);
          //                 },
          //                 style: ElevatedButton.styleFrom(
          //                     padding: const EdgeInsets.all(0),
          //                     backgroundColor: Colors.transparent,
          //                     shadowColor: Colors.transparent),
          //                 child: const SizedBox(
          //                   height: 30,
          //                   width: 30,
          //                   child: Icon(
          //                     // fill: 1,
          //                     size: 30,
          //                     Icons.add,
          //                     color: Colors.white,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //             const GradientText(
          //               'Create Itinerary',
          //               gradient: LinearGradient(
          //                 begin: Alignment(-1.00, 0.06),
          //                 end: Alignment(1, -0.06),
          //                 colors: [Color(0xFF54AB6A), Color(0xFF0099FF)],
          //               ),
          //               style: TextStyle(
          //                 color: Color(0xFF54AB6A),
          //                 fontSize: 12,
          //                 fontFamily: 'Public Sans',
          //                 fontWeight: FontWeight.w600,
          //                 // height: 0.11,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          InkWell(
            onTap: () {
              _onItemTapped(1);
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 70,
                  height: 70,
                ),
                Positioned(
                  top: -32,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0099FF),
                              Color(0xFF54AB6A),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Center(
                          // child: SvgPicture.asset(
                          //   'assets/icons/logo.svg',
                          //   height: 25,
                          //   width: 25,
                          //   colorFilter: const ColorFilter.mode(
                          //     Colors.white,
                          //     BlendMode.srcIn,
                          //   ),
                          // ),
                          child: Icon(
                            Icons.add,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "New Trip",
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                          fontFamily: themeFontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              _onItemTapped(2);
            },
            child: SizedBox(
              width: 70,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: _selectedIndex != 2
                          ? Colors.white
                          : const Color(0xFF2C64E3),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SvgPicture.asset(
                    'assets/icons/li_user.svg',
                    colorFilter: ColorFilter.mode(
                        _selectedIndex != 2
                            ? const Color(0xFF8B8D98)
                            : const Color(0xFF2C64E3),
                        BlendMode.srcIn),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: _selectedIndex != 2
                          ? const Color(0xFF8B8D98)
                          : const Color(0xFF2C64E3),
                      fontSize: 12,
                      fontFamily: themeFontFamily,
                      fontWeight: _selectedIndex != 2
                          ? FontWeight.w400
                          : FontWeight.w600,
                      // height: 0.11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // BottomNavigationBar(
    //   selectedFontSize: 15,
    //   selectedIconTheme:
    //       const IconThemeData(color: Color(0xFF2C64E3), size: 25),
    //   selectedItemColor: const Color(0xFF2C64E3),
    //   selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
    //   unselectedIconTheme: const IconThemeData(
    //     color: Color.fromRGBO(131, 131, 131, 1),
    //   ),
    //   unselectedItemColor: const Color.fromRGBO(131, 131, 131, 1),
    //   items: <BottomNavigationBarItem>[
    //     BottomNavigationBarItem(
    //       icon:
    //       SvgPicture.asset(
    //         'assets/icons/li_home.svg',
    //         colorFilter:
    //             const ColorFilter.mode(Color(0xFF626C70), BlendMode.srcIn),
    //       ),
    //       label: 'Home',
    //       activeIcon: SvgPicture.asset(
    //         'assets/icons/li_home.svg',
    //         colorFilter:
    //             const ColorFilter.mode(Color(0xFF2C64E3), BlendMode.srcIn),
    //       ),
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.abc),
    //       // SvgPicture.asset('assets/image/bid_icon.svg'),
    //       label: 'Bids',
    //       // activeIcon: SvgPicture.asset(
    //       //   'assets/image/bid_icon.svg',
    //       //   colorFilter:
    //       //       const ColorFilter.mode(Color(0xFFFF3A3A), BlendMode.srcIn),
    //       // ),
    //     ),
    //     BottomNavigationBarItem(
    //       icon: Icon(Icons.ac_unit),
    //       // SvgPicture.asset('assets/image/account_icon.svg'),
    //       label: 'Account',
    //       // activeIcon: SvgPicture.asset(
    //       //   'assets/image/account_icon.svg',
    //       //   colorFilter:
    //       //       const ColorFilter.mode(Color(0xFFFF3A3A), BlendMode.srcIn),
    //       // ),
    //     ),
    //   ],
    //   currentIndex: _selectedIndex,
    //   onTap: _onItemTapped,
    // );
  }
}
