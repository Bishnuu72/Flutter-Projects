import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manshi/models/reminder_model.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/firebase_auth/notification_service.dart';
import 'package:manshi/core/route_config/routes_name.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await FirestoreService.getCategories();
      if (!mounted) return;
      setState(() {
        _availableCategories = categories.map((c) => c.name).toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadUserReminders() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirestoreService.getUserReminders(currentUser.uid);
        // Optionally display existing reminders
      } catch (e) {
        // ignore/log
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

      final payload = json.encode({
        'type': 'reminder',
        'contentType': reminder.contentType.toString().split('.').last,
        'categories': reminder.categories,
      });

      if (_selectedType == ReminderType.daily) {
        await notificationService.scheduleDailyReminder(
          id: notificationId,
          title: reminder.title,
          body: reminder.body,
          hour: reminder.hour,
          minute: reminder.minute,
          payload: payload,
        );
      } else {
        await notificationService.scheduleWeeklyReminder(
          id: notificationId,
          title: reminder.title,
          body: reminder.body,
          dayOfWeek: reminder.dayOfWeek!,
          hour: reminder.hour,
          minute: reminder.minute,
          payload: payload,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Schedule Reminder',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoadingCategories
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // bottom padding for nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                labelText: 'Reminder Title',
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Body (optional)
            TextField(
              controller: _bodyController,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Reminder Message (optional)',
                labelStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reminder Type
            Text(
              'Reminder Type',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<ReminderType>(
                    title: Text(
                      'Daily',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    value: ReminderType.daily,
                    groupValue: _selectedType,
                    onChanged: (ReminderType? value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                Expanded(
                  child: RadioListTile<ReminderType>(
                    title: Text(
                      'Weekly',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    value: ReminderType.weekly,
                    groupValue: _selectedType,
                    onChanged: (ReminderType? value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),

            // Day of Week (for weekly)
            if (_selectedType == ReminderType.weekly) ...[
              const SizedBox(height: 16),
              Text(
                'Day of Week',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedDayOfWeek,
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                dropdownColor: Theme.of(context).cardColor,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Monday')),
                  DropdownMenuItem(value: 2, child: Text('Tuesday')),
                  DropdownMenuItem(value: 3, child: Text('Wednesday')),
                  DropdownMenuItem(value: 4, child: Text('Thursday')),
                  DropdownMenuItem(value: 5, child: Text('Friday')),
                  DropdownMenuItem(value: 6, child: Text('Saturday')),
                  DropdownMenuItem(value: 7, child: Text('Sunday')),
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
            Text(
              'Time',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Theme.of(context).iconTheme.color),
                    const SizedBox(width: 8),
                    Text(
                      _selectedTime.format(context),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Content Type
            Text(
              'Content Type',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: ContentType.values.map((type) {
                return RadioListTile<ContentType>(
                  title: Text(
                    type.toString().split('.').last.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  value: type,
                  groupValue: _selectedContentType,
                  onChanged: (ContentType? value) {
                    setState(() {
                      _selectedContentType = value!;
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Categories
            Text(
              'Categories',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? (isDarkMode ? Colors.black : Colors.white)
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
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
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  selectedColor: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                  checkmarkColor: isDarkMode ? Colors.black : Colors.white,
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
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: isDarkMode ? Colors.white : Colors.black,
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: isDarkMode ? Colors.black : Colors.white)
                    : const Text('Schedule Reminder', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}