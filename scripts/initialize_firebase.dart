import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  print('Initializing Firebase database with sample data...');
  
  try {
    // Initialize categories
    await _initializeCategories();
    
    // Initialize preferences
    await _initializePreferences();
    
    // Initialize quotes
    await _initializeQuotes();
    
    // Initialize health tips
    await _initializeHealthTips();
    
    print('✅ Firebase database initialized successfully!');
    print('You can now run the app and login with admin credentials.');
    
  } catch (e) {
    print('❌ Error initializing database: $e');
  }
}

Future<void> _initializeCategories() async {
  print('Creating categories...');
  
  final categories = [
    {
      'name': 'Mental Health',
      'description': 'Focus on emotional well-being and mental clarity',
    },
    {
      'name': 'Physical Fitness',
      'description': 'Exercise and physical activity for better health',
    },
    {
      'name': 'Nutrition',
      'description': 'Healthy eating habits and dietary guidance',
    },
    {
      'name': 'Mindfulness',
      'description': 'Meditation and present-moment awareness',
    },
    {
      'name': 'Sleep & Recovery',
      'description': 'Quality sleep and rest for optimal performance',
    },
  ];
  
  for (final category in categories) {
    await FirebaseFirestore.instance.collection('categories').add({
      ...category,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  print('✅ Categories created');
}

Future<void> _initializePreferences() async {
  print('Creating preferences...');
  
  // Get category documents
  final categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();
  final categories = categoriesSnapshot.docs;
  
  final preferences = [
    // Mental Health preferences
    {
      'name': 'Stress Management',
      'categoryId': categories[0].id,
      'description': 'Techniques to manage and reduce stress',
    },
    {
      'name': 'Self-esteem',
      'categoryId': categories[0].id,
      'description': 'Building confidence and self-worth',
    },
    {
      'name': 'Anxiety Relief',
      'categoryId': categories[0].id,
      'description': 'Methods to calm anxiety and worry',
    },
    
    // Physical Fitness preferences
    {
      'name': 'Cardio Training',
      'categoryId': categories[1].id,
      'description': 'Cardiovascular exercises and workouts',
    },
    {
      'name': 'Strength Training',
      'categoryId': categories[1].id,
      'description': 'Building muscle and strength',
    },
    {
      'name': 'Yoga',
      'categoryId': categories[1].id,
      'description': 'Flexibility and balance through yoga',
    },
    
    // Nutrition preferences
    {
      'name': 'Healthy Eating',
      'categoryId': categories[2].id,
      'description': 'Balanced and nutritious meal planning',
    },
    {
      'name': 'Weight Management',
      'categoryId': categories[2].id,
      'description': 'Maintaining healthy weight through diet',
    },
    
    // Mindfulness preferences
    {
      'name': 'Meditation',
      'categoryId': categories[3].id,
      'description': 'Mindfulness and meditation practices',
    },
    {
      'name': 'Breathing Exercises',
      'categoryId': categories[3].id,
      'description': 'Deep breathing and relaxation techniques',
    },
    
    // Sleep preferences
    {
      'name': 'Sleep Hygiene',
      'categoryId': categories[4].id,
      'description': 'Healthy sleep habits and routines',
    },
    {
      'name': 'Recovery',
      'categoryId': categories[4].id,
      'description': 'Rest and recovery strategies',
    },
  ];
  
  for (final preference in preferences) {
    await FirebaseFirestore.instance.collection('preferences').add({
      ...preference,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  print('✅ Preferences created');
}

Future<void> _initializeQuotes() async {
  print('Creating quotes...');
  
  // Get preference documents
  final preferencesSnapshot = await FirebaseFirestore.instance.collection('preferences').get();
  final preferences = preferencesSnapshot.docs;
  
  final quotes = [
    {
      'text': 'Your wellness is an investment, not an expense.',
      'author': 'Bishnu Kumar Yadav',
      'category': 'Mental Health',
      'categories': ['Mental Health', 'Self-esteem'],
      'preferences': [preferences[1].id], // Self-esteem
    },
    {
      'text': 'The only bad workout is the one that didn\'t happen.',
      'author': 'Unknown',
      'category': 'Physical Fitness',
      'categories': ['Physical Fitness', 'Cardio Training'],
      'preferences': [preferences[3].id], // Cardio Training
    },
    {
      'text': 'You are what you eat, so don\'t be fast, cheap, easy, or fake.',
      'author': 'Unknown',
      'category': 'Nutrition',
      'categories': ['Nutrition', 'Healthy Eating'],
      'preferences': [preferences[6].id], // Healthy Eating
    },
    {
      'text': 'Peace comes from within. Do not seek it without.',
      'author': 'Buddha',
      'category': 'Mindfulness',
      'categories': ['Mindfulness', 'Meditation'],
      'preferences': [preferences[8].id], // Meditation
    },
    {
      'text': 'Sleep is the best meditation.',
      'author': 'Dalai Lama',
      'category': 'Sleep & Recovery',
      'categories': ['Sleep & Recovery', 'Sleep Hygiene'],
      'preferences': [preferences[10].id], // Sleep Hygiene
    },
    {
      'text': 'Take care of your body. It\'s the only place you have to live.',
      'author': 'Jim Rohn',
      'category': 'Physical Fitness',
      'categories': ['Physical Fitness', 'Strength Training'],
      'preferences': [preferences[4].id], // Strength Training
    },
    {
      'text': 'The mind and body are not separate. What affects one, affects the other.',
      'author': 'Unknown',
      'category': 'Mental Health',
      'categories': ['Mental Health', 'Stress Management'],
      'preferences': [preferences[0].id], // Stress Management
    },
    {
      'text': 'Every breath is a new beginning.',
      'author': 'Unknown',
      'category': 'Mindfulness',
      'categories': ['Mindfulness', 'Breathing Exercises'],
      'preferences': [preferences[9].id], // Breathing Exercises
    },
  ];
  
  for (final quote in quotes) {
    await FirebaseFirestore.instance.collection('quotes').add({
      ...quote,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  print('✅ Quotes created');
}

Future<void> _initializeHealthTips() async {
  print('Creating health tips...');
  
  // Get category and preference documents
  final categoriesSnapshot = await FirebaseFirestore.instance.collection('categories').get();
  final preferencesSnapshot = await FirebaseFirestore.instance.collection('preferences').get();
  final categories = categoriesSnapshot.docs;
  final preferences = preferencesSnapshot.docs;
  
  final healthTips = [
    {
      'title': 'Practice Deep Breathing',
      'content': 'Take 5-10 deep breaths when feeling stressed. Inhale for 4 counts, hold for 4, exhale for 6.',
      'categoryId': categories[0].id, // Mental Health
      'preferenceId': preferences[0].id, // Stress Management
    },
    {
      'title': 'Start Your Day with Exercise',
      'content': 'Even 10 minutes of morning exercise can boost your mood and energy for the entire day.',
      'categoryId': categories[1].id, // Physical Fitness
      'preferenceId': preferences[3].id, // Cardio Training
    },
    {
      'title': 'Eat the Rainbow',
      'content': 'Include colorful fruits and vegetables in every meal for a variety of nutrients.',
      'categoryId': categories[2].id, // Nutrition
      'preferenceId': preferences[6].id, // Healthy Eating
    },
    {
      'title': 'Mindful Walking',
      'content': 'Take a 10-minute walk and focus on each step, your breathing, and the world around you.',
      'categoryId': categories[3].id, // Mindfulness
      'preferenceId': preferences[8].id, // Meditation
    },
    {
      'title': 'Create a Sleep Routine',
      'content': 'Go to bed and wake up at the same time every day, even on weekends.',
      'categoryId': categories[4].id, // Sleep & Recovery
      'preferenceId': preferences[10].id, // Sleep Hygiene
    },
  ];
  
  for (final tip in healthTips) {
    await FirebaseFirestore.instance.collection('healthTips').add({
      ...tip,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  print('✅ Health tips created');
} 