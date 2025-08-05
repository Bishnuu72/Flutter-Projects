import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manshi/core/route_config/routes_name.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<void> _refreshFuture;

  int userCount = 0;
  int categoryCount = 0;
  int quoteCount = 0;
  int healthTipsCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshFuture = _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final users = await getCollectionCount('users'); //getUserCount -> to show only users count
      final categories = await getCollectionCount('categories');
      final quotes = await getCollectionCount('quotes');
      final tips = await getCollectionCount('healthTips');

      if (mounted) {
        setState(() {
          userCount = users;
          categoryCount = categories;
          quoteCount = quotes;
          healthTipsCount = tips;
        });
      }
    } catch (e) {
      debugPrint('Error loading counts: $e');
    }
  }

  Future<int> getUserCount(String users) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting user count: $e');
      return 0;
    }
  }

  Future<int> getCollectionCount(String collection) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection(collection).get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting collection count for $collection: $e');
      return 0;
    }
  }

  Widget buildDashboardCard({
    required IconData icon,
    required String title,
    required String count,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red[800] : Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isLogout ? Colors.white : Colors.grey,
                    fontSize: 16,
                  ),
                ),
                if (!isLogout) const SizedBox(height: 6),
                if (!isLogout)
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
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.loginScreen,
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadCounts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              buildDashboardCard(
                icon: Icons.people,
                title: 'Total Users',
                count: userCount.toString(),
                onTap: () => Navigator.pushNamed(context, RoutesName.userListScreen),
              ),
              buildDashboardCard(
                icon: Icons.category,
                title: 'Total Categories',
                count: categoryCount.toString(),
                onTap: () => Navigator.pushNamed(context, RoutesName.categoryListScreen),
              ),
              buildDashboardCard(
                icon: Icons.format_quote,
                title: 'Total Quotes',
                count: quoteCount.toString(),
                onTap: () => Navigator.pushNamed(context, RoutesName.quoteListScreen),
              ),
              buildDashboardCard(
                icon: Icons.health_and_safety,
                title: 'Total Health Tips',
                count: healthTipsCount.toString(),
                onTap: () => Navigator.pushNamed(context, RoutesName.healthTipListScreen),
              ),
              buildDashboardCard(
                icon: Icons.logout,
                title: 'Logout',
                count: '',
                onTap: () => _logout(context),
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
