import 'dart:convert';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/providers/ci_date_provider.dart';
import 'package:xplorion_ai/views/create_itinerary.dart';
import 'package:http/http.dart' as http;
import '../../views/urlconfig.dart';

class SelectDateRange extends StatefulWidget {
  final PageController pageController;
  const SelectDateRange(this.pageController, {super.key});

  @override
  State<SelectDateRange> createState() => _SelectDateRangeState();
}

class _SelectDateRangeState extends State<SelectDateRange> {
  TextEditingController locationController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  TextEditingController preLoadLocation = TextEditingController();

  String startDate = 'Start Date';
  String endDate = 'End Date';
  bool dateBool = true;
  bool tripLength = false;
  int tripDays = 0;

  List<bool> monthSelected = [true, false, false, false];
  List<String> cityList = [];  // List to store city suggestions
  final String token = "your_token_here";  // Replace with your actual token

  @override
  void initState() {
    super.initState();
    _loadPreSelectedLocationOrDate();
  }

  Future<void> _loadPreSelectedLocationOrDate() async {
    String? selectedPlace = await storage.read(key: 'selectedPlace');
    String? startDateR = await storage.read(key: 'startDate');
    String? endDateR = await storage.read(key: 'endDate');
    setState(() {
      preLoadLocation.text = selectedPlace ?? '';
      startDate = startDateR ?? '';
      endDate = endDateR ?? '';
    });
  }

  // Function to fetch city suggestions from the API
  Future<void> fetchCities(String query) async {
    String? userToken = await storage.read(key: 'userToken');
    final String url = "$baseurl/app/city-name/$query/$userToken";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        cityList = data.map((city) => city['city'] as String).toList();
      });
    } else {
      print("Failed to load city data");
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
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  fetchCities(textEditingValue.text);
                  return cityList;
                },
                onSelected: (String selectedCity) {
                  print("Selected city: $selectedCity");
                },
                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                    FocusNode focusNode, VoidCallback onFieldSubmitted) {

                  textEditingController.text = textEditingController.text.isEmpty
                      ? preLoadLocation.text
                      : textEditingController.text;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 50,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.location_on,
                          color: Color(0xFF888888),
                        ),
                        hintText: 'Search your destination...',
                        hintStyle: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 16,
                          fontFamily: themeFontFamily2,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                      ),
                      controller: textEditingController,
                      focusNode: focusNode,
                    ),
                  );
                },
                optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options) {
                  final optionCount = options.length;
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      child: Container(
                        width: 300,
                        height: optionCount * 56.0 < 500 ? optionCount * 56.0 : 500,
                        color: Colors.white,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(option),
                                  onTap: () async {
                                    onSelected(option);
                                    await storage.write(
                                        key: 'selectedPlace',
                                        value: option
                                    );
                                  },
                                ),
                                if (index != optionCount - 1)
                                  const Divider(),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'When do you want to go?',
                style: TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Choose a date range',
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
              Visibility(
                visible: dateBool,
                child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  height: 50,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(builder:
                                (BuildContext context,
                                StateSetter modalSetState) {
                              return dateModal(modalSetState);
                            });
                          });
                    },
                    child: Row(
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFEFEFEF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF030917),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          '$startDate  -  $endDate',
                          style: const TextStyle(
                            color: Color(0xFF030917),
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
            ],
          ),
        ),
      ],
    );
  }

  Widget dateModal(StateSetter modalSetState) {
    final dateProvider = context.watch<CIDateProvider>();
    final config = CalendarDatePicker2Config(
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: const Color(0xFF005CE8),
      centerAlignModePicker: true,
      calendarViewMode: CalendarDatePicker2Mode.scroll,
      hideScrollViewMonthWeekHeader: true,
      scrollViewController: ScrollController(),
      weekdayLabelTextStyle: const TextStyle(
        color: Color(0xFF030917),
        fontSize: 16,
        fontFamily: themeFontFamily2,
        fontWeight: FontWeight.w500,
      ),
      dayTextStyle: const TextStyle(
        color: Color(0xFF030917),
        fontSize: 16,
        fontFamily: themeFontFamily2,
        fontWeight: FontWeight.w500,
      ),
      controlsTextStyle: const TextStyle(
        color: Color(0xFF030917),
        fontSize: 16,
        fontFamily: themeFontFamily2,
        fontWeight: FontWeight.w500,
      ),
      disabledDayTextStyle: const TextStyle(
        color: Color(0xFFCDCED7),
        fontSize: 16,
        fontFamily: themeFontFamily2,
        fontWeight: FontWeight.w500,
      ),
      selectableDayPredicate: (day) {
        return day.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      },
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      padding: const EdgeInsets.only(top: 5, left: 20, right: 20, bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 80,
              height: 6,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0x7F959FA3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Select dates',
            style: TextStyle(
              color: Color(0xFF030917),
              fontSize: 20,
              fontFamily: themeFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: CalendarDatePicker2(
                config: config,
                value: dateProvider.rangeDatePickerValueWithDefaultValue,
                onValueChanged: (dates) {
                  setState(() => dateProvider.changeDate(dates));
                }),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    startDate = 'Start Date';
                    endDate = 'End Date';
                    dateProvider.resetDate();
                    modalSetState(() {});
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.077,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFF2C64E3)),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: Color(0xFF2C64E3),
                          fontSize: 16,
                          fontFamily: themeFontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    if (dateProvider
                        .rangeDatePickerValueWithDefaultValue.length >
                        1) {
                      startDate = splitDate(dateProvider
                          .rangeDatePickerValueWithDefaultValue[0]
                          .toString());
                      endDate = splitDate(dateProvider
                          .rangeDatePickerValueWithDefaultValue[1]
                          .toString());

                      await storage.write(
                          key: 'startDate',
                          value: startDate
                      );

                      await storage.write(
                          key: 'endDate',
                          value: endDate
                      );
                    } else {
                      startDate = splitDate(dateProvider
                          .rangeDatePickerValueWithDefaultValue[0]
                          .toString());
                      endDate = splitDate(dateProvider
                          .rangeDatePickerValueWithDefaultValue[0]
                          .toString());

                      await storage.write(
                          key: 'startDate',
                          value: startDate
                      );

                      await storage.write(
                          key: 'endDate',
                          value: endDate
                      );
                    }
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Container(
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
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: themeFontFamily,
                          fontWeight: FontWeight.w600,
                          height: 0.16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String splitDate(String dates) {
    var totalDateWithTime = dates.split(' ');
    var totalDate = totalDateWithTime[0].split('-');
    var month = int.parse(totalDate[1]);
    var day = int.parse(totalDate[2]);
    return '$day ${getMonthName(month)}';
  }

  String getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }
}