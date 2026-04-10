# Gym Management System

A comprehensive Gym Management System built with Flutter Web and Firebase.

## Features

- **Authentication**: Sign up, sign in, password reset, and remember me functionality
- **Dashboard**: Animated counters, charts, and real-time statistics
- **Member Management**: Add, edit, renew memberships with searchable tables
- **Trainer Management**: Track trainers, classes conducted, and performance
- **Guest Management**: Convert guests to members with trial/daily visits
- **Attendance Tracking**: Mark attendance for members and trainers
- **Payment Management**: Track payments, generate reports, and revenue analytics
- **Plans Management**: Create and manage membership plans with features
- **Workout & Classes**: Schedule and manage gym classes with capacity tracking
- **AI Analytics**: Churn prediction, attendance patterns, and revenue forecasting
- **AI Chatbot**: Instant support for members across all screens
- **Settings**: Profile management, theme switching, and preferences

## Setup Instructions

### 1. Firebase Configuration

Before you can use the app, you need to set up Firebase:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Add a Web app to your Firebase project
4. Copy the Firebase configuration values
5. Update `lib/main.dart` with your Firebase credentials:

\`\`\`dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "YOUR_API_KEY",              // Replace with your API key
    authDomain: "YOUR_AUTH_DOMAIN",      // Replace with your auth domain
    projectId: "YOUR_PROJECT_ID",        // Replace with your project ID
    storageBucket: "YOUR_STORAGE_BUCKET", // Replace with your storage bucket
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID", // Replace with your sender ID
    appId: "YOUR_APP_ID",                // Replace with your app ID
  ),
);
\`\`\`

### 2. Enable Firebase Services

In the Firebase Console, enable the following services:

1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password" provider

2. **Firestore Database**:
   - Go to Firestore Database
   - Create database in production mode (or test mode for development)
   - Set up security rules (see below)

3. **Storage** (optional):
   - Go to Storage
   - Get started with default settings

### 3. Firestore Security Rules

Add these security rules to your Firestore Database:

\`\`\`javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write all documents
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
\`\`\`

### 4. Create Your First Admin Account

1. Run the application: `flutter run -d chrome`
2. On the login screen, click "Sign Up"
3. Enter your email and password (minimum 6 characters)
4. Click "Sign Up" to create your account
5. Switch back to "Sign In" mode
6. Enter your credentials and click "Sign In"

### 5. Install Dependencies

\`\`\`bash
flutter pub get
\`\`\`

### 6. Run the Application

\`\`\`bash
# For web
flutter run -d chrome

# For development with hot reload
flutter run -d chrome --web-renderer html
\`\`\`

## Currency Configuration

The system uses **EGP (Egyptian Pound - E£)** for all financial transactions and displays.

## Language Support

The system supports:
- English
- Arabic

## Default Features

- Material 3 Design
- Dark/Light theme support
- Responsive layout (Desktop, Tablet, Mobile)
- Smooth animations and transitions
- Real-time data synchronization with Firebase

## Troubleshooting

### Cannot Login

**Problem**: "No user found with this email" or "Wrong password provided"

**Solutions**:
1. Make sure you've created an account using the "Sign Up" feature
2. Verify Firebase Authentication is enabled in Firebase Console
3. Check that your Firebase configuration in `main.dart` is correct
4. Ensure you're using the correct email and password

### Firebase Configuration Error

**Problem**: Firebase initialization fails

**Solutions**:
1. Double-check all Firebase configuration values in `main.dart`
2. Ensure your Firebase project is active
3. Verify that the Web app is properly registered in Firebase Console

### Data Not Saving

**Problem**: Members, trainers, or other data not saving

**Solutions**:
1. Check Firestore Database is enabled
2. Verify Firestore security rules allow authenticated users to write
3. Ensure you're logged in with a valid account

## Project Structure

\`\`\`
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── member.dart
│   ├── trainer.dart
│   ├── guest.dart
│   ├── payment.dart
│   ├── plan.dart
│   └── workout_class.dart
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── members_screen.dart
│   ├── trainers_screen.dart
│   ├── guests_screen.dart
│   ├── attendance_screen.dart
│   ├── payments_screen.dart
│   ├── plans_screen.dart
│   ├── classes_screen.dart
│   ├── analytics_screen.dart
│   └── settings_screen.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── ai_analytics_service.dart
│   └── chatbot_service.dart
├── widgets/                  # Reusable widgets
│   ├── side_navigation.dart
│   ├── dashboard_card.dart
│   ├── notification_card.dart
│   ├── chatbot_widget.dart
│   └── [dialogs...]
└── utils/                    # Utilities
    └── theme.dart
\`\`\`

## Support

For issues or questions, please check:
1. Firebase Console for service status
2. Flutter doctor for environment issues
3. Browser console for runtime errors

## License

This project is for educational and commercial use.
