import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:http/http.dart' as http;

import '../gradient_text.dart';

class CreateItineraryBudgetLimit extends StatefulWidget {
  final PageController pageController;
  const CreateItineraryBudgetLimit(this.pageController, {super.key});

  @override
  State<CreateItineraryBudgetLimit> createState() =>
      _CreateItineraryBudgetLimitState();
}

class _CreateItineraryBudgetLimitState
    extends State<CreateItineraryBudgetLimit> {
  List budgetLimitationBool = []; // true, false, false
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  List<dynamic> budgetTierData = [];

  @override
  void initState() {
    fetchBudgetTier();
    super.initState();
  }

  // Function to fetch categories from the API
  void fetchBudgetTier() async {
    String? userToken = await storage.read(key: 'userToken');
    final response =
        await http.get(Uri.parse('$baseurl/app/budget-tier/${userToken!}'));
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      for (int i = 0; i < data.length; i++) {
        if (i == 0) {
          budgetLimitationBool.add(true);
          await storage.write(key: 'budgetTier', value: data[i]['budget_tier']);
        } else {
          budgetLimitationBool.add(false);
        }
      }
      setState(() {
        budgetTierData = data;
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    double mediaWidth = MediaQuery.of(context).size.width;
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select your budget tier',
                style: TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Select your preferred budget type.',
                style: TextStyle(
                  color: Color(0xFF8B8D98),
                  fontSize: 14,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: List.generate(budgetLimitationBool.length, (index) {
                  return SizedBox(
                    width: (mediaWidth - 60) /
                        2, // Adjust the width to fit 2 cards in a row
                    child: budgetLimitationCard(
                      index,
                      mediaWidth,
                      budgetTierData.isNotEmpty
                          ? (budgetTierData[index]['budget_tier'] ?? 'N/A')
                          : 'Loading...',
                      budgetTierData.isNotEmpty
                          ? (budgetTierData[index]['budget_tier_icon'] ?? 'N/A')
                          : '',
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget budgetLimitationCard(index, mediaWidth, String title, iconUrl) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: ShapeDecoration(
          gradient: budgetLimitationBool[index]
              ? themeGradientColor
              : noneThemeGradientColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1,
                color: !budgetLimitationBool[index]
                    ? const Color(0xFFCDCED7)
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: GestureDetector(
          onTap: () async {
            for (var i = 0; i < budgetLimitationBool.length; i++) {
              budgetLimitationBool[i] = i == index;
            }

            await storage.write(key: 'budgetTier', value: title);

            setState(() {});
          },
          child: Container(
            width: double.maxFinite,
            margin: const EdgeInsets.all(0),
            height: 114,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: budgetLimitationBool[index]
                  ? const Color(0xFFECF2FF)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: ShapeDecoration(
                    color: budgetLimitationBool[index]
                        ? const Color(0xFF2C64E3)
                        : Colors.white,
                    shape: const OvalBorder(),
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
                Text(
                  title, // Title is now a non-null string
                  style: TextStyle(
                    color: budgetLimitationBool[index]
                        ? const Color(0xFF2C64E3)
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
      ),
    );
  }
}
