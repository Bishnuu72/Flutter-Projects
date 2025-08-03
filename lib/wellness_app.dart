import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manshi/core/route_config/route_config.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/screens/login_screen.dart';
import 'package:manshi/screens/dashboard_screen.dart';
import 'package:manshi/screens/preference_selection.dart';
import 'package:manshi/screens/admin_screens/admin_dashboard_screen.dart';
import 'package:manshi/screens/admin_screens/admin_init_screen.dart';

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'Wellness App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins'),
        home: const AuthWrapper(),
        onGenerateRoute: RouteConfig.generateRoute,
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in, check their role and navigate accordingly
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final role = userData['role'] ?? 'user';
                final preferences = userData['preferences'] as List<dynamic>? ?? [];

                if (role == 'admin') {
                  // Check if database has any data for admin
                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance.collection('categories').get(),
                    builder: (context, categoriesSnapshot) {
                      if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          backgroundColor: Colors.black,
                          body: Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      }

                      if (categoriesSnapshot.hasData && categoriesSnapshot.data!.docs.isNotEmpty) {
                        return const AdminDashboardScreen();
                      } else {
                        return const AdminInitScreen();
                      }
                    },
                  );
                } else {
                  // Regular user - check if they have preferences
                  if (preferences.isNotEmpty) {
                    return const DashboardScreen();
                  } else {
                    return const PreferenceSelection();
                  }
                }
              } else {
                // User document doesn't exist, redirect to login
                return const LoginScreen();
              }
            },
          );
        } else {
          // User is not logged in
          return const LoginScreen();
        }
      },
    );
  }
}
