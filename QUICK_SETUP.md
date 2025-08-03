# Quick Setup Guide - Wellness App

## Immediate Fix for Navigation Issues

The navigation issues you're experiencing are likely due to:
1. Missing Firebase database setup
2. No sample data in the database
3. Missing admin user configuration

## Quick Steps to Fix:

### 1. Set up Firebase Database
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Enable Authentication (Email/Password + Google)
4. Create Firestore Database in test mode
5. Download `google-services.json` and place in `android/app/`

### 2. Initialize Database with Sample Data
Run this command to populate your database:
```bash
dart run scripts/initialize_firebase.dart
```

### 3. Create Admin User
1. Register a new user in the app
2. Go to Firebase Console → Firestore Database
3. Find the user document in `users` collection
4. Change `role` field from `"user"` to `"admin"`

### 4. Test the App
1. Login with admin credentials → Should go to Admin Dashboard
2. Register new user → Should go to Preference Selection
3. Select preferences → Should go to Dashboard

## Debug Features Added

The app now includes debug buttons:
- **Login Screen**: "Debug Firebase Connection" button
- **Preference Screen**: "Debug Firebase Connection" button

Use these to test Firebase connectivity and see what data is available.

## Common Issues & Solutions

### Issue: Admin login shows nothing
**Solution**: 
- Check if user role is set to "admin" in Firestore
- Ensure database has categories collection

### Issue: Preference selection shows empty
**Solution**:
- Run the initialization script
- Check if preferences collection exists

### Issue: App crashes on startup
**Solution**:
- Verify `google-services.json` is in correct location
- Check Firebase project configuration

## Next Steps

1. Follow the complete setup guide in `FIREBASE_SETUP_COMPLETE.md`
2. Configure FCM for push notifications
3. Test all features thoroughly

The app should now work correctly with proper navigation for both admin and regular users! 