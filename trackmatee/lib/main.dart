import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/Login.dart'; 
import 'screens/home_screen.dart';
import 'screens/Signup.dart' as custom;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // await Firebase.initializeApp(
    //   options: FirebaseOptions(
    //     apiKey: "AIzaSyCuy6CfRi9PolBewvx03xQ_XCd_R8BG-x4", 
    //     authDomain: "trackmate-7313a.firebaseapp.com", 
    //     projectId: "trackmate-7313a", 
    //     storageBucket: "trackmate-7313a.appspot.com",
    //     messagingSenderId: "330700524167", 
    //     appId: "1:330700524167:web:a0cd1f223912a77d470622",
    //     measurementId: "G-EYCCJ3SDQM",
    //   ),
    // );

    await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: "AIzaSyBUdwFZ7xub9SsHf6YlsddsnjiOHmRjarY",
    authDomain: "trackmate-106e0.firebaseapp.com", 
    projectId: "trackmate-106e0", 
    storageBucket: "trackmate-106e0.appspot.com", 
    messagingSenderId: "436163422471", 
    appId: "1:436163422471:android:d7b5e4ceedeb50a74bbda2", 
    measurementId: null, 
  ),
);


    print("Firebase initialized successfully");
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  runApp(TrackMateApp());
}

class TrackMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TrackMate',
            theme: theme.getTheme(),
            initialRoute: '/', 
            routes: {
              '/': (context) => AuthWrapper(), 
              '/login': (context) => LoginScreen(), 
              '/signUp': (context) => custom.SignUpScreen(), 
              '/home': (context) => HomeScreen(), 
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          setupFirestoreStructure();
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

Future<void> setupFirestoreStructure() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

  final docSnapshot = await userDocRef.get();
  if (docSnapshot.exists) {
    print('Firestore structure already exists for user: $userId');
    return;
  }

  await userDocRef.set({
    'name': 'John Doe', 
    'email': FirebaseAuth.instance.currentUser?.email,
  });

  final taskGroupDocRef = await userDocRef.collection('taskGroups').add({
    'name': 'Work',
    'progress': 0.0,
    'taskCount': 0,
  });

  await taskGroupDocRef.collection('tasks').add({
    'name': 'Complete Report',
    'time': '10:00 AM',
    'status': 'In Progress',
    'groupId': taskGroupDocRef.id,
  });

  await taskGroupDocRef.collection('tasks').add({
    'name': 'Email Client',
    'time': '2:00 PM',
    'status': 'Undone',
    'groupId': taskGroupDocRef.id,
  });

  print('Firestore structure set up for user: $userId');
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData getTheme() {
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
