import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
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
    String? userToken = await storage.read(key: 'userToken');
    String? userEmail = await storage.read(key: 'email');

    if (userToken == null || userEmail == null) {
      throw Exception('User token or email not found. Please log in again.');
    }

    final response = await http.get(Uri.parse(
        '$baseurl/app/friends/shared-iternary/$userToken/$userEmail'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
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
          'Shared with me',
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
                  'No itineraries have been shared with you yet.',
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
            return ListView.builder(
              itemCount: itineraries.length,
              itemBuilder: (context, index) {
                final itinerary = itineraries[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
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

/// ** [ FINAL UPDATED WIDGET ] **
/// A redesigned card with a fully responsive layout where the image stretches to the full card height.
Widget sharedItineraryCard(
    BuildContext context,
    String? imageUrl,
    String placeName,
    int noOfDays,
    String dayDate,
    String travelCompanion,
    String itineraryId,
    String friendName) {
  // Helper function for consistently styled info rows
  Widget buildInfoRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF8B8D98), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8B8D98),
              fontSize: 14,
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  return InkWell(
    onTap: () {
      Navigator.of(context).pushNamed(
        '/home_page_trip',
        arguments: {'itinerarySavedFlag': 1, 'itineraryId': itineraryId},
      );
    },
    borderRadius: BorderRadius.circular(24),
    child: Container(
      clipBehavior: Clip.antiAlias, // Clip overflow from children
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19929292),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: IntrinsicHeight(
        // Use IntrinsicHeight to make children match height
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch children vertically
          children: [
            // Itinerary Image
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      ),
                    )
                  : Image.asset(
                      "assets/images/panjim_goa.jpeg", // Placeholder
                      fit: BoxFit.cover,
                    ),
            ),
            // Itinerary Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      placeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF030917),
                        fontSize: 16,
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildInfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: '$dayDate ($noOfDays days)',
                    ),
                    const SizedBox(height: 6),
                    buildInfoRow(
                      icon: Icons.group_outlined,
                      text: travelCompanion,
                    ),
                    const SizedBox(height: 6),
                    buildInfoRow(
                      icon: Icons.person_outline,
                      text: 'Shared by: $friendName',
                    ),
                    // const SizedBox(height: 12),
                    // Full-width View Button
                    // Container(
                    //   width: double.infinity, // Make the button full-width
                    //   height: 44, // Increased height for better proportions
                    //   decoration: ShapeDecoration(
                    //     color: const Color(0xFFECF2FF),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(32),
                    //     ),
                    //   ),
                    //   child: const Center(
                    //     child: Text(
                    //       'View',
                    //       style: TextStyle(
                    //         color: Color(0xFF005CE7),
                    //         fontSize: 14, // Slightly larger font
                    //         fontFamily: 'Sora',
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
