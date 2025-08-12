import 'package:flutter/material.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/models/health_tip_model.dart';
import 'package:manshi/screens/admin_screens/edit_health_screen.dart'; // ✅ Added import for edit screen
import 'package:manshi/core/route_config/routes_name.dart';

class HealthTipListScreen extends StatefulWidget {
  const HealthTipListScreen({super.key});

  @override
  State<HealthTipListScreen> createState() => _HealthTipListScreenState();
}

class _HealthTipListScreenState extends State<HealthTipListScreen> {
  List<HealthTipModel> healthTips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHealthTips();
  }

  Future<void> loadHealthTips() async {
    try {
      final healthTipsData = await FirestoreService.getHealthTips();
      setState(() {
        healthTips = healthTipsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load health tips: $e')),
        );
      }
    }
  }

  Future<void> deleteHealthTip(String healthTipId) async {
    try {
      await FirestoreService.deleteHealthTip(healthTipId);
      await loadHealthTips();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health tip deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete health tip: $e')),
        );
      }
    }
  }

  void _navigateToEditHealthTip(HealthTipModel healthTip) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHealthTipsScreen(healthTip: healthTip), // ✅ Direct push to edit screen
      ),
    );
    if (result == true) {
      loadHealthTips();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Health Tips'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, RoutesName.healthTipsScreen);
              if (result == true) {
                loadHealthTips();
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadHealthTips,
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : healthTips.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.health_and_safety, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text('No health tips available',
                      style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Add your first health tip to help users',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, RoutesName.healthTipsScreen);
                      if (result == true) loadHealthTips();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Add Health Tip'),
                  ),
                ],
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: healthTips.length,
          itemBuilder: (context, index) {
            final healthTip = healthTips[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.health_and_safety, color: Colors.green[400], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          healthTip.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _navigateToEditHealthTip(healthTip),
                        icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteDialog(healthTip),
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    healthTip.content,
                    style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(HealthTipModel healthTip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Delete Health Tip', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${healthTip.title}"? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400]))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteHealthTip(healthTip.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
