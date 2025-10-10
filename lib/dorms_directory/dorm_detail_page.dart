// dorms_detail_page.dart

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:findmydorm/models/dorms.dart';
import 'package:findmydorm/maps_directory/maps_detail_page.dart';

class DormDetailPage extends StatelessWidget {
  // 1. Change the final field type from String to the Dorms object
  final Dorms dorm;

  // 2. Update the constructor to require the Dorms object
  const DormDetailPage(this.dorm, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use the actual dorm name in the AppBar title
        title: Text(dorm.dormName),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          // 3. Image Section (Remains the same for now)
          Container(
            height: MediaQuery.of(context).size.height *
                0.4, // Reduced height for more detail space
            width: double.infinity,
            child: Image.asset(
              'assets/images/dorm.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // 4. Details Section (Expanded to show all data)
          Expanded(
            child: SingleChildScrollView(
              // Use SingleChildScrollView to prevent overflow
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    dorm.dormName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Location Detail
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Location: ${dorm.dormLocation}',
                        style:
                            const TextStyle(fontSize: 18, fontFamily: 'Lato'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dorm Number Detail
                  Row(
                    children: [
                      const Icon(Icons.pin, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Dorm ID/Number: ${dorm.dormNumber}',
                        style:
                            const TextStyle(fontSize: 18, fontFamily: 'Lato'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Created At Detail
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      // Format the date for better readability if possible
                      Text(
                        'Listed on: ${dorm.createdAt.substring(0, 10)}',
                        style:
                            const TextStyle(fontSize: 18, fontFamily: 'Lato'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Placeholder for a longer description (you can add this field to your model later)
                  const Text(
                    "This is a brief description of the dorm amenities, rules, and general information. It's a quiet place suitable for students looking for a focus environment near campus.",
                    style: TextStyle(
                        fontSize: 16, fontFamily: 'Lato', color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar (Remains the same)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the MapsDetailPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapsDetailPage(
                      // ⚠️ Assumes dorm.latitude and dorm.longitude are implemented in the model
                      latitude: dorm.latitude ??
                          51.5, // Use actual data or safe default
                      longitude: dorm.longitude ??
                          -0.09, // Use actual data or safe default
                      dormName: dorm.dormName,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                minimumSize: WidgetStateProperty.all<Size>(const Size(280, 60)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.amber, width: 2),
                  ),
                ),
              ),
              child: const Icon(
                Ionicons.map,
                size: 40,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
