import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manshi/models/reminder_model.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/firebase_auth/notification_service.dart';
import 'dart:convert';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  
  ReminderType _selectedType = ReminderType.daily;
  ContentType _selectedContentType = ContentType.quote;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _selectedDayOfWeek = 1; // Monday
  List<String> _selectedCategories = [];
  List<String> _availableCategories = [];
  
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadUserReminders();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await FirestoreService.getCategories();
      setState(() {
        _availableCategories = categories.map((c) => c.name).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadUserReminders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final reminders = await FirestoreService.getUserReminders(currentUser.uid);
        // You can display existing reminders here
      } catch (e) {
        print('Error loading reminders: $e');
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
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

  Future<void> _createReminder() async {
    if (_titleController.text.trim().isEmpty) {
      _showDialog("Error", "Please enter a reminder title", DialogType.error);
      return;
    }

    if (_selectedCategories.isEmpty) {
      _showDialog("Error", "Please select at least one category", DialogType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showDialog("Error", "User not authenticated", DialogType.error);
        return;
      }

      final reminder = ReminderModel(
        id: '', // Will be set by Firestore
        userId: currentUser.uid,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim().isEmpty 
            ? "Time for your wellness reminder!" 
            : _bodyController.text.trim(),
        type: _selectedType,
        contentType: _selectedContentType,
        categories: _selectedCategories,
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        dayOfWeek: _selectedType == ReminderType.weekly ? _selectedDayOfWeek : null,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await FirestoreService.createReminder(reminder);

      // Schedule local notification
      final notificationService = NotificationService();
      final notificationId = DateTime.now().millisecondsSinceEpoch % 2147483647;

      if (_selectedType == ReminderType.daily) {
        await notificationService.scheduleDailyReminder(
          id: notificationId,
          title: reminder.title,
          body: reminder.body,
          hour: reminder.hour,
          minute: reminder.minute,
          payload: json.encode({
            'type': 'reminder',
            'contentType': reminder.contentType.toString().split('.').last,
            'categories': reminder.categories,
          }),
        );
      } else {
        await notificationService.scheduleWeeklyReminder(
          id: notificationId,
          title: reminder.title,
          body: reminder.body,
          dayOfWeek: reminder.dayOfWeek!,
          hour: reminder.hour,
          minute: reminder.minute,
          payload: json.encode({
            'type': 'reminder',
            'contentType': reminder.contentType.toString().split('.').last,
            'categories': reminder.categories,
          }),
        );
      }

      if (!mounted) return;
      _showDialog(
        "Success", 
        "Reminder scheduled successfully!", 
        DialogType.success,
        onOk: () {
          Navigator.pop(context);
        },
      );
    } catch (e) {
      _showDialog("Error", "Failed to create reminder: $e", DialogType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Reminder'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Reminder Title',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Body (optional)
                  TextField(
                    controller: _bodyController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Reminder Message (optional)',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reminder Type
                  const Text(
                    'Reminder Type',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<ReminderType>(
                          title: const Text('Daily', style: TextStyle(color: Colors.white)),
                          value: ReminderType.daily,
                          groupValue: _selectedType,
                          onChanged: (ReminderType? value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                          activeColor: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<ReminderType>(
                          title: const Text('Weekly', style: TextStyle(color: Colors.white)),
                          value: ReminderType.weekly,
                          groupValue: _selectedType,
                          onChanged: (ReminderType? value) {
                            setState(() {
                              _selectedType = value!;
                            });
                          },
                          activeColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // Day of Week (for weekly)
                  if (_selectedType == ReminderType.weekly) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Day of Week',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedDayOfWeek,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.grey[900],
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 1, child: Text('Monday', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 2, child: Text('Tuesday', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 3, child: Text('Wednesday', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 4, child: Text('Thursday', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 5, child: Text('Friday', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 6, child: Text('Saturday', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 7, child: Text('Sunday', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (int? value) {
                        setState(() {
                          _selectedDayOfWeek = value!;
                        });
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Time
                  const Text(
                    'Time',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content Type
                  const Text(
                    'Content Type',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: ContentType.values.map((type) {
                      return RadioListTile<ContentType>(
                        title: Text(
                          type.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: type,
                        groupValue: _selectedContentType,
                        onChanged: (ContentType? value) {
                          setState(() {
                            _selectedContentType = value!;
                          });
                        },
                        activeColor: Colors.white,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Categories
                  const Text(
                    'Categories',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _availableCategories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category, style: TextStyle(color: isSelected ? Colors.black : Colors.white)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[800],
                        selectedColor: Colors.white,
                        checkmarkColor: Colors.black,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('Schedule Reminder', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 