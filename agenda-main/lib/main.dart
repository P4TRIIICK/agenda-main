import 'package:agenda/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:agenda/onboarding/views.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDnCK7zemEi2jpDIYLRwg_YzChvdz0TV5A",
      appId: "1:832191643065:android:6bc0eb7f216f22250b0a68",
      messagingSenderId: "832191643065",
      projectId: "agenda-8b383",
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  final onboarding = prefs.getBool("onboarding")??false;

  
  runApp( MyApp(onboarding: onboarding));
}

class MyApp extends StatelessWidget {
  final bool onboarding;
  const MyApp({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 61, 143, 250)),
        useMaterial3: true,
      ),
      home: onboarding? const Wrapper() : const OnboardingView(),
    );
  }
}