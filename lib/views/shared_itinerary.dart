import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplorion_ai/views/urlconfig.dart'; // Make sure this import is correct
import 'package:http/http.dart' as http;

class SharedItinerary extends StatefulWidget {
  const SharedItinerary({super.key});

  @override
  State<SharedItinerary> createState() => _SharedItineraryState();
}

class _SharedItineraryState extends State<SharedItinerary> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  /// Fetches itineraries shared with the current user.
  Future<List<Map<String, dynamic>>> fetchSharedItineraries() async {
    // Retrieve user token and email from secure storage.
    String? userToken = await storage.read(key: 'userToken');
    String? userEmail = await storage.read(
        key:
            'email'); // Ensure you store the user's email with this key upon login.

    if (userToken == null || userEmail == null) {
      throw Exception('User token or email not found. Please log in again.');
    }

    final response = await http.get(Uri.parse(
        '$baseurl/app/friends/shared-iternary/$userToken/rohankhanra9@gmail.com'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Map the response to a list of simplified itinerary objects.
      return data.map((sharedItem) {
        final details = sharedItem['iternaryDetails'];
        return {
          'place': details['cityStateCountry'] ?? 'Unknown Place',
          'image': details['itinerary']?['image_for_main_place'],
          'travelCompanion': details['travelCompanion'] ?? 'Not specified',
          'noOfDays': details['itinerary']?['itinerary']?['days']?.length ?? 0,
          'dayWithDate':
              details['itinerary']?['itinerary']?['days']?[0]?['day'] ?? 'N/A',
          'id': details['_id'],
          'friendName': sharedItem['friendName'] ?? 'A friend',
        };
      }).toList();
    } else {
      throw Exception('Failed to load shared itineraries: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Shared with me', // Updated title
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontSize: 20,
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding:
            EdgeInsets.fromLTRB(mediaWidth * 0.04, 10, mediaWidth * 0.04, 0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchSharedItineraries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.red, fontFamily: 'Public Sans'),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No itineraries have been shared with you yet.', // Updated empty state message
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 16,
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }

            final itineraries = snapshot.data!;
            // Use ListView.builder for better performance with long lists.
            return ListView.builder(
              itemCount: itineraries.length,
              itemBuilder: (context, index) {
                final itinerary = itineraries[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: sharedItineraryCard(
                    context,
                    itinerary['image'],
                    itinerary['place'],
                    itinerary['noOfDays'],
                    itinerary['dayWithDate'],
                    itinerary['travelCompanion'],
                    itinerary['id'],
                    itinerary['friendName'],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// A card widget to display summary of a shared itinerary.
Widget sharedItineraryCard(
    BuildContext context,
    String? imageUrl,
    String placeName,
    int noOfDays,
    String dayDate,
    String travelCompanion,
    String itineraryId,
    String friendName) {
  const String themeFontFamily = 'Public Sans';

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: ShapeDecoration(
      shape: RoundedRectangleBorder(
        side: const BorderSide(width: 1, color: Color(0xFFCDCED7)),
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Itinerary Image
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          height: 140, // Adjusted height for better balance
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey),
                  )
                : Image.asset(
                    "assets/images/panjim_goa.jpeg", // Placeholder image
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(width: 16),
        // Itinerary Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                placeName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF030917),
                  fontSize: 16,
                  fontFamily: themeFontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Starts $dayDate ($noOfDays days)',
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 14,
                  fontFamily: themeFontFamily,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SvgPicture.asset('assets/icons/bag.svg',
                      width: 14, height: 14),
                  const SizedBox(width: 6),
                  Text(
                    travelCompanion,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                      fontFamily: themeFontFamily,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // ** New section to show who shared the itinerary **
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      color: Color(0xFF888888), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Shared by: $friendName',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                        fontFamily: themeFontFamily,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: InkWell(
                  onTap: () {
                    // Navigate to the full itinerary view
                    Navigator.of(context).pushNamed(
                      '/home_page_trip',
                      arguments: {
                        'itinerarySavedFlag': 1,
                        'itineraryId': itineraryId
                      },
                    );
                  },
                  child: Container(
                    width: 60,
                    height: 30,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFECF2FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'View',
                        style: TextStyle(
                          color: Color(0xFF005CE7),
                          fontSize: 12,
                          fontFamily: 'Sora',
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
      ],
    ),
  );
}
