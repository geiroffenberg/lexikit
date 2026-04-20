import 'package:flutter/material.dart';

import '../screens/lexikit_home_screen.dart';

class LexiKitApp extends StatelessWidget {
  const LexiKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexiKit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6F78)),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.15),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.2),
          bodyLarge: TextStyle(fontSize: 17, height: 1.45),
          bodyMedium: TextStyle(fontSize: 15, height: 1.45),
          bodySmall: TextStyle(fontSize: 13.5, height: 1.35),
        ),
      ),
      home: const LexiKitHomeScreen(),
    );
  }
}
