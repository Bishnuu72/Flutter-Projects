import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/models/quote_model.dart';
import 'package:manshi/models/user_model.dart';
import 'package:manshi/models/health_tip_model.dart';
import 'package:share_plus/share_plus.dart'; // For share button

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  List<dynamic> contentItems = []; // Generic list for quotes or health tips
  UserModel? currentUser;
  bool isLoading = true;
  int currentIndex = 0; // For current page in PageView

  String? selectedCategoryName; // For strict category query
  String? categoryType; // 'quote' or 'health'

  bool _argsLoaded = false; // Flag to load args only once

  @override
  void initState() {
    super.initState();
    // Do not load args or content here - move to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      // Read args here (safe after initState)
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        selectedCategoryName = args['categoryName'] as String?;
        categoryType = args['categoryType'] as String?;
        log("Navigation args: categoryName=$selectedCategoryName, type=$categoryType");
      } else {
        log("No navigation args - fallback to default");
      }
      _argsLoaded = true;
      loadContent();
    }
  }

  Future<void> loadContent() async {
    setState(() {
      isLoading = true;
      currentIndex = 0; // Reset to first item
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirestoreService.getUser(user.uid);
        setState(() {
          currentUser = userData;
        });
        log("User loaded: UID=${user.uid}, Preferences=${userData?.preferences}");

        log("Starting load for categoryName: $selectedCategoryName, Type: $categoryType");

        if (categoryType == 'quote' || categoryType == null) { // Fallback to quote if type null
          if (selectedCategoryName != null && selectedCategoryName!.isNotEmpty) {
            // Strict query for category-specific quotes (exact 'category' == name)
            final snapshot = await FirebaseFirestore.instance
                .collection('quotes')
                .where('category', isEqualTo: selectedCategoryName)
                .get();
            final selectedQuotes = snapshot.docs.map((doc) => QuoteModel.fromMap(doc.id, doc.data())).toList();
            log("Loaded ${selectedQuotes.length} quotes ONLY for category $selectedCategoryName (strict 'category' == name)");
            if (selectedQuotes.isEmpty) {
              log("WARNING: No quotes for '$selectedCategoryName' - add quotes with 'category' = '$selectedCategoryName'");
            }
            setState(() {
              contentItems = selectedQuotes;
            });
          } else if (userData != null && userData.preferences.isNotEmpty) {
            final personalizedQuotes = await FirestoreService.getQuotesByPreferences(userData.preferences);
            log("Loaded ${personalizedQuotes.length} personalized quotes based on preferences: ${userData.preferences}");
            if (personalizedQuotes.isEmpty) {
              log("WARNING: No personalized quotes - falling back to all quotes");
              final allQuotesData = await FirestoreService.getQuotes();
              setState(() {
                contentItems = allQuotesData;
              });
            } else {
              setState(() {
                contentItems = personalizedQuotes;
              });
            }
          } else {
            log("Falling back to all quotes");
            final allQuotesData = await FirestoreService.getQuotes();
            setState(() {
              contentItems = allQuotesData;
            });
          }
        } else if (categoryType == 'health') {
          if (selectedCategoryName != null && selectedCategoryName!.isNotEmpty) {
            // Strict query for category-specific tips (exact 'categoryId' == name)
            final selectedTips = await FirestoreService.getHealthTipsByCategory(selectedCategoryName!);
            log("Loaded ${selectedTips.length} health tips ONLY for category $selectedCategoryName (strict 'categoryId' == name)");
            if (selectedTips.isEmpty) {
              log("WARNING: No health tips for '$selectedCategoryName' - add tips with 'categoryId' = '$selectedCategoryName'");
            }
            setState(() {
              contentItems = selectedTips;
            });
          } else {
            // Fallback: Load all health tips if no category
            final allTips = await FirestoreService.getHealthTips();
            log("Loaded ${allTips.length} all health tips from Firestore");
            if (allTips.isEmpty) {
              log("WARNING: No health tips in 'healthTips' collection");
            }
            setState(() {
              contentItems = allTips;
            });
          }
        }
      } else {
        log("No user logged in - cannot load content");
      }
    } catch (e) {
      log("Error loading content: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load content: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
      log("Load complete: Final ${contentItems.length} items loaded for $categoryType in $selectedCategoryName");
    }
  }

  bool isQuoteFavorite(String quoteId) {
    return currentUser?.favoriteQuotes.contains(quoteId) ?? false;
  }

  Future<void> toggleFavorite(String quoteId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreService.toggleFavoriteQuote(user.uid, quoteId);
        if (mounted) {
          setState(() {
            currentUser?.toggleFavorite(quoteId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updated favorites')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorites: $e')),
        );
      }
    }
  }

  void shareQuote(String text, String author) {
    final quote = '"$text" - $author';
    Share.share(quote);
  }

  @override
  Widget build(BuildContext context) {
    final isQuoteType = categoryType == 'quote' || categoryType == null;
    final title = selectedCategoryName != null && selectedCategoryName!.isNotEmpty
        ? selectedCategoryName!
        : (isQuoteType ? 'Motivation' : 'Health Tips');

    return Scaffold(
      backgroundColor: Colors.black, // Dark background as per screenshot
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_off, color: Colors.white), // Mute icon (placeholder)
            onPressed: () {
              // Add mute functionality if needed (e.g., toggle sound)
              log("Mute toggled");
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadContent,
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : contentItems.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isQuoteType ? Icons.format_quote : Icons.health_and_safety,
                  size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('No ${isQuoteType ? 'quotes' : 'health tips'} available for $title',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              SizedBox(height: 8),
              Text('Swipe up to refresh or add more.',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        )
            : PageView.builder(
          scrollDirection: Axis.vertical, // Swipe up for next
          itemCount: contentItems.length,
          onPageChanged: (index) {
            currentIndex = index;
          },
          itemBuilder: (context, index) {
            final item = contentItems[index];
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isQuoteType) ...[
                      Text(
                        '"${(item as QuoteModel).text}"',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '- ${(item as QuoteModel).author}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Text(
                        (item as HealthTipModel).content,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: 48),
                    Text(
                      'Swipe up',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    Icon(Icons.gesture, color: Colors.grey),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            isQuoteType && isQuoteFavorite((item as QuoteModel).id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isQuoteType && isQuoteFavorite((item as QuoteModel).id) ? Colors.red : Colors.white,
                          ),
                          onPressed: isQuoteType
                              ? () => toggleFavorite((item as QuoteModel).id)
                              : null, // Disable for health tips
                        ),
                        SizedBox(width: 24),
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            if (isQuoteType) {
                              shareQuote((item as QuoteModel).text, (item as QuoteModel).author);
                            } else {
                              Share.share((item as HealthTipModel).content);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}