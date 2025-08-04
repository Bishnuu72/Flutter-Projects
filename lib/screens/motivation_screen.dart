import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manshi/services/firestore_service.dart';
import 'package:manshi/models/quote_model.dart';
import 'package:manshi/models/user_model.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  List<QuoteModel> quotes = [];
  List<QuoteModel> allQuotes = [];
  UserModel? currentUser;
  bool isLoading = true;
  bool showAllQuotes = false;

  String? selectedCategoryName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Read navigation arguments only once
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      selectedCategoryName = args['categoryName'] as String?;
    }

    loadQuotes();
  }

  Future<void> loadQuotes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirestoreService.getUser(user.uid);
        setState(() {
          currentUser = userData;
        });

        final allQuotesData = await FirestoreService.getQuotes();
        setState(() {
          allQuotes = allQuotesData;
        });

        if (selectedCategoryName != null && selectedCategoryName!.isNotEmpty) {
          final selectedQuotes = await FirestoreService.getQuotesByCategory(selectedCategoryName!);
          setState(() {
            quotes = selectedQuotes;
          });
        } else if (userData != null && userData.preferences.isNotEmpty) {
          final personalizedQuotes = await FirestoreService.getQuotesByPreferences(userData.preferences);
          setState(() {
            quotes = personalizedQuotes;
          });
        } else {
          setState(() {
            quotes = allQuotesData;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load quotes: $e')),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  bool isQuoteFavorite(String quoteId) {
    return currentUser?.favoriteQuotes.contains(quoteId) ?? false;
  }

  void handleToggleQuotes() {
    setState(() {
      showAllQuotes = !showAllQuotes;
      if (showAllQuotes) {
        quotes = allQuotes;
      } else if (currentUser?.preferences.isNotEmpty == true) {
        quotes = allQuotes.where((quote) {
          return quote.preferences.any((pref) => currentUser!.preferences.contains(pref));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = selectedCategoryName != null && selectedCategoryName!.isNotEmpty
        ? selectedCategoryName!
        : 'Motivation';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (selectedCategoryName == null)
            IconButton(
              onPressed: handleToggleQuotes,
              icon: Icon(
                showAllQuotes ? Icons.person : Icons.public,
                color: Colors.white,
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : quotes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_quote, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text('No quotes available',
                style: TextStyle(color: Colors.grey[600], fontSize: 18)),
            const SizedBox(height: 8),
            Text('Check back later for new motivational quotes',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center),
          ],
        ),
      )
          : Column(
        children: [
          if (selectedCategoryName == null &&
              currentUser?.preferences.isNotEmpty == true &&
              !showAllQuotes)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Showing quotes personalized for you',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                final quote = quotes[index];
                final isFavorite = isQuoteFavorite(quote.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '"${quote.text}"',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => toggleFavorite(quote.id),
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '- ${quote.author}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
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
}
