# Wellness App - Firebase & FCM Integration

A comprehensive wellness application built with Flutter, Firebase, and Firebase Cloud Messaging (FCM) for real-time notifications and personalized content delivery.

## Features

### User Features
- **Authentication**: Email/password and Google Sign-In
- **Personalized Content**: Quotes and health tips based on user preferences
- **Favorites System**: Save and manage favorite motivational quotes
- **Scheduled Reminders**: Set daily/weekly reminders for wellness content
- **Push Notifications**: Receive real-time notifications for new content

### Admin Features
- **User Management**: View all registered users with detailed information
- **Content Management**: Add and manage categories, quotes, and health tips
- **Targeted Notifications**: Send custom push notifications to selected users
- **Analytics Dashboard**: Overview of users, categories, quotes, and health tips

### Technical Features
- **FCM Integration**: Real-time push notifications
- **Firestore Database**: NoSQL database for all app data
- **Dynamic Content**: Content fetched from Firestore based on user preferences
- **Token Management**: Automatic FCM token updates and management

## Setup Instructions

### 1. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password and Google Sign-In)
3. Create a Firestore database
4. Download and add the configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

### 2. FCM Setup

1. In Firebase Console, go to **Project Settings** > **Cloud Messaging**
2. Copy the **Server key**
3. Open `lib/config/fcm_config.dart`
4. Replace `YOUR_FCM_SERVER_KEY_HERE` with your actual server key:

```dart
static const String serverKey = 'your_actual_server_key_here';
```

### 3. Dependencies

The app uses the following key dependencies:
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database operations
- `firebase_messaging`: Push notifications
- `flutter_local_notifications`: Local notifications
- `http`: HTTP requests for FCM

### 4. Database Structure

The Firestore database contains the following collections:

#### Users Collection
```json
{
  "id": "user_id",
  "name": "User Name",
  "email": "user@example.com",
  "role": "user|admin",
  "preferences": ["Fitness", "Mental Health"],
  "favoriteQuotes": ["quote_id_1", "quote_id_2"],
  "fcmToken": "fcm_token_here",
  "createdAt": "timestamp"
}
```

#### Categories Collection
```json
{
  "id": "category_id",
  "name": "Category Name",
  "description": "Category Description",
  "createdAt": "timestamp"
}
```

#### Quotes Collection
```json
{
  "id": "quote_id",
  "text": "Quote text",
  "author": "Author name",
  "category": "Category name",
  "preferences": ["Fitness", "Mental Health"],
  "createdAt": "timestamp"
}
```

#### Health Tips Collection
```json
{
  "id": "tip_id",
  "title": "Tip title",
  "content": "Tip content",
  "categoryId": "category_id",
  "preferenceId": "preference_id",
  "createdAt": "timestamp"
}
```

#### Reminders Collection
```json
{
  "id": "reminder_id",
  "userId": "user_id",
  "title": "Reminder title",
  "body": "Reminder message",
  "type": "daily|weekly",
  "contentType": "quote|healthTip|both",
  "categories": ["Fitness"],
  "hour": 9,
  "minute": 0,
  "dayOfWeek": 1,
  "isActive": true,
  "createdAt": "timestamp",
  "lastTriggered": "timestamp"
}
```

## App Flow

### User Journey
1. **Registration/Login**: Users can register with email/password or Google Sign-In
2. **Preference Selection**: New users select wellness preferences
3. **Dashboard**: Personalized content based on preferences
4. **Content Browsing**: View quotes, health tips, and favorites
5. **Reminders**: Schedule daily/weekly wellness reminders
6. **Notifications**: Receive push notifications for new content

### Admin Journey
1. **Login**: Admin authentication
2. **Dashboard**: Overview of app statistics
3. **User Management**: View and manage all users
4. **Content Management**: Add categories, quotes, and health tips
5. **Notifications**: Send targeted notifications to users

## FCM Implementation

### Token Management
- **Login/Signup**: FCM token is fetched and saved to user's Firestore document
- **App Launch**: Token is checked and updated if changed
- **Background**: Tokens are managed automatically

### Notification Types
1. **Content Notifications**: Sent when new quotes/health tips are added
2. **Admin Notifications**: Custom notifications sent by admins
3. **Reminder Notifications**: Scheduled local notifications

### Sending Notifications
The app uses FCM HTTP v1 API to send notifications:

```dart
// Send to single user
await FCMServices.sendNotificationToToken(
  token: userToken,
  title: "Notification Title",
  body: "Notification Body",
);

// Send to multiple users
await FCMServices.sendNotificationToMultipleTokens(
  tokens: userTokens,
  title: "Notification Title",
  body: "Notification Body",
);
```

## Security Considerations

1. **FCM Server Key**: Store securely and never commit to version control
2. **Firestore Rules**: Implement proper security rules
3. **User Authentication**: Verify user roles before admin operations
4. **Token Validation**: Validate FCM tokens before sending notifications

## Testing

### Local Testing
1. Run the app on a physical device (FCM doesn't work on simulators)
2. Test user registration and login
3. Test preference selection
4. Test content browsing and favorites
5. Test reminder scheduling
6. Test push notifications

### Admin Testing
1. Create an admin user in Firestore
2. Test admin dashboard
3. Test user management
4. Test content creation
5. Test notification sending

## Troubleshooting

### Common Issues
1. **FCM Not Working**: Ensure you're testing on a physical device
2. **Notifications Not Received**: Check FCM token is saved correctly
3. **Server Key Issues**: Verify the server key is correct and has proper permissions
4. **Firestore Errors**: Check Firestore rules and internet connectivity

### Debug Steps
1. Check console logs for FCM token generation
2. Verify Firestore data structure
3. Test FCM token manually using Firebase Console
4. Check notification permissions on device

## Future Enhancements

- **Analytics**: User engagement tracking
- **Advanced Scheduling**: More flexible reminder options
- **Content Recommendations**: AI-powered content suggestions
- **Social Features**: User interactions and sharing
- **Offline Support**: Cached content for offline viewing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
