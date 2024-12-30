import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mfoodapp/code/AdminPage.dart';
import 'package:mfoodapp/code/FoodMenu.dart';
import 'package:mfoodapp/code/HomePage.dart';
import 'package:mfoodapp/code/LoginPage.dart';
import 'package:mfoodapp/code/SignUpPage.dart';
import 'package:mfoodapp/code/UserProfilePage.dart';
import 'package:mfoodapp/code/ViewUserOrderHistory.dart';
import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Ordering App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/history':(context) => ViewUserOrderHistory(),
        '/admin':(context) => AdminPage(),
        '/menu':(context) => FoodMenu(),
        '/profile':(context) => const UserProfilePage()
      },
    );
  }
}
