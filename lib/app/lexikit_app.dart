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
      ),
      home: const LexiKitHomeScreen(),
    );
  }
}
