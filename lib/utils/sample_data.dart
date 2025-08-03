import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/preference_model.dart';
import '../models/quote_model.dart';
import '../models/health_tip_model.dart';

class SampleData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeSampleData() async {
    try {
      // Initialize categories
      await _initializeCategories();
      
      // Initialize preferences
      await _initializePreferences();
      
      // Initialize quotes
      await _initializeQuotes();
      
      // Initialize health tips
      await _initializeHealthTips();
      
      print('Sample data initialized successfully!');
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }

  static Future<void> _initializeCategories() async {
    final categories = [
      CategoryModel(
        id: '',
        name: 'Mental Health',
        description: 'Focus on emotional well-being and psychological health',
        icon: 'psychology',
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        name: 'Physical Fitness',
        description: 'Exercise, strength training, and physical activities',
        icon: 'fitness_center',
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        name: 'Nutrition',
        description: 'Healthy eating habits and dietary guidance',
        icon: 'restaurant',
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        name: 'Mindfulness',
        description: 'Meditation, breathing exercises, and mental clarity',
        icon: 'self_improvement',
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: '',
        name: 'Relationships',
        description: 'Building and maintaining healthy relationships',
        icon: 'people',
        createdAt: DateTime.now(),
      ),
    ];

    for (final category in categories) {
      await _firestore.collection('categories').add(category.toMap());
    }
  }

