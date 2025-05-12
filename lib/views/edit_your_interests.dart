import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:xplorion_ai/views/urlconfig.dart';

class EditYourInterests extends StatefulWidget {
  const EditYourInterests({super.key});

  @override
  State<EditYourInterests> createState() => _EditYourInterestsState();
}

class _EditYourInterestsState extends State<EditYourInterests> {
  TextEditingController interestsController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  List selectedInterestsIds = [];

  void fetchSelectedInterests() async {
    String? userToken = await storage.read(key: 'userToken');
    final String url = '$baseurl/app/mobile/interests/$userToken';

    try {
      // Sending GET request
      final response = await http.get(Uri.parse(url));

      // Checking if the request was successful
      if (response.statusCode == 200) {
        // Parse the JSON data
        final data = json.decode(response.body);
        int len = data.length;

        for (int i = 0; i < len; i++) {
          selectedInterestsIds.add(data[i]['interest_id']);
        }

        print("++++++++");
        print(selectedInterestsIds);
        print("++++++++");
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _categoriesFuture = fetchCategories();
    fetchSelectedInterests();
  }

  // Function to fetch categories from the API
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    String? userToken = await storage.read(key: 'userToken');
    final response = await http
        .get(Uri.parse('$baseurl/app/sub-category/all/${userToken!}'));

    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  List<bool> subCategoryList = [];
  List<String> selectedSubCategory = [];

  List<bool> tasteBudsBoolList = [
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  List<bool> cuisineBoolList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  List<bool> activitiesBoolList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  List<bool> entertainmentBoolList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  List<bool> nightLifeBoolList = [
    false,
    false,
  ];

  List<bool> othersBoolList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  bool tasteBuds = true;
  bool cuisine = false;
  bool activities = false;
  bool entertainment = false;
  bool nightLife = false;
  bool others = false;

  bool allSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Find your fun',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
            height: 0,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(
              height: 20,
              child: Text(
                'Edit your interests for tailored itineraries',
                style: TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                  // height: 0.09,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Choose atleast 1 interest from each category.',
              style: TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories available'));
                } // End of error/loading/empty state handling

                final categories = snapshot.data!;
                int subCategoryDataLength = 0;
                int subCatLen;

                if (subCategoryList.isEmpty) {
                  for (int s = 0; s < categories.length; s++) {
                    subCatLen = (categories[s]['sub_category_data']).length;
                    subCategoryDataLength += subCatLen;
                  }

                  for (int c = 0; c <= subCategoryDataLength; c++) {
                    if (subCategoryList.length <= subCategoryDataLength) {
                      subCategoryList.add(false);
                    }
                  }

                  var selectedInterestBool;
                  for (int s = 0; s < categories.length; s++) {
                    subCatLen = (categories[s]['sub_category_data']).length;
                    var subCategoryDataDL = categories[s]['sub_category_data'];

                    for (int sc = 0; sc < subCatLen; sc++) {
                      selectedInterestBool = selectedInterestsIds
                          .contains(subCategoryDataDL[sc]['sub_category_id']);

                      if (selectedInterestBool == true) {
                        subCategoryList[subCategoryDataDL[sc]['sl']] = true;
                        selectedSubCategory
                            .add(subCategoryDataDL[sc]['sub_category_id']);
                      }
                    }
                  }
                }

                return Column(
                  children: categories.map((category) {
                    final primaryCategoryName = category['primaryCategoryName'];
                    final subCategoryData =
                        category['sub_category_data'] as List<dynamic>;
                    final subCategoryLen = subCategoryData.length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset('assets/icons/food.svg'),
                              const SizedBox(width: 10),
                              Text(
                                primaryCategoryName,
                                style: const TextStyle(
                                  color: Color(0xFF030917),
                                  fontSize: 16,
                                  fontFamily: 'themeFontFamily2',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ), // End of Row
                          const SizedBox(height: 10),
                          subCategoryData.isNotEmpty
                              ? Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: subCategoryData
                                      .map<Widget>((subCategory) {
                                    //final subCategoryId = subCategory['sub_category_id'].toString();
                                    /*final isSelected =
                              selectedInterestsIds.contains(subCategoryId);

                              if(isSelected == true)
                              {
                                  subCategoryList[subCategory['sl']] = true;
                              } */

                                    return interestsContainer(
                                        subCategory['sl'].toString(),
                                        subCategory['sub_category_name'],
                                        true,
                                        subCategoryList,
                                        subCategory['sub_category_id']);
                                  }).toList(),
                                ) // End of Wrap
                              : const Text(
                                  'No subcategories available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ); // End of Column
                  }).toList(),
                ); // End of Column wrapping FutureBuilder results
              }, // End of FutureBuilder builder
            ),
            InkWell(
              onTap: allSelected
                  ? () {
                      saveSelectedInterest();
                    }
                  : null,
              child: Opacity(
                opacity: allSelected ? 1 : 0.5,
                child: Container(
                  margin: const EdgeInsets.only(top: 50),
                  width: double.maxFinite,
                  height: 56,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
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
                  child: const Center(
                    child: Text(
                      'Update Interests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: themeFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //(String id, String interestsText, bool isSelected, String subCatId)
  Widget interestsContainer(id, interestsText, cat, arrayBool, subCatId) {
    var index = int.parse(id);
    bool isSelected = selectedSubCategory.contains(subCatId.toString());

    return InkWell(
      onTap: () {
        addSubInterestCat(subCatId.toString());
      },
      child: Opacity(
        opacity: cat ? 1 : 0.5,
        child: Container(
          height: 42,
          padding: const EdgeInsets.all(2),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            gradient: isSelected
                ? themeGradientColor
                : noneThemeGradientColor, // Use `isSelected` to determine the style
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: isSelected
                    ? Colors.transparent
                    : const Color(
                        0xFFCDCED7), // Use `isSelected` to determine the border color
              ),
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Chip(
            side: const BorderSide(color: Colors.transparent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            backgroundColor: isSelected
                ? const Color(0xFFEBF2FF)
                : Colors
                    .white, // Use `isSelected` to determine the background color
            label: Text(
              interestsText,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF005CE7)
                    : Colors
                        .black, // Use `isSelected` to determine the text color
                fontSize: 14,
                fontFamily: themeFontFamily2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  addSubInterestCat(String subCatId) {
    setState(() {
      if (selectedSubCategory.contains(subCatId.toString())) {
        // If the subcategory is already selected, remove it
        selectedSubCategory.remove(subCatId.toString());
      } else {
        // If the total selected subcategories are less than 6, allow adding
        if (selectedSubCategory.length < 6) {
          selectedSubCategory.add(subCatId.toString());
        } else {
          // Show a message if the user tries to select more than 6
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 6 interests only.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // Update the `allSelected` state based on whether any subcategories are selected
      allSelected = selectedSubCategory.isNotEmpty;
    });
  }

  saveSelectedInterest() async {
    String? userToken = await storage.read(key: 'userToken');
    List<String> stringSelectedSubCategory =
        selectedSubCategory.map((e) => '"$e"').toList();

    try {
      // Create the body for the POST request
      final map = <String, dynamic>{};
      map['userToken'] = userToken;
      map['subCategoryId'] = stringSelectedSubCategory.toString();

      // Send the POST request
      final response = await http.post(
        Uri.parse('$baseurl/app/interests/add'),
        body: map,
      );

      // Check the status code of the response
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the response body
        final responseData = jsonDecode(response.body);

        if (responseData['errFlag'] == 0) {
          Navigator.of(context).pushReplacementNamed('/profile');
        }
      } else {
        // If the server did not return a 200 OK response
        print(
            'Failed to send POST request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
}
