# Complete Firebase Setup Guide for Wellness App

This guide will help you set up Firebase completely for the Wellness App and resolve the current navigation and data display issues.

## Prerequisites
- Flutter SDK installed
- Android Studio or VS Code
- Firebase account
- Android device or emulator

## Step 1: Firebase Project Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: "Wellness App" or "Manshi"
4. Enable Google Analytics (optional)
5. Click "Create project"

### 1.2 Add Android App
1. In Firebase console, click the Android icon
2. Enter Android package name: `com.example.manshi`
3. Enter app nickname: "Wellness App"
4. Click "Register app"
5. Download `google-services.json` file
6. Place it in `android/app/` directory

### 1.3 Configure Android Build Files
1. Open `android/build.gradle.kts` and ensure you have:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

2. Open `android/app/build.gradle.kts` and ensure you have:
```kotlin
plugins {
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}
```

## Step 2: Enable Firebase Services

### 2.1 Authentication
1. In Firebase console, go to "Authentication"
2. Click "Get started"
3. Enable "Email/Password" provider
4. Enable "Google" provider
5. Add your test email addresses to authorized domains

### 2.2 Cloud Firestore
1. In Firebase console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location close to your users
5. Click "Done"

### 2.3 Cloud Messaging (FCM)
1. In Firebase console, go to "Cloud Messaging"
2. Note down the Server key (you'll need this later)

## Step 3: Firestore Security Rules

Replace the default security rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read categories, preferences, quotes, health tips
    match /categories/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /preferences/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /quotes/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /healthTips/{document=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /reminders/{document=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

## Step 4: Update FCM Configuration

1. Open `lib/config/fcm_config.dart`
2. Replace `YOUR_FCM_SERVER_KEY_HERE` with your actual FCM server key from Step 2.3

## Step 5: Initialize Database with Sample Data

### 5.1 Create Admin User
1. Run the app
2. Register a new user with email/password
3. In Firebase console, go to Firestore Database
4. Find the user document in the `users` collection
5. Manually change the `role` field from `"user"` to `"admin"`

### 5.2 Initialize Sample Data
1. Login with the admin account
2. You should be redirected to the Admin Init Screen
3. Click "Initialize Sample Data" button
4. This will create:
   - 5 Wellness Categories
   - 12 User Preferences
   - 8 Motivational Quotes
   - 5 Health Tips

## Step 6: Test the Application

### 6.1 Test Admin Flow
1. Login with admin credentials
2. Should navigate to Admin Dashboard
3. Test adding categories, preferences, quotes, and health tips
4. Test user management features

### 6.2 Test User Flow
1. Register a new user account
2. Should navigate to Preference Selection
3. Select preferences and save
4. Should navigate to Dashboard
5. Test viewing personalized content

## Step 7: Troubleshooting Common Issues

### Issue 1: Admin login not navigating to admin page
**Solution:**
- Check if user document exists in Firestore
- Verify the `role` field is set to `"admin"`
- Check console logs for any errors

### Issue 2: Preference selection showing empty
**Solution:**
- Ensure sample data has been initialized
- Check if `preferences` collection exists in Firestore
- Verify Firestore security rules allow reading preferences

### Issue 3: FCM not working
**Solution:**
- Verify FCM server key is correctly set in `fcm_config.dart`
- Check if `google-services.json` is properly placed
- Ensure FCM is enabled in Firebase console

### Issue 4: Google Sign-In not working
**Solution:**
- Add your SHA-1 fingerprint to Firebase project
- Enable Google Sign-In in Firebase Authentication
- Add authorized domains in Firebase console

## Step 8: Database Structure Reference

### Collections Structure:

#### users
```json
{
  "name": "User Name",
  "email": "user@example.com",
  "role": "user|admin",
  "preferences": ["pref1", "pref2"],
  "favoriteQuotes": ["quote1", "quote2"],
  "fcmToken": "fcm_token_here",
  "createdAt": "timestamp"
}
```

#### categories
```json
{
  "name": "Category Name",
  "description": "Category description",
  "createdAt": "timestamp"
}
```

#### preferences
```json
{
  "name": "Preference Name",
  "categoryId": "category_doc_id",
  "description": "Preference description",
  "createdAt": "timestamp"
}
```

#### quotes
```json
{
  "text": "Quote text",
  "author": "Author name",
  "category": "Category name",
  "categories": ["cat1", "cat2"],
  "preferences": ["pref1", "pref2"],
  "createdAt": "timestamp"
}
```

#### healthTips
```json
{
  "title": "Tip title",
  "content": "Tip content",
  "categoryId": "category_doc_id",
  "preferenceId": "preference_doc_id",
  "createdAt": "timestamp"
}
```

#### reminders
```json
{
  "userId": "user_doc_id",
  "type": "daily|weekly",
  "contentType": "quote|healthTip|both",
  "categories": ["cat1", "cat2"],
  "time": "HH:mm",
  "dayOfWeek": 1-7 (for weekly),
  "isActive": true,
  "lastTriggered": "timestamp",
  "createdAt": "timestamp"
}
```

## Step 9: Final Verification

1. **Admin Features:**
   - [ ] Can login and access admin dashboard
   - [ ] Can add categories and preferences
   - [ ] Can add quotes and health tips
   - [ ] Can view and manage users
   - [ ] Can send targeted notifications

2. **User Features:**
   - [ ] Can register and login
   - [ ] Can select preferences
   - [ ] Can view personalized content
   - [ ] Can save favorite quotes
   - [ ] Can schedule reminders

3. **FCM Features:**
   - [ ] Receives notifications for new content
   - [ ] Receives scheduled reminders
   - [ ] Receives targeted admin notifications

## Support

If you encounter any issues:
1. Check the console logs for error messages
2. Use the debug buttons in the app to test Firebase connection
3. Verify all Firebase services are properly configured
4. Ensure the database structure matches the expected format

The app should now work correctly with proper navigation and data display for both admin and regular users. 