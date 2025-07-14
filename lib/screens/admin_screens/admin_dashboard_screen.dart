import 'package:flutter/material.dart';
import 'package:manshi/core/route_config/routes_name.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget buildDashboardCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String count,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: icon == Icons.people
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onTap,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.add, size: 20, color: Colors.black),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add New',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildDashboardCard(
              context: context,
              icon: Icons.people,
              title: 'Total Users',
              count: '1488888',
              onTap: () {},
            ),
            buildDashboardCard(
              context: context,
              icon: Icons.category,
              title: 'Total Category',
              count: '100',
              onTap: () {
                Navigator.pushNamed(context, RoutesName.categoryScreen);
              },
            ),
            buildDashboardCard(
              context: context,
              icon: Icons.format_quote,
              title: 'Total Quotes',
              count: '200',
              onTap: () {
                Navigator.pushNamed(context, RoutesName.quoteScreen);
              },
            ),
            buildDashboardCard(
              context: context,
              icon: Icons.health_and_safety,
              title: 'Total Health Tips',
              count: '50',
              onTap: () {
                Navigator.pushNamed(context, RoutesName.healthTipsScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
