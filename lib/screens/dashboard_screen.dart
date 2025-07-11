import 'package:flutter/material.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RoutesName.profileScreen);
                    },
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border, size: 28,),
                      label: const Text('My Favorites',
                      style: TextStyle(fontSize: 16),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none, size: 28,),
                      label: const Text('Remind Me',
                      style: TextStyle(fontSize: 16),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              const Text(
                "Today's Quotes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"Your wellness is an investment, not an expense."',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 12,),
                    Text(
                      "- Bishnu Kumar Yadav",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,fontStyle: FontStyle.italic,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              const Text(
                "Quotes",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12,),
              buildButtonTile(Icons.wb_sunny_outlined, "Feeling blessed", () {
                Navigator.pushNamed(context, RoutesName.quotesDetailScreen);
              }),
              buildButtonTile(Icons.favorite_border, "Pride Month", () {
                //Navigator here
              }),
              buildButtonTile(Icons.star_border, "Self-worth", () {
                //Navihgator hereee
              }),
              buildButtonTile(Icons.favorite, "Love", () {
                //Navigator here
              }),
              const SizedBox(height: 20,),
              const Text(
                "Health Tips",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12,),
              buildButtonTile(Icons.air, "Breathe to Reset", () {
                Navigator.pushNamed(context, RoutesName.productScreen);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
