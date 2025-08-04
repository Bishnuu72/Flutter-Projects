import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/models/quote_model.dart';
import 'package:manshi/models/user_model.dart';
import 'package:manshi/models/category_model.dart';
import 'package:manshi/models/health_tip_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  QuoteModel? todayQuote;
  UserModel? currentUser;
  bool isLoading = true;

  // Quotes
  List<CategoryModel> quoteCategories = [];
  String? selectedQuoteCategoryId;
  List<QuoteModel> categoryQuotes = [];

  // Health Tips
  List<CategoryModel> healthCategories = [];
  String? selectedHealthCategoryId;
  List<HealthTipModel> categoryHealthTips = [];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirestoreService.getUser(user.uid);
        setState(() {
          currentUser = userData;
        });

        final quotes = await FirestoreService.getQuotes();
        if (quotes.isNotEmpty) {
          if (userData != null && userData.preferences.isNotEmpty) {
            final personalizedQuotes =
            await FirestoreService.getQuotesByPreferences(userData.preferences);
            todayQuote = personalizedQuotes.isNotEmpty ? personalizedQuotes.first : quotes.first;
          } else {
            todayQuote = quotes.first;
          }
        }

        final fetchedQuoteCategories = await FirestoreService.getQuoteCategories();
        final fetchedHealthCategories = await FirestoreService.getHealthCategories();

        setState(() {
          quoteCategories = fetchedQuoteCategories;
          healthCategories = fetchedHealthCategories;
        });
      }
    } catch (e) {
      // Handle or log error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // We don't need loadQuotesByCategory and loadHealthTipsByCategory here
  // because navigation will happen instead of loading data on this screen.

  Widget buildCategoryChips(
      List<CategoryModel> categories,
      String? selectedId,
      String categoryType, // 'quote' or 'health'
      BuildContext context,
      ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category.id == selectedId;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                category.name,
                style: TextStyle(color: isSelected ? Colors.black : Colors.white),
              ),
              selected: isSelected,
              selectedColor: Colors.white,
              backgroundColor: Colors.grey[850],
              onSelected: (_) {
                Navigator.pushNamed(
                  context,
                  RoutesName.motivationScreen,
                  arguments: {
                    'categoryName': category.name,
                    'categoryType': categoryType,
                  },
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildQuoteList(List<QuoteModel> list) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (list.isEmpty) {
      return const Text(
        "No data found in this category.",
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.map((item) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${item.text}"',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "- ${item.author}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildHealthTipList(List<HealthTipModel> list) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (list.isEmpty) {
      return const Text(
        "No data found in this category.",
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.map((item) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

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
                    child: currentUser?.profileImage != null
                        ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(currentUser!.profileImage!),
                    )
                        : CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Text(
                        currentUser?.name.isNotEmpty == true
                            ? currentUser!.name[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, RoutesName.favoritesScreen),
                      icon: const Icon(Icons.favorite_border, size: 28),
                      label: const Text('My Favorites', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, RoutesName.motivationScreen),
                      icon: const Icon(Icons.format_quote, size: 28),
                      label: const Text('Motivation', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, RoutesName.reminderScreen),
                  icon: const Icon(Icons.alarm, size: 28),
                  label: const Text('Schedule Reminder', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Today's Quote",
                style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : todayQuote != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${todayQuote!.text}"',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "- ${todayQuote!.author}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  ],
                )
                    : const Text(
                  '"Your wellness is an investment, not an expense."\n- Bishnu Kumar Yadav',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Quote Categories",
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              buildCategoryChips(quoteCategories, selectedQuoteCategoryId, 'quote', context),
              const SizedBox(height: 20),
              const Text(
                "Health Tips",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              buildCategoryChips(healthCategories, selectedHealthCategoryId, 'health', context),
            ],
          ),
        ),
      ),
    );
  }
}
