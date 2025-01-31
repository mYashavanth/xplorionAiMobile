import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:xplorion_ai/lib_assets/fonts.dart';
import 'package:xplorion_ai/views/urlconfig.dart';
import 'package:xplorion_ai/widgets/bottom_navbar.dart';
import 'package:http/http.dart' as http;

class SavedItineraries extends StatefulWidget {
  const SavedItineraries({super.key});

  @override
  State<SavedItineraries> createState() => _SavedItinerariesState();
}

class _SavedItinerariesState extends State<SavedItineraries> {

  Future<List> fetchCollections() async {

    const FlutterSecureStorage storage = FlutterSecureStorage();
    String? userToken = await storage.read(key: 'userToken');

    final url = Uri.parse('$baseurl/app/collection/all/$userToken');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load collections');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Saved",
          style: TextStyle(
            fontSize: 20,
            fontFamily: themeFontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder(
          future: fetchCollections(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(child: Text('No collections found.'));
            }

            final collections = snapshot.data as List;

            return ListView(
              children: [
                // Dynamically add rows based on the API response
                ...List.generate(
                  (collections.length / 2).ceil(),
                      (index) {
                    final item1 = collections[index * 2];
                    final item2 = index * 2 + 1 < collections.length
                        ? collections[index * 2 + 1]
                        : null;

                    return Row(
                      children: [
                        buildCard('default_image.jpeg', item1['collection_name'], true, item1['_id']),
                        if (item2 != null) ...[
                          const Spacer(),
                          buildCard('default_image.jpeg', item2['collection_name'], true, item1['_id']),
                        ],
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const TripssistNavigationBar(2),
    );
  }

  Widget buildSavedItineraryCard(array1, array2) {
    return Row(
      children: [
        buildCard(array1[0], array1[1], array1[2], null),
        const Spacer(),
        buildCard(array2[0], array2[1], array2[2], null),
      ],
    );
  }

  Widget buildCard(img, title, private, collectionId) {
    double size = MediaQuery.of(context).size.width * 0.454;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: (){

            Navigator.of(context).pushNamed('/detailed_saved_itinerary',arguments: {
              'collectionId': collectionId,
              'titleCollection': title
            });

          },
          child: Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              image: const DecorationImage(
                image: NetworkImage('https://img.freepik.com/free-vector/travel-tourism-label-with-attractions_1284-52995.jpg'),//AssetImage("assets/images/$img"),
                fit: BoxFit.cover,
              ),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF030917),
            fontSize: 16,
            fontFamily: themeFontFamily2,
            fontWeight: FontWeight.w400,
          ),
        ),
        // const SizedBox(
        //   height: 5,
        // ),
        private
            ? const Row(children: [
                Icon(
                  Icons.lock,
                  size: 12,
                  color: Color(0xFF888888),
                ),
                Text(
                  'Private',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    fontFamily: themeFontFamily2,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ])
            :
          
            buildFriends()
      ],
    );
  }

  Widget buildFriends() {
    return Row(
      children: [
        SizedBox(
          width: 25,
          height: 12,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const ShapeDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/friend_photo.jpeg"),
                      fit: BoxFit.fill,
                    ),
                    shape: OvalBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const ShapeDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/friend1.jpeg"),
                      fit: BoxFit.cover,
                    ),
                    shape: OvalBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignOutside,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        const Text(
          'with friends',
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 12,
            fontFamily: themeFontFamily2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
