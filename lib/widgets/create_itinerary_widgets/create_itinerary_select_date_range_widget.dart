import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Import the uuid package

// (Keep your other imports like colors, fonts, providers, etc.)
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:xplorion_ai/lib_assets/colors.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/providers/ci_date_provider.dart';
import '../../views/urlconfig.dart';

// A placeholder for your Google Maps API Key
const String _googleApiKey = 'AIzaSyDEJx-EbYbqRixjZ0DvwuPd3FKVKtvv_OY';

/// A helper class to hold suggestion data and its source.
class LocationSuggestion {
  final String
      description; // The text to display (e.g., "Bengaluru, Karnataka, India")
  final bool isFromGoogle; // Flag to check the source of the suggestion
  final String? placeId; // Google's unique ID for a place

  LocationSuggestion({
    required this.description,
    this.isFromGoogle = false,
    this.placeId,
  });
}

class SelectDateRange extends StatefulWidget {
  final PageController pageController;
  const SelectDateRange(this.pageController, {super.key});

  @override
  State<SelectDateRange> createState() => _SelectDateRangeState();
}

class _SelectDateRangeState extends State<SelectDateRange> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  TextEditingController preLoadLocation = TextEditingController();

  String startDate = 'Start Date';
  String endDate = 'End Date';
  bool dateBool = true;
  bool tripLength = false;
  int tripDays = 0;

  Timer? _debounce;
  // Session token for Google Places API billing
  String? _googleSessionToken;
  final Uuid _uuid = const Uuid();

  DateTime? selectedStartDate;

  @override
  void initState() {
    super.initState();
    _loadPreSelectedLocationOrDate();
    // Generate a new session token when the widget is initialized
    _googleSessionToken = _uuid.v4();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPreSelectedLocationOrDate() async {
    String? selectedPlace = await storage.read(key: 'selectedPlace');
    String? startDateR = await storage.read(key: 'startDate');
    String? endDateR = await storage.read(key: 'endDate');
    setState(() {
      preLoadLocation.text = selectedPlace ?? '';
      startDate = startDateR ?? 'Start Date';
      endDate = endDateR ?? 'End Date';
    });
  }

  Future<List<LocationSuggestion>> _fetchCustomCities(String query) async {
    try {
      String? userToken = await storage.read(key: 'userToken');
      final String url = "$baseurl/app/city-name/$query/$userToken";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((city) {
          final cityName = city['city'] as String;
          final stateName = city['state'] as String;
          final countryName = city['country'] as String;
          return LocationSuggestion(
            description: '$cityName, $stateName, $countryName',
            isFromGoogle: false,
          );
        }).toList();
      }
    } catch (e) {
      print("Error fetching from custom backend: $e");
    }
    return []; // Return empty list on failure
  }

  
  Future<List<LocationSuggestion>> _fetchGooglePlaces(String query) async {
    if (_googleApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') {
      print("Google API Key is not set. Skipping Google Places search.");
      return [];
    }

    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&sessiontoken=$_googleSessionToken&types=(cities)';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final List<dynamic> predictions = data['predictions'];
          return predictions.map((prediction) {
            return LocationSuggestion(
              description: prediction['description'] as String,
              placeId: prediction['place_id'] as String,
              isFromGoogle: true,
            );
          }).toList();
        }
      }
    } catch (e) {
      print("Error fetching from Google Places API: $e");
    }
    return [];
  }

  
  Future<Map<String, dynamic>?> _getGooglePlaceDetails(String placeId) async {
    if (_googleApiKey == 'YOUR_GOOGLE_MAPS_API_KEY') return null;

    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_googleApiKey&sessiontoken=$_googleSessionToken&fields=address_components,geometry';

    // Invalidate the session token after use
    setState(() {
      _googleSessionToken = null;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
    return null;
  }

  
  Future<void> _sendGooglePlaceToBackend(Map<String, dynamic> placeData) async {
    print("--- Sending Google Place Data to Backend (Simulation) ---");
    print("City: ${placeData['city']}");
    print("State: ${placeData['state']}");
    print("Country: ${placeData['country']}");
    print("Latitude: ${placeData['latitude']}");
    print("Longitude: ${placeData['longitude']}");
    print("---------------------------------------------------------");

    try {
      String? userToken = await storage.read(key: 'userToken');
      final String url =
          "$baseurl/app/add-city-name/${placeData['city']}/${placeData['state']}/${placeData['country']}/$userToken";
      print("+++++++++++++++++++++++++URL: $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("+++++++++++++++++++++++++Backend response: $data");
      } else {
        print(
            "+++++++++++++++++++++++++Failed to send data to backend. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("+++++++++++++++++++++++++Error fetching from custom backend: $e");
    }
  }

  /// Handles the selection of a Google Place suggestion.
  Future<void> _handleGooglePlaceSelection(LocationSuggestion selection) async {
    final details = await _getGooglePlaceDetails(selection.placeId!);
    if (details == null) return;

    // Extract city, state, country from address components
    String city = '';
    String state = '';
    String country = '';

    if (details['address_components'] is List) {
      for (var component in details['address_components']) {
        if (component['types'] is List) {
          List types = component['types'];
          if (types.contains('locality')) {
            city = component['long_name'];
          }
          if (types.contains('administrative_area_level_1')) {
            state = component['long_name'];
          }
          if (types.contains('country')) {
            country = component['long_name'];
          }
        }
      }
    }

    // Extract geometry
    double lat = details['geometry']?['location']?['lat'] ?? 0.0;
    double lng = details['geometry']?['location']?['lng'] ?? 0.0;

    final placeData = {
      'city': city.isNotEmpty ? city : selection.description.split(',')[0],
      'state': state,
      'country': country,
      'latitude': lat,
      'longitude': lng,
    };

    // Call the dummy function to "send" data
    await _sendGooglePlaceToBackend(placeData);

    // Save the user-friendly description to storage
    await storage.write(key: 'selectedPlace', value: selection.description);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Autocomplete<LocationSuggestion>(
                displayStringForOption: (option) => option.description,
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  final String query = textEditingValue.text.trim();

                  if (_googleSessionToken == null) {
                    setState(() {
                      _googleSessionToken = _uuid.v4();
                    });
                  }

                  if (query.length < 3) {
                    return const Iterable<LocationSuggestion>.empty();
                  }

                  _debounce?.cancel();
                  final completer = Completer<Iterable<LocationSuggestion>>();
                  _debounce =
                      Timer(const Duration(milliseconds: 600), () async {
                    List<LocationSuggestion> customResults =
                        await _fetchCustomCities(query);
                    if (customResults.isNotEmpty) {
                      completer.complete(customResults);
                    } else {
                      List<LocationSuggestion> googleResults =
                          await _fetchGooglePlaces(query);
                      completer.complete(googleResults);
                    }
                  });
                  return completer.future;
                },
                onSelected: (LocationSuggestion selection) {
                  if (selection.isFromGoogle) {
                    _handleGooglePlaceSelection(selection);
                  } else {
                    storage.write(
                        key: 'selectedPlace', value: selection.description);
                  }
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  if (preLoadLocation.text.isNotEmpty &&
                      textEditingController.text.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      textEditingController.text = preLoadLocation.text;
                      preLoadLocation.clear();
                    });
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 50,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 1, color: Color(0xFFCDCED7)),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        prefixIcon:
                            Icon(Icons.location_on, color: Color(0xFF888888)),
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
                optionsViewBuilder: (BuildContext context,
                    AutocompleteOnSelected<LocationSuggestion> onSelected,
                    Iterable<LocationSuggestion> options) {
                  final optionCount = options.length;
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        width: MediaQuery.of(context).size.width - 40,
                        height: optionCount * 65.0 < 300
                            ? optionCount * 65.0
                            : 300, // Adjusted height
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFCDCED7)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            final option = options.elementAt(index);
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(option.description,
                                      style: const TextStyle(fontSize: 16)),
                                  trailing: option.isFromGoogle
                                      ? const Icon(Icons.public,
                                          color: Colors.grey, size: 18)
                                      : null,
                                  onTap: () {
                                    onSelected(option);
                                  },
                                ),
                                if (index != optionCount - 1)
                                  const Divider(
                                      height: 1, color: Color(0xFFCDCED7)),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 5),
              const Text(
                'When do you want to go?',
                style: TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 16,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Choose a date range',
                style: TextStyle(
                  color: Color(0xFF8B8D98),
                  fontSize: 14,
                  fontFamily: themeFontFamily2,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: dateBool,
                child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  height: 50,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side:
                          const BorderSide(width: 1, color: Color(0xFFCDCED7)),
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
                        const SizedBox(width: 10),
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

  // ================= Date Modal (Restored to Original) ====================
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
        if (day.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
          return false;
        }
        if (selectedStartDate != null) {
          final maxEndDate = selectedStartDate!.add(const Duration(days: 6));
          return day.isBefore(maxEndDate) || day.isAtSameMomentAs(maxEndDate);
        }
        return true;
      },
    );

    return SafeArea(
      bottom: true,
      child: Container(
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
            const SizedBox(height: 10),
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
                  if (dates.isNotEmpty) {
                    setState(() {
                      selectedStartDate = dates[0];
                      dateProvider.changeDate(dates);
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      startDate = 'Start Date';
                      endDate = 'End Date';
                      dateProvider.resetDate();
                      setState(() {
                        selectedStartDate = null;
                      });
                      modalSetState(() {});
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.07,
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
                        startDate = DateFormat('yyyy-MM-dd').format(
                          dateProvider.rangeDatePickerValueWithDefaultValue[0]!,
                        );
                        endDate = DateFormat('yyyy-MM-dd').format(
                          dateProvider.rangeDatePickerValueWithDefaultValue[1]!,
                        );
                        await storage.write(key: 'startDate', value: startDate);
                        await storage.write(key: 'endDate', value: endDate);
                      } else if (dateProvider
                          .rangeDatePickerValueWithDefaultValue.isNotEmpty) {
                        startDate = DateFormat('yyyy-MM-dd').format(
                          dateProvider.rangeDatePickerValueWithDefaultValue[0]!,
                        );
                        endDate = startDate;
                        await storage.write(key: 'startDate', value: startDate);
                        await storage.write(key: 'endDate', value: endDate);
                      }
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                    child: Container(
                      width: double.maxFinite,
                      height: 56,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(-1.00, 0.06),
                          end: Alignment(1, -0.06),
                          colors: [Color(0xFF0099FF), Color(0xFF54AB6A)],
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
      ),
    );
  }

  // ================= Original Helper Functions ====================
  String splitDate(String dates) {
    var totalDateWithTime = dates.split(' ');
    var totalDate = totalDateWithTime[0].split('-');
    var month = int.parse(totalDate[1]);
    var day = int.parse(totalDate[2]);
    return '$day ${getMonthName(month)}';
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
