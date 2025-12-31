import 'package:flutter/material.dart';
import 'donor/donor_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sahaya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DonorDashboard(), // starting screen
    );
  }
}
