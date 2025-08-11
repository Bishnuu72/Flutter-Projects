import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:manshi/models/user_model.dart';
import 'package:manshi/models/preference_model.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/firebase_auth/fcm_services.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserModel> users = [];
  List<PreferenceModel> allPreferences = [];
  List<UserModel> selectedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userList = await FirestoreService.getAllUsers();
      final preferenceList = await FirestoreService.getAllPreferences(); // Implement this in FirestoreService
      setState(() {
        users = userList;
        allPreferences = preferenceList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDialog(String title, String desc, DialogType type, {VoidCallback? onOk}) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: type,
      animType: AnimType.rightSlide,
      title: title,
      desc: desc,
      btnOkOnPress: onOk ?? () {},
    ).show();
  }

  Future<void> _sendNotificationToSelectedUsers() async {
    if (selectedUsers.isEmpty) {
      _showDialog("Error", "Please select at least one user", DialogType.error);
      return;
    }

    final TextEditingController titleController = TextEditingController();
    final TextEditingController bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Send Notification', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) {
                _showDialog("Error", "Please enter a title", DialogType.error);
                return;
              }
              if (bodyController.text.trim().isEmpty) {
                _showDialog("Error", "Please enter a message", DialogType.error);
                return;
              }

              Navigator.pop(context);
              await _sendNotification(titleController.text.trim(), bodyController.text.trim());
            },
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendNotification(String title, String body) async {
    try {
      final userIds = selectedUsers.map((user) => user.id).toList();
      final tokens = await FirestoreService.getFCMTokensByUserIds(userIds);

      if (tokens.isEmpty) {
        _showDialog("Warning", "No valid FCM tokens found for selected users", DialogType.warning);
        return;
      }

      final success = await FCMServices.sendNotificationToMultipleTokens(
        tokens: tokens,
        title: title,
        body: body,
        data: {
          'type': 'admin_notification',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (success) {
        _showDialog(
          "Success",
          "Notification sent to ${tokens.length} users",
          DialogType.success,
          onOk: () {
            setState(() {
              selectedUsers.clear();
            });
          },
        );
      } else {
        _showDialog("Error", "Failed to send notification", DialogType.error);
      }
    } catch (e) {
      _showDialog("Error", "Error sending notification: $e", DialogType.error);
    }
  }

  // Helper: Get preference name by ID
  String _getPreferenceNameById(String id) {
    final pref = allPreferences.firstWhere(
          (p) => p.id == id,
      orElse: () => PreferenceModel(
        id: id,
        categoryId: '',
        name: 'Unknown',
        description: '',
        createdAt: DateTime.now(),
      ),
    );
    return pref.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('All Users'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (selectedUsers.isNotEmpty)
            TextButton(
              onPressed: _sendNotificationToSelectedUsers,
              child: const Text('Send Notification', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : users.isEmpty
          ? const Center(
        child: Text('No users found', style: TextStyle(color: Colors.white)),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Total Users: ${users.length}',
              style: const TextStyle(
                  fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = selectedUsers.contains(user);
                final hasFCMToken = user.fcmToken != null && user.fcmToken!.isNotEmpty;

                // Convert preference IDs to names
                final preferenceNames =
                user.preferences.map((id) => _getPreferenceNameById(id)).toList();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey[700] : Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedUsers.add(user);
                                } else {
                                  selectedUsers.remove(user);
                                }
                              });
                            },
                            activeColor: Colors.white,
                            checkColor: Colors.black,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: user.role == 'admin'
                                            ? Colors.red
                                            : Colors.green,
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        user.role.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Registered: ${_formatDate(user.createdAt)}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                if (hasFCMToken)
                                  const Text(
                                    '📱 Push notifications enabled',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.green),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (preferenceNames.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Preferences:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: preferenceNames.map<Widget>((prefName) {
                            return Chip(
                              label: Text(
                                prefName,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12),
                              ),
                              backgroundColor: Colors.white,
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                      ],
                      if (user.favoriteQuotes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Favorite Quotes: ${user.favoriteQuotes.length}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
