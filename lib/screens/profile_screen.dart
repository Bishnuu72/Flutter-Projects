import 'package:flutter/material.dart';
import '../widgets/dashboard_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Profile Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bishnu Manshi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'bishnu.manshi@example.com',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "MAKE IT YOURS",
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            buildButtonTile(Icons.menu_book, "Content Preferences", () {
              print("Content Preferences tapped");
            }),

            const SizedBox(height: 30),

            Text(
              "ACCOUNT",
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            buildButtonTile(Icons.edit, "Theme", () {
              print("Theme tapped");
            }),
            buildButtonTile(Icons.password, "Forgot Password", () {
              print("Forgot Password tapped");
            }),
            buildButtonTile(Icons.logout, "Logout", () {
              print("Logout tapped");
            }),
          ],
        ),
      ),
    );
  }
}
