import 'package:cached_network_image/cached_network_image.dart';
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

  bool hasUnreadNotifications = false;

  List<CategoryModel> quoteCategories = [];
  String? selectedQuoteCategoryId;
  List<QuoteModel> categoryQuotes = [];

  List<CategoryModel> healthCategories = [];
  String? selectedHealthCategoryId;
  List<HealthTipModel> categoryHealthTips = [];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
    checkUnreadNotifications();
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
      debugPrint("Error loading dashboard data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkUnreadNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      hasUnreadNotifications = true;
    });
  }

  Widget buildQuoteCategoryHorizontalList(
      List<CategoryModel> categories,
      String categoryType,
      BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 130, // Increase height
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                RoutesName.motivationScreen,
                arguments: {
                  'categoryName': category.name, // Pass name for exact category query
                  'categoryType': categoryType,
                },
              );
            },
            child: Container(
              width: 180, // Increase width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(category.imageUrl ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: (isDarkMode ? Colors.black : Colors.white).withOpacity(0.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Explore',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Stack(
                          children: [
                            Icon(Icons.notifications,
                                size: 28, color: Theme.of(context).iconTheme.color),
                            if (hasUnreadNotifications)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '!',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, RoutesName.notificationScreen);
                        },
                      ),
                      const SizedBox(width: 10),
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
                          backgroundColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            currentUser?.name.isNotEmpty == true
                                ? currentUser!.name[0].toUpperCase()
                                : "?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, RoutesName.favoritesScreen),
                      icon: Icon(Icons.favorite_border,
                          size: 28, color: Theme.of(context).iconTheme.color),
                      label: Text('My Favorites',
                          style: TextStyle(
                              fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, RoutesName.motivationScreen, arguments: {
                        'categoryName': null, // Null for all quotes
                        'categoryType': 'quote',
                      }),
                      icon: Icon(Icons.format_quote,
                          size: 28, color: Theme.of(context).iconTheme.color),
                      label: Text('Motivation',
                          style: TextStyle(
                              fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
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
                  icon: Icon(Icons.alarm, size: 28, color: Theme.of(context).iconTheme.color),
                  label: Text('Schedule Reminder',
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Today's Quote",
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                    : todayQuote != null
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${todayQuote!.text}"',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "- ${todayQuote!.author}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  ],
                )
                    : Text(
                  '"Your wellness is an investment, not an expense."\n- Bishnu Kumar Yadav',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Quote Categories",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildQuoteCategoryHorizontalList(quoteCategories, 'quote', context),
              const SizedBox(height: 20),
              Text(
                "Health Tips",
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildQuoteCategoryHorizontalList(healthCategories, 'health', context),
            ],
          ),
        ),
      ),
    );
  }
}