  static Future<void> _initializePreferences() async {
    // Get category IDs first
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final categoryDocs = categoriesSnapshot.docs;
    
    final preferences = [
      // Mental Health preferences
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[0].id, // Mental Health
        name: 'Stress Management',
        description: 'Techniques to manage and reduce stress',
        createdAt: DateTime.now(),
      ),
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[0].id, // Mental Health
        name: 'Self-esteem',
        description: 'Building confidence and self-worth',
        createdAt: DateTime.now(),
      ),
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[0].id, // Mental Health
        name: 'Positive Thinking',
        description: 'Cultivating optimistic mindset',
        createdAt: DateTime.now(),
      ),
      
      // Physical Fitness preferences
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[1].id, // Physical Fitness
        name: 'Cardio Workouts',
        description: 'Aerobic exercises and endurance training',
        createdAt: DateTime.now(),
      ),
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[1].id, // Physical Fitness
        name: 'Strength Training',
        description: 'Building muscle and physical strength',
        createdAt: DateTime.now(),
      ),
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[1].id, // Physical Fitness
        name: 'Yoga',
        description: 'Flexibility and mind-body connection',
        createdAt: DateTime.now(),
      ),
      
      // Nutrition preferences
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[2].id, // Nutrition
        name: 'Healthy Eating',
        description: 'Balanced and nutritious diet',
        createdAt: DateTime.now(),
      ),
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[2].id, // Nutrition
        name: 'Meal Planning',
        description: 'Organized and healthy meal preparation',
        createdAt: DateTime.now(),
      ),
      
      // Mindfulness preferences
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[3].id, // Mindfulness
        name: 'Meditation',
        description: 'Mental clarity and inner peace',
        createdAt: DateTime.now(),
      ),
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[3].id, // Mindfulness
        name: 'Breathing Exercises',
        description: 'Deep breathing and relaxation techniques',
        createdAt: DateTime.now(),
      ),
      
      // Relationships preferences
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[4].id, // Relationships
        name: 'Communication',
        description: 'Effective communication skills',
        createdAt: DateTime.now(),
      ),
      PreferenceModel(
        id: '',
        categoryId: categoryDocs[4].id, // Relationships
        name: 'Self-love',
        description: 'Caring for yourself first',
        createdAt: DateTime.now(),
      ),
    ];

    for (final preference in preferences) {
      await _firestore.collection('preferences').add(preference.toMap());
    }
  }

  static Future<void> _initializeQuotes() async {
    // Get preference IDs for tagging
    final preferencesSnapshot = await _firestore.collection('preferences').get();
    final preferenceDocs = preferencesSnapshot.docs;
    
    final quotes = [
      QuoteModel(
        id: '',
        text: 'Your wellness is an investment, not an expense.',
        author: 'Bishnu Kumar Yadav',
        category: 'Mental Health',
        categories: ['Mental Health', 'Self-esteem'],
        preferences: [preferenceDocs[1].id], // Self-esteem
        createdAt: DateTime.now(),
      ),
      QuoteModel(
        id: '',
        text: 'The only bad workout is the one that didn\'t happen.',
        author: 'Unknown',
        category: 'Physical Fitness',
        categories: ['Physical Fitness'],
        preferences: [preferenceDocs[3].id, preferenceDocs[4].id], // Cardio, Strength
        createdAt: DateTime.now(),
      ),
      QuoteModel(
        id: '',
        text: 'You are what you eat, so don\'t be fast, cheap, easy, or fake.',
        author: 'Unknown',
        category: 'Nutrition',
        categories: ['Nutrition'],
        preferences: [preferenceDocs[6].id], // Healthy Eating
        createdAt: DateTime.now(),
      ),
      QuoteModel(
        id: '',
        text: 'Peace comes from within. Do not seek it without.',
        author: 'Buddha',
        category: 'Mindfulness',
        categories: ['Mindfulness'],
        preferences: [preferenceDocs[8].id], // Meditation
        createdAt: DateTime.now(),
      ),
      QuoteModel(
        id: '',
        text: 'The most important relationship in your life is the relationship you have with yourself.',
        author: 'Diane von Furstenberg',
        category: 'Relationships',
        categories: ['Relationships', 'Self-esteem'],
        preferences: [preferenceDocs[1].id, preferenceDocs[11].id], // Self-esteem, Self-love
        createdAt: DateTime.now(),
      ),
      QuoteModel(
        id: '',
        text: 'Take care of your body. It\'s the only place you have to live.',
        author: 'Jim Rohn',
        category: 'Physical Fitness',
        categories: ['Physical Fitness', 'Health'],
        preferences: [preferenceDocs[3].id, preferenceDocs[4].id], // Cardio, Strength
        createdAt: DateTime.now(),
      ),
      QuoteModel(
        id: '',
        text: 'Every day is a new beginning. Take a deep breath and start again.',
        author: 'Unknown',
        category: 'Mindfulness',
        categories: ['Mindfulness', 'Mental Health'],
        preferences: [preferenceDocs[0].id, preferenceDocs[9].id], // Stress Management, Breathing
        createdAt: DateTime.now(),
      ),
      QuoteModel(
        id: '',
        text: 'You don\'t have to be perfect to be amazing.',
        author: 'Unknown',
        category: 'Mental Health',
        categories: ['Mental Health', 'Self-esteem'],
        preferences: [preferenceDocs[1].id, preferenceDocs[2].id], // Self-esteem, Positive Thinking
        createdAt: DateTime.now(),
      ),
    ];

    for (final quote in quotes) {
      await _firestore.collection('quotes').add(quote.toMap());
    }
  }

  static Future<void> _initializeHealthTips() async {
    // Get category and preference IDs
    final categoriesSnapshot = await _firestore.collection('categories').get();
    final preferencesSnapshot = await _firestore.collection('preferences').get();
    final categoryDocs = categoriesSnapshot.docs;
    final preferenceDocs = preferencesSnapshot.docs;
    
    final healthTips = [
      HealthTipModel(
        id: '',
        title: 'Deep Breathing for Stress Relief',
        content: 'Take 5 deep breaths: inhale for 4 counts, hold for 4, exhale for 6. This simple technique can instantly reduce stress and anxiety.',
        categoryId: categoryDocs[3].id, // Mindfulness
        preferenceId: preferenceDocs[9].id, // Breathing Exercises
        createdAt: DateTime.now(),
      ),
      HealthTipModel(
        id: '',
        title: 'Start Your Day with Gratitude',
        content: 'Before getting out of bed, think of 3 things you\'re grateful for. This practice sets a positive tone for your entire day.',
        categoryId: categoryDocs[0].id, // Mental Health
        preferenceId: preferenceDocs[2].id, // Positive Thinking
        createdAt: DateTime.now(),
      ),
      HealthTipModel(
        id: '',
        title: 'The 10-Minute Rule',
        content: 'If you\'re feeling unmotivated to exercise, commit to just 10 minutes. Often, once you start, you\'ll want to continue.',
        categoryId: categoryDocs[1].id, // Physical Fitness
        preferenceId: preferenceDocs[3].id, // Cardio Workouts
        createdAt: DateTime.now(),
      ),
      HealthTipModel(
        id: '',
        title: 'Mindful Eating',
        content: 'Eat without distractions, savor each bite, and listen to your body\'s hunger and fullness cues.',
        categoryId: categoryDocs[2].id, // Nutrition
        preferenceId: preferenceDocs[6].id, // Healthy Eating
        createdAt: DateTime.now(),
      ),
      HealthTipModel(
        id: '',
        title: 'Daily Self-Check-in',
        content: 'Take 5 minutes each day to ask yourself: How am I feeling? What do I need? What am I grateful for?',
        categoryId: categoryDocs[0].id, // Mental Health
        preferenceId: preferenceDocs[1].id, // Self-esteem
        createdAt: DateTime.now(),
      ),
    ];

    for (final healthTip in healthTips) {
      await _firestore.collection('healthTips').add(healthTip.toMap());
    }
  }
} 