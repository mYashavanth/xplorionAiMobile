import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/views/urlconfig.dart';

class CreateIteneraryTravelCompanions extends StatefulWidget {
  final PageController pageController;
  const CreateIteneraryTravelCompanions(this.pageController, {super.key});

  @override
  State<CreateIteneraryTravelCompanions> createState() =>
      _CreateIteneraryTravelCompanionsState();
}

class _CreateIteneraryTravelCompanionsState
    extends State<CreateIteneraryTravelCompanions> {
  List<bool> companienSelectBoolList = [];
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  List<dynamic> travelCompanionData = [];
  bool goingWithFamily = false;
  bool travellingWithChildren = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // Function to fetch categories from the API
  Future<void> fetchCategories() async {
    try {
      String? userToken = await storage.read(key: 'userToken');
      debugPrint('User token: $userToken');
      if (userToken == null) throw Exception('User token not found');

      final response = await http
          .get(Uri.parse('$baseurl/app/travel-companions/$userToken'));
      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        debugPrint('Fetched data: $data');

        //setState(() {
        travelCompanionData = data;
        companienSelectBoolList =
            List.generate(data.length, (index) => index == 0);
        //});

        // Save the first travel companion by default
        if (data.isNotEmpty) {
          await storage.write(
            key: 'travelCompanion',
            value: data[0]['travel_companion_name'],
          );
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Travel Companions',
                      style: TextStyle(
                        color: Color(0xFF030917),
                        fontSize: 16,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select your travel group type.',
                      style: TextStyle(
                        color: Color(0xFF8B8D98),
                        fontSize: 14,
                        fontFamily: themeFontFamily2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: List.generate(
                        companienSelectBoolList.length,
                        (index) {
                          return travelCompanionCard(
                            index,
                            travelCompanionData.isNotEmpty
                                ? travelCompanionData[index]
                                    ['travel_companion_name']
                                : '',
                            travelCompanionData.isNotEmpty
                                ? travelCompanionData[index]
                                    ['travel_companion_icon_link']
                                : '',
                            // 'profile.svg',
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
  }

  Widget travelCompanionCard(int index, String title, iconUrl) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: ShapeDecoration(
        gradient: companienSelectBoolList[index]
            ? themeGradientColor
            : noneThemeGradientColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: !companienSelectBoolList[index]
                ? const Color(0xFFCDCED7)
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          setState(() {
            for (var i = 0; i < companienSelectBoolList.length; i++) {
              companienSelectBoolList[i] = i == index;
            }
          });
          await storage.write(key: 'travelCompanion', value: title);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width * 0.4,
          height: 132,
          decoration: ShapeDecoration(
            color: companienSelectBoolList[index]
                ? const Color(0xFFECF2FF)
                : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: companienSelectBoolList[index]
                      ? const Color(0xFF2C64E3)
                      : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: (iconUrl != null && iconUrl.isNotEmpty)
                      ? ClipOval(
                          child: Image.network(
                            iconUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                  'https://dummyimage.com/50x50/ccc/ccc');
                            },
                          ),
                        )
                      : ClipOval(
                          child: Image.network(
                              'https://dummyimage.com/50x50/ccc/ccc'),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  color: companienSelectBoolList[index]
                      ? const Color(0xFF005CE7)
                      : Colors.black,
                  fontSize: 14,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
