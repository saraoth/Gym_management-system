import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'pages/dashboard_page.dart';
import 'pages/members_page.dart';
import 'pages/guests_page.dart';
import 'pages/trainers_page.dart';
import 'pages/payments_page.dart';
import 'pages/reports_page.dart';
import 'pages/attendance_page.dart';
import 'screens/settings_screen.dart';
import 'screens/classes_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/plans_screen.dart';
import 'utils/theme.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // TODO: Replace these values with your Firebase project configuration
        // Get these values from Firebase Console > Project Settings > Your apps > Web app
        apiKey: "YOUR_API_KEY",
        authDomain: "YOUR_AUTH_DOMAIN",
        projectId: "YOUR_PROJECT_ID",
        storageBucket: "YOUR_STORAGE_BUCKET",
        messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
        appId: "YOUR_APP_ID",
      ),
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('Please configure Firebase in lib/main.dart');
    debugPrint('See README.md for setup instructions');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Set to dark mode to match Next.js design
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardPage(),
        '/members': (context) => const MembersPage(),
        '/guests': (context) => const GuestsPage(),
        '/trainers': (context) => const TrainersPage(),
        '/payments': (context) => const PaymentsPage(),
        '/reports': (context) => const ReportsPage(),
        '/attendance': (context) => const AttendancePage(),
        '/plans': (context) => const PlansScreen(),
        '/classes': (context) => const ClassesScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
