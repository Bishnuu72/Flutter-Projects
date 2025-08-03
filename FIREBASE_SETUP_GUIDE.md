# Firebase Setup Guide for Wellness App

This guide will help you set up Firebase for the Wellness App project, including Authentication, Cloud Firestore, and Cloud Messaging.

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. Firebase CLI installed (optional but recommended)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `wellness-app-manshi` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Choose Analytics account or create new one
6. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click the Android icon (</>) to add Android app
2. Enter Android package name: `com.example.manshi`
3. Enter app nickname: `Wellness App`
4. Enter SHA-1 certificate fingerprint (optional for now)
5. Click "Register app"
6. Download `google-services.json` file
7. Place `google-services.json` in `android/app/` directory

## Step 3: Add iOS App (if needed)

1. In Firebase Console, click the iOS icon to add iOS app
2. Enter iOS bundle ID: `com.example.manshi`
3. Enter app nickname: `Wellness App`
4. Click "Register app"
5. Download `GoogleService-Info.plist` file
6. Place `GoogleService-Info.plist` in `ios/Runner/` directory

## Step 4: Enable Authentication

1. In Firebase Console, go to "Authentication" section
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Enable "Google" provider
   - Add your support email
   - Configure OAuth consent screen if needed

## Step 5: Set Up Cloud Firestore

1. In Firebase Console, go to "Firestore Database" section
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select location closest to your users
5. Click "Done"

### Firestore Security Rules

Replace the default rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read categories, preferences, quotes, and health tips
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
    
    // Users can manage their own reminders
    match /reminders/{reminderId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

## Step 6: Set Up Cloud Messaging (FCM)

1. In Firebase Console, go to "Cloud Messaging" section
2. Go to "Project settings" tab
3. Scroll down to "Cloud Messaging" section
4. Copy the "Server key" (you'll need this for sending notifications)

### Update FCM Configuration

1. Open `lib/config/fcm_config.dart`
2. Replace `YOUR_FCM_SERVER_KEY_HERE` with your actual server key:

```dart
class FCMConfig {
  static const String serverKey = 'YOUR_ACTUAL_SERVER_KEY_HERE';
}
```

## Step 7: Database Structure

The app uses the following Firestore collections:

### Users Collection
```javascript
{
  "name": "string",
  "email": "string", 
  "role": "user" | "admin",
  "preferences": ["array of preference IDs"],
  "favoriteQuotes": ["array of quote IDs"],
  "fcmToken": "string",
  "createdAt": "timestamp"
}
```

### Categories Collection
```javascript
{
  "name": "string",
  "description": "string",
  "createdAt": "timestamp"
}
```

### Preferences Collection
```javascript
{
  "name": "string",
  "categoryId": "string",
  "description": "string",
  "createdAt": "timestamp"
}
```

### Quotes Collection
```javascript
{
  "text": "string",
  "author": "string",
  "category": "string",
  "categories": ["array of category names"],
  "preferences": ["array of preference IDs"],
  "createdAt": "timestamp"
}
```

### Health Tips Collection
```javascript
{
  "title": "string",
  "content": "string",
  "categoryId": "string",
  "preferenceId": "string",
  "createdAt": "timestamp"
}
```

### Reminders Collection
```javascript
{
  "userId": "string",
  "title": "string",
  "body": "string",
  "type": "daily" | "weekly",
  "contentType": "quote" | "healthTip" | "both",
  "categories": ["array of category names"],
  "hour": "number",
  "minute": "number",
  "dayOfWeek": "number (1-7, optional for weekly)",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "lastTriggered": "timestamp (optional)"
}
```

## Step 8: Initialize Sample Data

1. Run the app for the first time
2. Navigate to the admin dashboard
3. Use the "Initialize Sample Data" feature to populate the database with:
   - Categories (Mental Health, Physical Fitness, Nutrition, etc.)
   - Preferences (Stress Management, Cardio, Healthy Eating, etc.)
   - Sample quotes and health tips

## Step 9: Test the Setup

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the app
3. Test user registration and login
4. Test admin functionality (add categories, quotes, health tips)
5. Test FCM notifications

## Troubleshooting

### Common Issues:

1. **google-services.json not found**: Make sure the file is in `android/app/` directory
2. **FCM not working**: Check that the server key is correctly set in `fcm_config.dart`
3. **Firestore permission denied**: Check security rules and ensure user is authenticated
4. **Build errors**: Run `flutter clean` and `flutter pub get`

### Getting SHA-1 Certificate Fingerprint:

For debug builds:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

For release builds:
```bash
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

## Security Best Practices

1. **Never commit sensitive keys to version control**
2. **Use environment variables for production keys**
3. **Regularly review and update security rules**
4. **Monitor Firebase usage and costs**
5. **Keep Firebase SDK versions updated**

## Next Steps

1. Set up Firebase Analytics for user behavior tracking
2. Configure Firebase Crashlytics for error reporting
3. Set up Firebase Performance Monitoring
4. Configure Firebase Remote Config for feature flags
5. Set up automated backups for Firestore data

## Support

If you encounter issues:
1. Check Firebase Console for error logs
2. Review Flutter Firebase documentation
3. Check Firebase status page for service issues
4. Consult Firebase support forums 