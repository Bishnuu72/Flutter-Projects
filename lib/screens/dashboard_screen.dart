import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/models/quote_model.dart';
import 'package:manshi/models/user_model.dart';
import 'package:manshi/models/category_model.dart';
import 'package:manshi/models/health_tip_model.dart';
// Add imports for the other screens (adjust paths if needed)
import 'package:manshi/screens/favorites_screen.dart'; // Import FavoritesScreen
import 'package:manshi/screens/reminder_screen.dart'; // Import ReminderScreen

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

  // Bottom navigation state (Home/Favourites/Reminders)
  int _navIndex = 0;

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
        if (!mounted) return;
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

        if (!mounted) return;
        setState(() {
          quoteCategories = fetchedQuoteCategories;
          healthCategories = fetchedHealthCategories;
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkUnreadNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      hasUnreadNotifications = true;
    });
  }

  // Function to get dynamic greeting based on time
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Function to get first name
  String getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'User';
    return fullName.split(' ').first;
  }

  Widget buildQuoteCategoryHorizontalList(
      List<CategoryModel> categories,
      String categoryType,
      BuildContext context,
      ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final hasImage = (category.imageUrl?.isNotEmpty ?? false);
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                RoutesName.motivationScreen,
                arguments: {
                  'categoryName': category.name,
                  'categoryType': categoryType,
                },
              );
            },
            child: Container(
              width: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).cardColor,
                image: hasImage
                    ? DecorationImage(
                  image: CachedNetworkImageProvider(category.imageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
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

  // Updated navigation: Direct switch using IndexedStack (no push/pop, no reset)
  void _onNavTap(int index) {
    setState(() => _navIndex = index); // Directly switch the index
  }

  // Home/Dashboard content widget (extracted for IndexedStack)
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar (Avatar left, Greeting + First Name, Notifications right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Avatar + texts (tap to open profile)
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, RoutesName.profileScreen),
                    child: Row(
                      children: [
                        currentUser?.profileImage != null
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getGreeting(),
                                style: TextStyle(
                                  color:
                                  Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                getFirstName(currentUser?.name),
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right: Notifications icon with badge
                IconButton(
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.notifications,
                        size: 28,
                        color: Theme.of(context).iconTheme.color,
                      ),
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
                            child: const Center(
                              child: Text(
                                '!',
                                style: TextStyle(
                                  color: Colors.white,
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
              ],
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
                  ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
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

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of pages for direct switching
    final List<Widget> pages = [
      _buildHomeContent(), // Index 0: Home (Dashboard content)
      const FavoritesScreen(), // Index 1: Favourites (direct content)
      const ReminderScreen(), // Index 2: Set Reminder (direct content)
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // Bottom Navigation Bar: Home, Favourites, Set Reminder
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onNavTap,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: Theme.of(context).bottomAppBarTheme.color ??
            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite_outline_rounded,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
            ),
            selectedIcon: Icon(
              Icons.favorite_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.alarm_add_outlined,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
            ),
            selectedIcon: Icon(
              Icons.alarm_on_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            label: 'Set Reminder',
          ),
        ],
      ),

      body: IndexedStack(
        index: _navIndex,
        children: pages, // Directly switches between contents
      ),
    );
  }
}